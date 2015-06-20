<?php
require_once("connectsql.php");
require_once("push_config.php");

$message = $_POST["msg"];
$lists = $_POST["list"];

// echo "$message</br>";

// foreach($lists as $member_id)
// {
// 	echo "checked: $member_id</br>";
// }

////////////////////////////////////////////////////////////////////////////////

$ctx = stream_context_create();
stream_context_set_option($ctx, 'ssl', 'local_cert', 'apns-dev.pem');
stream_context_set_option($ctx, 'ssl', 'passphrase', $push_config['development']['push_server']);

// Open a connection to the APNS server
$fp = stream_socket_client(
	'ssl://'.$push_config['development']['push_server'], $err,
	$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);

if (!$fp) exit("<p>Failed to connect: $err $errstr </p>");
echo "<p>Connected to APNS</p>";

// 透過 member_id 查詢要推播對象的 device_token, mem_no
foreach ($lists as $value) {
	$result=$db->query("SELECT device_token,mem_no FROM users WHERE member_id='$value'");
	while($temp=$result->fetch()){
		if ($temp[0]) 
		{
			$deviceToken = $temp[0];
			$memNo = $temp[1];
		}
	}
	if ($deviceToken && $memNo) {
		// 組成 news_id (PK)：mem_no (2碼) + 5碼流水號
		$result = $db->query("SELECT count(news_id) FROM news");
		$temp = $result->fetch();
		if (!$temp){
			$newsId = $memNo."00000";	
		}else {
			$newsIdCount = $temp[0];
		}
		$newsIdCount++;
		$newsId = $memNo.sprintf("%05s",$newsIdCount);
		
// 		echo  "newsIdNumber:$newsIdNumber<br>";
// 		echo  "newsId:$newsId<br>";
		
		// 寫入資料庫 table `news` news_id & device_token & msg
		$result = $db->prepare("INSERT INTO news (news_id, msg, device_token) VALUES (?, ?, ?)");
		$result->execute(array((string)$newsId, $message, $deviceToken));
// 		$stmt->bindParam(1, $newsId);
// 		$stmt->bindParam(2, $message);
// 		$stmt->bindParam(3, $deviceToken);
		
		// Create the payload body
		$result = $db->prepare("SELECT COUNT(news_id) FROM news WHERE have_read = 0 AND news_id LIKE '$memNo%'");
		$result->execute();
		$temp = $result->fetch();
		$badge = $temp[0];

		$body['aps'] = array(
				'alert' => $message,
				'sound' => 'default',
				'badge' => (int)$badge
			);
		// Encode the payload as JSON
		$payload = json_encode($body);

		// Build the binary notification
		// $msg = chr(0). pack('n',32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;
		
		$id = time();
		$expire = time() + 600;//10 minutes
		if ($expire) {
			$msg = chr(1) . pack('N',$id) . pack('N',$expire) .pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;
		}

		// Send it to the server
		$fwresult = fwrite($fp, $msg, strlen($msg));
		
		if (!$fwresult)
			echo "Message not delivered.</br>";
		else
			echo "Message successfully delivered.</br>";
	}
}
// Close the connection to the server
fclose($fp);


