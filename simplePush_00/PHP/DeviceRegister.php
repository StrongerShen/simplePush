<?php
require_once("connectsql.php");

$device_token = $_POST['device_token'];
$member_id = $_POST['memID'];
$member_name = $_POST['memName'];


$message = array("ret_code"=>"", "ret_user_id"=>"");


$sql = "SELECT * from users WHERE device_token='$device_token' ";
$result = mysql_query($sql) or die ('901');

if (mysql_num_rows($result) <=0 ) {
	//新增
	$sql = "INSERT INTO users (member_id, member_name, member_phone, device_token) 
	VALUES ('$member_id', '$member_name', 'new_member_phone', '$device_token')";
	$result = mysql_query($sql) or die('903');
	
	$message["ret_code"]='YES';
} else {
	//修改
	$message["ret_code"]='NO';
}

echo json_encode($message);

?>
