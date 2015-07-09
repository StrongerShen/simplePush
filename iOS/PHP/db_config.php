<?php
	/*
	 ==============================
	 功能說明 : Database的連線資訊設定檔
	 建立者 : Samma
	 建立日期 : 2015/06/16
	 異動記錄 :
	 2015/07/09	Samma	調整Database連結IP
	 ==============================
	 */

	$db_config = array(
			
			// for development environment settings
			'development' => array(
					'host' 		=> '10.0.1.8',
					'dbname' 	=> 'userdbs',
					'port'		=> '3306',
					'username'	=> 'root',
					'password'	=> 'twtm2015'
			),
			
			// for production environment settings
			'production' => array(
					'host' 		=> '192.168.0.12',
					'dbname' 	=> 'userdbs',
					'port'		=> '3306',
					'username'	=> 'root',
					'password'	=> 'root'
			)
	);
?>