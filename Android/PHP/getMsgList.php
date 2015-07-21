<?php
	/*
	 ==============================
	 功能說明 : 依傳入的 member_id 回饋所有發送給該使用者的訊息列表
	 Input  =>	member_id		:	user的member_id
	 Output =>	errCode			:	錯誤代碼 (沒有錯誤時回傳0),
	 			errMsg			:	錯誤訊息,
	 			msgNumNread		:	該使用者總共有幾條訊息 (未讀)
	 			msgNumYread		:	該使用者總共有幾條訊息 (已讀)
	 			content(array)	:	訊息列表內容
	 								newsId		:	訊息 ID
					 				sendTime	:	訊息發送時間
					 				preMsg		:	訊息前一段文字，固定 10 個字元，不足 10 字元的訊息以原長度為主
					 				haveRead	:	訊息是否已讀 [ 0:未讀 ; 1:已讀 ]
	 建立者 : Samma
	 建立日期 : 2015/06/18
	 異動記錄 :
	 2015/06/23	Samma	1、回傳內容增加newsId
	 2015/06/30	Samma	1、調整回傳的訊息改讀msgTitle
	 2015/07/15	Samma	1、調整回傳的訊息列表，如果 title 本身沒超過 10 個字元，後面不用加 "..."
	 2015/07/21	Samma	1、調整回傳的訊息 title 不需要加 ...
	 					2、加入 last_login_time 記錄
	 ==============================
	 */

	//receive member_id
	//$member_id = $_POST['member_id'];
	$member_id = 'Samma2';
	
	//handle error
	$errCode = 0;
	$errMsg = '';
	
	//Database Connect
	require_once('connectsql.php');
	
	//=======當前端每次與這個頁面連線，更新 users.last_login_time========
	try {
			
		$db->beginTransaction();
			
		//當device token不存在時新增
		$result = $db->query("update users
							     set last_login_time = now()
							   where member_id = '$member_id'");
			
		$db->commit();
			
	} catch (PDOException $err) {
			
		$db->rollback();
		$errCode = $err->getCode();
		$errMsg = $err->getMessage();
			
	}
	
	//==========取得訊息列表===========
	try {
		
		//依指定的訊息 ID 從Database 取出訊息的完整內容
		//if( char_length(b.msg_title) <= 10,b.msg_title,concat(substr(b.msg_title,1,10),'...') ) pre_msg,
		$sth = $db->prepare("select b.news_id,
									b.msg_title pre_msg,
									b.have_read,
									date_format(b.send_time, '%Y-%m-%d %H:%i:%s') send_time
							   from users a, news b
							  where a.device_token = b.device_token
	  							and a.member_id = :id
						   order by b.send_time desc
						");
		$sth->bindParam("id",$member_id,PDO::PARAM_INT);
		$sth->execute();
		
		//統計已讀、未讀訊息數
		$msgNumNread = 0;
		$msgNumYread = 0;
		
		//data array
		$msgArray = array();
		$i = 0;
		
		while ( $row = $sth->fetch() ) {
		
			$news_id = $row['news_id'];
			$pre_msg = $row['pre_msg'];
			$have_read = $row['have_read'];
			$send_time = $row['send_time'];
		
			if ($have_read) {	//have_read = 1
				$msgNumYread ++;
			} else {			//have_read = 0
				$msgNumNread ++;
			}
		
			//資訊息內容串成陣列
			$msgArray[$i] = array(
					'newsId'	=>	$news_id,
					'sendTime'	=>	$send_time,
					'preMsg'	=>	$pre_msg,
					'haveRead'	=>	$have_read
			);
		
			$i++;
			//echo "pre_msg={$pre_msg}, have_read={$have_read}, send_time={$send_time}, Nread={$msgNumNread}, Yread={$msgNumYread}<br>";
		
		}	//end while ( $row = $sth->fetch() )
		
	} catch (PDOException $err) {
		$errCode = $err->getCode();
		$errMsg = $err->getMessage();
	}
	
	//close Database Connect
	$db = null;
	
	//編碼傳回內容
	//1. check 是否有訊息資料
	if ( ($msgNumNread + $msgNumYread) == 0 && !$errCode) {
		$errCode = 1;
		$errMsg = "member_id = {$member_id} , is data not found";
	}
	
	//2. 開始編碼
	$responseArray = array(
			'errCode'		=>	$errCode,
			'errMsg'		=>	$errMsg,
			'msgNumNread'	=>	$msgNumNread,
			'msgNumYread'	=>	$msgNumYread,
			'content'		=>	$msgArray
	);
	
	echo json_encode( $responseArray );
	
?>