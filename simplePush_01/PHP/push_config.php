<?php
	/*
	 ==============================
	 功能說明 : APNS的連線資訊設定檔
	 建立者 : Samma
	 建立日期 : 2015/06/16
	 異動記錄 :
	
	 ==============================
	 */

	$push_config = array(
			
			// for development environment settings
			'development' => array(
					'push_server'		=> 'gateway.sandbox.push.apple.com:2195',
					'feedback_server'	=> 'feedback.sandbox.push.apple.com:2196',
					'certificate'		=> 'apns-dev.pem',
					'passphrase'		=> 'twtm2015'
			),
				
			// for production environment settings
			'production' => array(
					'push_server'		=> 'gateway.push.apple.com:2195',
					'feedback_server'	=> 'feedback.push.apple.com:2196',
					'certificate'		=> 'apns-dev.pem',
					'passphrase'		=> 'twtm2015'
			)
	);
?>