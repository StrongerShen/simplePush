<?php
	/*
	 ==============================
	 功能說明 : 連線Database
	 建立者 : Samma
	 建立日期 : 2015/06/16
	 異動記錄 :
	
	 ==============================
	 */

	// include db config file
	require_once ('db_config.php');

	// get development environment settings
	$get_db_config = $db_config['development'];
	
	// set pdo connect
	$db = new PDO("mysql:host={$get_db_config['host']};dbname={$get_db_config['dbname']};port:{$get_db_config['port']}",
					$get_db_config['username'],
					$get_db_config['password']);
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