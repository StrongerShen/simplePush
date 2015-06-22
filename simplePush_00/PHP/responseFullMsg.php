<?php
	/*
	 ==============================
	 功能說明 : 依傳入的 news_id 回饋完整訊息
	 	Input  =>	news_id	:	訊息ID
	 	Output =>	errCode	:	錯誤代碼 (沒有錯誤時回傳0),
					errMsg	:	錯誤訊息,
					fullMsg	:	完整訊息
	 建立者 : Samma
	 建立日期 : 2015/06/17
	 異動記錄 :
	 2015/06/18	Samma	1、加入 transaction 控制
	 ==============================
	 */

	//connect database
	require_once('connectsql.php');

	//receive message id
	$news_id = $_POST['news_id'];
	//$news_id = '1001';
	
	//handle error
	$errCode = 0;
	$errMsg = '';
	
	//依指定的訊息 ID 從Database 取出訊息的完整內容
	$sth = $db->prepare("select msg from news where news_id = :id");
	$sth->bindParam("id",$news_id,PDO::PARAM_INT);
	$sth->execute();
	$result = $sth->fetchAll();
	$data = $result[0];
	$msg = $data['msg'];

	if ( !$msg ) {
		
		$errCode = 1;
		$errMsg = "news_id = {$news_id} , is data not found";
		
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
	
	//close Database Connection
	$db = null;
	
	//回傳格式 => JSON
	$msgContent = array(
			'errCode'	=>	$errCode,
			'errMsg'	=>	$errMsg,
			'fullMsg'	=>	$msg
	);
	
	echo json_encode($msgContent);

?>