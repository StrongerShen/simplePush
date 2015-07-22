<?php
	/*
	 ==============================
	 功能說明 : Cloud Message 的連線資訊設定檔
	 建立者	 : Samma
	 建立日期 : 2015/07/11
	 異動記錄 :
	 2015/07/22	Samma 1、api key update
	 ==============================
	 */

	$push_config = array(
			
			// for development environment settings
			'development' => array(
					'push_server'		=> 'https://android.googleapis.com/gcm/send',
					'feedback_server'	=> 'no data',
					'api_key'			=> 'AIzaSyBV_rkecXDwKl8dUeCTy_5pBDgE7KiVcgo'
			),
				
			// for production environment settings
			'production' => array(
					'push_server'		=> 'https://android.googleapis.com/gcm/send',
					'feedback_server'	=> 'no data',
					'api_key'			=> 'AIzaSyBV_rkecXDwKl8dUeCTy_5pBDgE7KiVcgo'
			)
	);
?>