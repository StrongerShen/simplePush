<?php
	$db = new PDO("mysql:host=192.168.0.12;dbname=userdbs;port:3306","root","root");
	$db->exec("set names utf8");
	if (!$db) {
		exit("...connect database error ".$db->errorCode().":".$db->errorInfo());
	} 
	
	// test db select
	/*
	echo "connect PDO";
	$result = $db->query("select * from users");
	while ( $row = $result->fetch() ) {
		echo "member_No : {$row['member_No']}<br>";
		echo "member_id : {$row['member_id']}<br>";
		echo "member_name : {$row['member_name']}<br>";
		echo "device_token : {$row['device_token']}<br>";
		echo "<HR>";
	}
	*/
?>