<?php
	/*
	 ==============================
	 功能說明 : 到APNs取回推播訊息的error feedback
	 建立者 : Samma
	 建立日期 : 2015/06/11
	 異動記錄 :
	 2015/06/16	Samma	1、調整連結Feedback Service的連線資料改由push_config.php讀取
						2、對DB的處理改為PDO方式
						3、從Feedback Service取回的資料，寫入MySQL的push_error_log table
	 2015/06/18	Samma	1、加入 transaction 控制
	 2015/06/22	Samma	1、調整啟動方法名稱由 writePushError() 調整為 start()
	 ==============================
	 */

	//取得APNS Feedback Service的連線資訊
	require_once('push_config.php');
	$get_push_config = $push_config['development'];
	
	//建立處理Feedback Service資料的物件
	$feedbackObj = new APNS_Feedback($get_push_config);
	$feedbackObj->start();

////////////////////////////////////////////////////////////////

	class APNS_Feedback
	{
		private $server;
		private $certificate;
		private $passphrase;
		
		//建構元
		function __construct($get_push_config) {
			$this->server		= $get_push_config['feedback_server'];
			$this->certificate	= $get_push_config['certificate'];
			$this->passphrase	= $get_push_config['passphrase'];
		}
		
		function start() {
			
			//Database Connect
			require_once('connectsql.php');
			
			//取回Feedback Service 記錄推播異常的device token
			$feedBackData = $this->getFeedbackData();
			
			foreach ($feedBackData as $device) {
				
				//check device token 是否已存在
				$sth = $db->prepare("select count(*) cnt from push_error_log where device_token = :dt");
				$sth->bindParam("dt",$device['device_token'],PDO::PARAM_STR,256);
				$sth->execute();
				$result = $sth->fetchAll();
				$data = $result[0];
				$count = $data['cnt'];
				
				//如果 Database 捕捉到例外(ex.SQL syntax 錯誤等等)，所有 transaction rollback
				try {
					
					$db->beginTransaction();
					
					//write data to push_error_log
					if ($count > 0) {	//如果 device token 已經存在
							
						//update 
						$sth = $db->prepare("update push_error_log
										 	set final_push_time = :time,
												receive_time = :rt
										  where device_token = :dt
										");
						$sth->bindParam("time",$device['timestamp'],PDO::PARAM_STR);
						$sth->bindParam("rt",date('Y-m-d H:i'),PDO::PARAM_STR);
						$sth->bindParam("dt",$device['device_token'],PDO::PARAM_STR,256);
						$sth->execute();
							
					} else {
							
						//insert
						$sth = $db->prepare("insert into push_error_log
											(device_token, final_push_time)
										 values
											(:dt, :time)
										");
						$sth->bindParam("dt",$device['device_token'],PDO::PARAM_STR,256);
						$sth->bindParam("time",$device['timestamp'],PDO::PARAM_STR);
						$sth->execute();
					}
					
					//update users.stop_push_mk
					$sth = $db->prepare("update users
											set stop_push_mk = '1'
										  where device_token = :dt
										");
					$sth->bindParam("dt",$device['device_token'],PDO::PARAM_STR,256);
					$sth->execute();
					
					echo "write push error devie_token => " .$device['device_token']. PHP_EOL;

					$db->commit();
					
				} catch (PDOException $err) {
					$db->rollback();
					echo "Error:".$err->getMessage();
				}
				
			}	//end foreach ($feedBackData as $device)
			
			//close Database Connect
			$db = null;
			
		} //end function => writePushError();
		
		//從 Feedback Service 讀取資料
		function getFeedbackData() {
			
			$ctx = stream_context_create();
			stream_context_set_option($ctx, 'ssl', 'local_cert', $this->certificate);
			stream_context_set_option($ctx, 'ssl', 'passphrase', $this->passphrase);
			
			//與 APNS 建立 Socket Connection
			$fp = stream_socket_client(
					'ssl://'.$this->server, $err,
					$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);
			
			if (!$fp) {
				exit("Failed to connect Feedback Server: $err $errstr" . PHP_EOL);
			}
			
			echo 'Connected to Feedback Server' . PHP_EOL;
					
			// 開始取回資料
			$errorLog = array();
			$i = 0;
			
			// get APNs feeback service result，everytime get 38 bytes
			while ( $result = fread($fp, 38) ) {
			
				//將會得到一個關聯式的array
				$errorFeedbackArray = unpack("H*", $result);
			
				//把array的元素串成字串回傳
				$errorFeedbackStr = trim( implode("", $errorFeedbackArray) );
			
				//取出前面4個byte的時間戳記，並且把十六進制資料轉為十進制
				$feedbackTime = hexdec(substr($errorFeedbackStr, 0, 8));
			
				//轉成可讀的日期格式
				date_default_timezone_set('Asia/Taipei');
				@$feedbackDate = date('Y-m-d H:i', $feedbackTime);
			
				//取出token length
				$feedbackLen = hexdec(substr($errorFeedbackStr, 8, 4));
			
				//取出device token
				$feedbackDeviceToken = substr($errorFeedbackStr, 12, 64);
			
				//將準備寫入 push_error_log 的資料組成陣列後回傳
				$errorLog[$i] = array(
						'timestamp'		=> $feedbackDate,
						'device_token'	=> $feedbackDeviceToken
				);
				
				$i++;
				
			}	// end while loop
			
			//關閉與 APNS 間的Socket Connection
			fclose($fp);
			
			return $errorLog;
			
		}	//end function => getFeedbackData()
		
	}	//end class => APNS_Feedback
?>