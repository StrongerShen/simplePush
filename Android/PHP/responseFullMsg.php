<?php
	/*
	 ==============================
	 功能說明 : 依傳入的 news_id 回饋完整訊息
	 Input  =>	news_id	:	訊息ID
	 Output =>	errCode	:	錯誤代碼 (沒有錯誤時回傳0)
				errMsg	:	錯誤訊息
				title	:	新聞標題
				sendTime:	發送時間
				fullMsg	:	完整訊息
	 建立者 : Samma
	 建立日期 : 2015/06/17
	 異動記錄 :
	 2015/06/18	Samma	1、加入 transaction 控制
	 2015/07/09	Samma	1、針對一開始取出完整訊息的 SQL，增加 try catch 例外處理
	 2015/07/22	Samma	1、增加回傳 title & send time
	 ==============================
	 */

	//connect database
	require_once('connectsql.php');

	//receive message id
	$news_id = $_POST['news_id'];
	
	//handle error
	$errCode = 0;
	$errMsg = '';
	
	try {
		
		//依指定的訊息 ID 從Database 取出訊息的完整內容
		$sth = $db->prepare("select msg,
									msg_title,
									date_format(send_time, '%Y-%m-%d %H:%i:%s') send_time
						   	   from news
						  	  where news_id = :id");
		$sth->bindParam("id",$news_id,PDO::PARAM_INT);
		$sth->execute();
		$result = $sth->fetchAll();
		$data = $result[0];
		$msg = $data['msg'];
		$msg_title = $data['msg_title'];
		$send_time = $data['send_time'];
		
		if ( !$msg ) {
		
			$errCode = 1;
			$errMsg = "news_id = {$news_id} , no data found";
		
		} else {
		
			try {
					
				$db->beginTransaction();
					
				//更新已讀註記
				$sth = $db->prepare("update news
									set have_read = '1',
										read_time = DATE_ADD(CURRENT_TIMESTAMP,INTERVAL 8 HOUR)
								  where news_id = :id
						");
				$sth->bindParam("id",$news_id,PDO::PARAM_INT);
				$sth->execute();
					
				$db->commit();
					
			} catch (PDOException $err) {
					
				$db->rollback();
					
				//有錯誤的時候，不回傳message內容
				$msg = "";
					
				$errCode = $err->getCode();
				$errMsg = $err->getMessage();
		
			}
		
		}	//end if ( !$msg )
		
	} catch (PDOException $err) {
		
		$errCode = $err->getCode();
		$errMsg = $err->getMessage();
		
	}
	
	//close Database Connection
	$db = null;
	
	//回傳格式 => JSON
	$msgContent = array(
			'errCode'	=>	$errCode,
			'errMsg'	=>	$errMsg,
			'title'		=>	$msg_title,
			'sendTime'	=>	$send_time,
			'fullMsg'	=>	$msg
	);
	
	echo json_encode($msgContent);

?>