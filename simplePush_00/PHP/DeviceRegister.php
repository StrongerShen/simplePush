<?php
/*
 ==============================
    功能說明 : 	使用者名稱、裝置名稱、裝置代號，寫入資料庫

    Input  =>	(string)    device_token   :   裝置代號
                (string)    member_id      :   使用者名稱
                (string)    member_name    :   裝置名稱

    建立者 : James
    建立日期 : 2015/06/18
    異動記錄 :
	2015/06/22	Samma	1、增加 try catch 處理
 ==============================
 */

	require_once("connectsql.php");
	
	$device_token = $_POST['device_token'];
	$member_id = $_POST['memID'];
	$member_name = $_POST['memName'];
	
	$message = array("ret_code"=>"", "ret_desc"=>"", "user_id"=>"");
	
	$result = $db->query("select * from users where device_token='$device_token' ") or die('901');
	
	//PDOStatement::rowCount — 取得上一個執行的SQL語法，影響到的資料筆數
	if ($result->rowCount() <=0 ) {
		
		try {
			
			$db->beginTransaction();
			
			//當device token不存在時新增
			$result = $db->query("INSERT INTO users
								 (member_id, member_name, member_phone, device_token)
							 	 VALUES
								 ('$member_id', '$member_name', 'new_member_phone', '$device_token')"
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
	}

	//close Database Connect
	$db = null;
	
	echo json_encode($message);

?>
