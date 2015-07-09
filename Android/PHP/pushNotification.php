<?php

	define("GOOGLE_API_KEY", "AIzaSyB8cneIrOV1nRsr3pb8FD3XgC5tJLe637g");
	define("GOOGLE_GCM_URL", "https://android.googleapis.com/gcm/send");
	 
	require_once("connectsql.php");
	
	// 取得推播對象的 device_token, msg
	$sendAllFlag = $_POST["sendAll"];
	$lists = $_POST["list"];
	$msgTitle = $_POST["msgTitle"];
	$message = $_POST["msg"];

	$msgJSON = array("message" => $msgTitle);
	
	$device_tokens = array();
	$payload = array();
	$i = 0;
	
	if ( $sendAllFlag == 0 ) {
		foreach ($lists as $value) {
		
			//get device_token
			$result = $db->query("select device_token,mem_No
					from users
					where member_id='$value' and stop_push_mk = '0'");
			$row = $result->fetch();
		
			if ($row && $row["device_token"] != NULL && $row["mem_No"] != NULL) {
				$device_tokens[$i] = $row["device_token"];
				$i++;
			}
		
		}
		
		$payload = array(	'registration_ids'  => $device_tokens,
							'data'              => $msgJSON,
						);
	} else {
		$payload = array(	'to'	=> '/topics/global',
							'data'	=> $msgJSON,
						);
	}
	
		
	$headers = array(
		'Authorization: key=' . GOOGLE_API_KEY,
		'Content-Type: application/json'
	);
	
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, GOOGLE_GCM_URL);
	curl_setopt($ch, CURLOPT_POST, true);
	curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
	curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));

	$result = curl_exec($ch);
	if ($result === FALSE) {
		die('Problem occurred: ' . curl_error($ch));
	}

	curl_close($ch);
	echo $result;

?>