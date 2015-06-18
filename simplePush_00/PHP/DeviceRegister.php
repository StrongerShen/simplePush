<?php
require_once("connectsql.php");

$device_token = $_POST['device_token'];
$member_id = $_POST['memID'];
$member_name = $_POST['memName'];

$message = array("ret_code"=>"", "ret_user_id"=>"");

$result = $db->query("SELECT * from users WHERE device_token='$device_token' ") or die('901');

//PDOStatement::rowCount — 取得上一個執行的SQL語法，影響到的資料筆數
if ($result->rowCount() <=0 ) {
	
	//當device token不存在時新增
	$result = $db->query("INSERT INTO users 
							(member_id, member_name, member_phone, device_token) 
						  VALUES 
							('$member_id', '$member_name', 'new_member_phone', '$device_token')"
						) or die('903');
	
	//新增完成，處理結果["ret_code"]返回YES，代表OK
	$message["ret_code"]='YES';
	
} else {
	
	//當device token已存在時，處理結果["ret_code"]返回NO，代表不OK
	$message["ret_code"]='NO';
	
}

echo json_encode($message);

?>
