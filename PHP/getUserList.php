<?php

	/*
	 ==============================
	 功能說明 : 回饋 user list 資料
	 Input  =>	NO
	 Output =>	array[0]	=>	member_id		:	user name
								member_name		:	device name
								device_token	:	device token
				array[1]	=>	同 array[0]，以此類推
	 建立者 : Samma
	 建立日期 : 2015/06/20
	 異動記錄 :
	 
	 ==============================
	 */

	//Database Connect
	require_once("connectsql.php");
		
	try {
		
		$result=$db->query("select mem_No,device_token,member_name,member_id from users order by member_id");
		
		$i = 1;
		$user_list = array();
		
		while($rows = $result->fetch()) {
		
			$device_token = $rows['device_token'];
			$member_name = $rows['member_name'];
			$member_id = $rows['member_id'];
			$member_no = $row["mem_No"];
			
			$user_list[$i] = array(
					"member_id"		=>	$member_id,
					"member_name"	=>	$member_name,
					"device_token"	=>	$device_token
			);
			
			$i++;
		
		}
		
	} catch (PDOException $err) {
		
		echo "Query Error => ".$err->getMessage();
		
	}
	
	//close Database Connect
	$db = null;
	
	echo json_encode($user_list);
?>