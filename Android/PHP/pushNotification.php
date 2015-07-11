<?php
/*
 ==============================
 	功能說明 :  存檔：將推播相關訊息存入資料庫(Table `news`)
 			   推播：製作推播內容，與 APNS 建立連線，並傳送至 APNS，發出推播給 users

 	Input  =>       lists           :   推播對象的 Member Id
 					message         :   推播訊息
 	Output =>       NO

 	建立者 : Samma
 	建立日期 : 2015/07/11
 	異動記錄 :

 ==============================
 */
	 
	try {
		require_once("connectsql.php");
		require_once("push_config.php");
	
		$obj = new GCM_Push($db,$push_config);
		$obj->start();
	
	} catch (Exception $e) {
		echo ($e);
	}
	
///////////////////////////////////////
class GCM_Push {
	
	private $db;
	private $push_server;
	private $api_key;
	
	function __construct($db, $push_config) {
		$this->db = $db;
		$this->push_server = $push_config['development']['push_server'];
		$this->api_key = $push_config['development']['api_key'];
	}
	
	function start() {
		
		// 取得推播對象的 device_token, msg
		$sendAllFlag = $_POST["sendAll"];
		$lists = $_POST["list"];
		$msgTitle = $_POST["msgTitle"];
		$message = $_POST["msg"];
	
		if ($lists && $msgTitle){
			
			$device_tokens = array();
			$i = 0;
			
			foreach ($lists as $value) {
				 
				$result = $this->db->prepare("select device_token,mem_No 
												from users 
											   where member_id = '$value' 
												 and stop_push_mk = '0'");
				$result->execute();
				$temp = $result->fetch();
	
				if ($temp && $temp[0] != NULL && $temp[1] != NULL) {
					 
					try {
	
						$this->db->beginTransaction();
						
						//寫入訊息
						$this->insertDataBase($msgTitle, $message, $temp[0], $temp[1]);
						$device_tokens[$i] = $temp["device_token"];
						$i++;
	
						$this->db->commit();
	
					} catch (PDOException $err) {
						$this->db->rollback();
						echo "insert error:".$err->getMessage();
					}
	
				}
	
			}	// end foreach ($lists as $value)
				
			//執行推播
			$this->sendNotification($msgTitle, $device_tokens, $sendAllFlag);
			 
		}	//end if ($lists && $message)
		 
	}	//end function start()
	
	//存檔：將推播訊息存入資料表
	function insertDataBase($msgTitle, $message, $deviceToken, $memNo) {
		// 組成流水號 seq_no
		$result = $this->db->prepare("select MAX(seq_no) 
										from news 
									   where mem_No = $memNo");
		$result->execute();
		$temp = $result->fetch();
		$seqNo = $temp[0];
		if ($seqNo==NULL){
			$seqNo = 0;
		}
		$seqNo++;
	
		// 寫入資料庫 table `news` mem_No & seq_no & device_token & msg
		$result = $this->db->prepare("insert into news 
									  (mem_No, seq_no, msg_title, msg, device_token) 
									  values
									  (?, ?, ?, ?, ?)");
		$result->execute(array($memNo, $seqNo, $msgTitle, $message, $deviceToken));

	}	//end function insertDataBase()
	
	// 傳送推播內容至 APNS 給指定對象
	function sendNotification($msgTitle, $device_tokens, $sendAllFlag){
		
		//要傳送的訊息內容
		$msgJSON = array("message" => $msgTitle);
		
		$payload = array();
		
		//部份發送
		if ( $sendAllFlag == 0 ) {
			$payload = array(	'registration_ids'  => $device_tokens,
								'data'              => $msgJSON,
			);
		
		//全部發送
		} else {
			$payload = array(	'to'	=> '/topics/global',
								'data'	=> $msgJSON,
			);
		}
		
		
		$headers = array(
				'Authorization: key=' . $this->api_key,
				'Content-Type: application/json'
		);
		
		$ch = curl_init();
		//發出 request 的網址
		curl_setopt($ch, CURLOPT_URL, $this->push_server);
		//使用 GET or POST 方式發出 request
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
		//指定curl_exec()執行後獲得的資料以stream的形式回傳，不直接輸出
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
		//設定要傳過去的參數
		curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
		
		$result = curl_exec($ch);
		if ($result === FALSE) {
			die('push error: ' . curl_error($ch));
		}
		
		curl_close($ch);
		echo $result;

	}	//end function sendNotification()
	
}	// end class GCM_Push


?>