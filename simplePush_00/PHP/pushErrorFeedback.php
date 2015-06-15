<?php
	//到APNs取回推播訊息的error feedback
	
	$passphrase = 'twtm2015';

	$ctx = stream_context_create();
	stream_context_set_option($ctx, 'ssl', 'local_cert', '../simple_push/apns-dev.pem');
	stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);
	
	// Open a connection to the APNS server
	$fp = stream_socket_client(
		'ssl://feedback.sandbox.push.apple.com:2196', $err,
		$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);
	
	if (!$fp)
		exit("Failed to connect Feedback Server: $err $errstr" . PHP_EOL);
	
	echo 'Connected to Feedback Server' . PHP_EOL;
	
	// get APNs feeback service result，everytime get 38 bytes
	while ( $result = fread($fp, 38) ) {

		//將會得到一個關聯式的array
		$errorFeedbackArray = unpack("H*", $result);
		
		//把array的元素串成字串回傳
		$errorFeedbackStr = trim( implode("", $errorFeedbackArray) );
		
		//取出前面4個byte的時間戳記，並且把十六進制資料轉為十進制
		$feedbackTime = hexdec(substr($errorFeedbackStr, 0, 8));
		
		//轉成可讀的日期格式
		date_default_timezone_set('Asia/Taipei');
		@$feedbackDate = date('Y-m-d H:i', $feedbackTime);
		
		//取出token length
		$feedbackLen = hexdec(substr($errorFeedbackStr, 8, 4));
		
		//取出device token
		$feedbackDeviceToken = substr($errorFeedbackStr, 12, 64);
		
		echo "timestamp : ".$feedbackDate. PHP_EOL;
		echo "device id : ".$feedbackDeviceToken. PHP_EOL;
	}
fclose($fp);
?>