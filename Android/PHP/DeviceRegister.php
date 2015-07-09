<?php
/*
 ==============================
    功能說明 : 	使用者名稱、裝置名稱、裝置代號，寫入資料庫

    Input	=>	device_token	:   裝置代號
                memID			:   使用者名稱
                memberName		:   裝置名稱
              	memberPwd		:	使用者密碼  			
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
 ==============================
 */

	require_once("connectsql.php");
	
	$device_token = $_POST['device_token'];
	$member_id = $_POST['memID'];
	$member_name = $_POST['memName'];
	$member_pwd = $_POST["memberPwd"];
	
	if (empty($member_pwd) or strlen($member_pwd) == 0) {
		$member_pwd = '123';
	}
	
	//md5密碼加密
	$member_pwd = md5($member_pwd);
	
	$message = array("ret_code"=>"", "ret_desc"=>"", "user_id"=>"", "user_name"=>"", "device_name"=>"", "device_token"=>"");
	
	$result = $db->query("select * from users where device_token='$device_token' ") or die('901');
	
	//PDOStatement::rowCount — 取得上一個執行的SQL語法，影響到的資料筆數
	if ($result->rowCount() <=0 ) {
		
		try {
			
			$db->beginTransaction();
			
			//當device token不存在時新增
			$result = $db->query("INSERT INTO users
								 (member_id, member_pwd, member_name, member_phone, device_token, device_type)
							 	 VALUES
								 ('$member_id', '$member_pwd','$member_name', 'new_member_phone', '$device_token', '1')"
			) or die('903');
			
			//新增完成，處理結果["ret_code"]返回YES，代表OK
			$message["ret_code"]='YES';
			
			$db->commit();
			
		} catch (PDOException $err) {
			
			$db->rollback();
			$message["ret_code"]='NO';
			$message["ret_desc"] = $err->getMessage();
			
		}
	
	} else {
		
		//當device token已存在時，處理結果["ret_code"]返回NO，代表不OK
		$message["ret_code"] = 'NO';
		$message["ret_desc"] = 'device token already exists';
		
	}	// end if ($result->rowCount() <=0 )

	//get user id
	$result = $db->query("select * from users where device_token='$device_token' ") or die('query member ID failure');
	foreach ($result as $row) {
		$message["user_id"] = $row['mem_No'];
		$message["user_name"] = $row['member_id'];
		$message["device_name"] = $row['member_name'];
		$message["device_token"] = $row['device_token'];
	}

	//close Database Connect
	$db = null;
	
	echo json_encode($message);

?>
