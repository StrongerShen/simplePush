<?php
require_once("connectsql.php");

// Put your private key's passphrase here:
$passphrase = 'twtm2015';
//$deviceToken = '1ec0f3489a33feaf98d0fc7b75ae8ec7818b55f051c54252b5497ca70920139c';//JamesID
$message = $_POST["msg"];
$devicetoken = $_POST["device_token"];
$lists = $_POST["list"];

//echo "$message</br>, $devicetoken</br> $CheckboxGroup1</br>";

// foreach($lists as $value)
// {
// 	echo "checked: $value</br>";
// }

////////////////////////////////////////////////////////////////////////////////

$ctx = stream_context_create();
stream_context_set_option($ctx, 'ssl', 'local_cert', 'apns-dev.pem');
stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);

// Open a connection to the APNS server
$fp = stream_socket_client(
	'ssl://gateway.sandbox.push.apple.com:2195', $err,
	$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);

if (!$fp) exit("<p>Failed to connect: $err $errstr </p>");
echo "<p>Connected to APNS</p>";


foreach ($lists as $value) {
	$sql="select device_token from users where member_id='$value' ";
	$result=mysql_query($sql,$link);
	while($post=mysql_fetch_row($result)){
		if ($post[0]) 
		{
			$deviceToken = $post[0];
		}
	}

	if ($deviceToken) {

		// Create the payload body
		$body['aps'] = array(
				'alert' => $message,
				'sound' => 'default',
				'badge' => 2
			);

		// Encode the payload as JSON
		$payload = json_encode($body);

		// Build the binary notification
		// $msg = chr(0). pack('n',32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;
		
		$id = time();
		$expire = time() + 600;
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


