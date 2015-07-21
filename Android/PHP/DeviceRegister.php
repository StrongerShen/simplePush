<?php
/*
 ==============================
    功能說明 : 	使用者名稱、裝置名稱、裝置代號，寫入資料庫

    Input	=>	device_token	:   裝置代號
                memID			:   使用者名稱
                memName			:   裝置名稱
              	memPwd			:	使用者密碼
              	device_type		:	裝置類型[0:iphone ; 1:android]
    Output	=>	ret_code					:	處理結果 (YES / NO)
    			ret_desc					:	處理結果說明
    			user_id						:	對應users.mem_No
    			user_name					:	對應users.member_id
    			device_name					:	對應users.member_name
    			device_token				:	對應users.device_token

    建立者 : James
    建立日期 : 2015/06/18
    異動記錄 :
	2015/06/22	Samma	1、增加 try catch 處理
	2015/06/23	Samma	1、增加回傳 user_name、device_name、device_token
	2015/07/09	Samma	1、增加密碼預設功能
						2、增加傳入 device_type [裝置類型]，便於後續整合成 simpleTalk 專案
						3、重構程式，以 class 的方式重寫
	2015/07/21	Samma	1、增加判斷 member_id 已經存在時，更新 device_token，不返回 device_token 已存在的訊息
 ==============================
 */

	$device = new DeviceRegister();
	$device->start();
	$device->close();
	
////////////////////////////////////////
	
	class DeviceRegister {
		
		private $connDB;
		private $device_token;
		private $member_id;
		private $member_name;
		private $member_pwd;
		private $device_type;
		private $message;
		
		function __construct () {
			
			//Database Connect
			require_once("connectsql.php");
			
			$this->connDB = $db;
			$this->device_token = isset($_POST['device_token']) ? $_POST['device_token'] : NULL;
			$this->member_id = isset($_POST['memID']) ? $_POST['memID'] : NULL;
			$this->member_name = isset($_POST['memName']) ? $_POST['memName'] : NULL;
			$this->member_pwd = isset($_POST['memPwd']) ? $_POST['memPwd'] : NULL;
			$this->device_type = isset($_POST['device_type']) ? $_POST['device_type'] : NULL;
			
			
			//如果密碼沒有傳入，自動預設 123，此設計是為了避免現階段前端錯誤而無法運作，後續的simpleTalk是不做這樣設計的
			if (empty($this->member_pwd) or strlen($this->member_pwd) == 0) {
				$this->member_pwd = md5('123');
			}
			
			//return json init
			$this->message = array("ret_code"=>"", "ret_desc"=>"", "user_id"=>"", "user_name"=>"", "device_name"=>"", "device_token"=>"");
			
		}
		
		function start() {
			
			try {
			
				$result = $this->connDB->query("select * 
												  from users 
									   			 where device_token = '$this->device_token'");
				
				//PDOStatement::rowCount — 取得上一個執行的SQL語法，影響到的資料筆數
				if ($result->rowCount() <= 0 ) {
						
					try {
				
						$this->connDB->beginTransaction();
				
						//當device token不存在時新增
						$result = $this->connDB->query("INSERT INTO users
											  			(member_id, member_pwd,
											  			 member_name, member_phone,
											  			 device_token, device_type)
											 			VALUES
											  			('$this->member_id', '$this->member_pwd',
											   			 '$this->member_name', 'new_member_phone',
											   			 '$this->device_token', '$this->device_type')");
				
						//新增完成，處理結果["ret_code"]返回YES，代表OK
						$this->message["ret_code"]='YES';
				
						$this->connDB->commit();
				
					} catch (PDOException $err) {
				
						$this->connDB->rollback();
						$this->message["ret_code"]='NO';
						$this->message["ret_desc"] = $err->getMessage();
				
					}
						
				} else {
					
					try {
						
						$this->connDB->beginTransaction();
						
						//若device token已經存在，將使用者帳號、密碼、裝置名稱直接更新
						$result = $this->connDB->query("update users
														   set member_id = '$this->member_id',
															   member_pwd = '$this->member_pwd',
															   member_name = '$this->member_name'
														 where device_token = '$this->device_token'
														   and device_type = '$this->device_type'");
							
						$this->message["ret_code"] = 'YES';
						$this->message["ret_desc"] = 'device token already exists';
						
						$this->connDB->commit();
						
					} catch (PDOException $err) {
				
						$this->connDB->rollback();
						$this->message["ret_code"]='NO';
						$this->message["ret_desc"] = $err->getMessage();
				
					}
						
				}	// end if ($result->rowCount() <=0 )
				
				
				//註冊成功的話，寫入使用者資訊，準備回傳
				try {
					
					//get user id
					$result = $this->connDB->query("select * 
													  from users 
													 where device_token = '$this->device_token'");
					foreach ($result as $row) {
						$this->message["user_id"] = $row['mem_No'];
						$this->message["user_name"] = $row['member_id'];
						$this->message["device_name"] = $row['member_name'];
						$this->message["device_token"] = $row['device_token'];
					}
					
				} catch (PDOException $err) {
					
					$this->message["ret_code"]='NO';
					$this->message["ret_desc"] = $err->getMessage();
					
				}

			}catch(PDOException $err) {
			
				$this->message["ret_code"]='NO';
				$this->message["ret_desc"] = $err->getMessage();
			
			}
			
		}	//end function start()
		
		function close() {
			
			//close Database Connect
			$this->connDB = null;
			exit( json_encode($this->message) );
			
		}	//end function close()
		
	}


?>
