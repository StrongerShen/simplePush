<?php
/*
==============================
	功能說明 : 	依傳入的 news_id 進行刪除
	Input	=>	news_id		:	新聞訊息 ID
 	Output	=>	ret_code	:	處理結果 (YES / NO)
 				ret_desc	:	處理結果說明
 				
 	建立者 	: Samma
 	建立日期 : 2015/07/09
 	異動記錄 :

 ==============================
 */

	//receive news_id
	$news_id = $_POST["news_id"];
	
	//return json init
	$response = array("ret_code"=>"", "ret_desc"=>"");
	
	//Database Connect
	require_once('connectsql.php');
	
	//delete handle start
	try {
			
		$result = $db->query("select *
								from news
							   where news_id = '$news_id'");
		
		//如果 news_id 不存在，返回錯誤
		if ($result->rowCount() <= 0 ) {
			
			$response["ret_code"] = "NO";
			$response["ret_desc"] = "news_id = ".$news_id.", no data found.";
			
		//delete data
		} else {
			
			try {
			
				$db->beginTransaction();
			
				//依指定的訊息 ID 刪除 database 內的資料
				$sth = $db->prepare("delete 
								  	   from news
									  where news_id = :id");
				$sth->bindParam("id",$news_id,PDO::PARAM_INT);
				$sth->execute();
			
				$response["ret_code"] = "YES";
			
				$db->commit();
			
			} catch (PDOException $err) {
			
				$db->rollback();
				$response["ret_code"] = "NO";
				$response["ret_desc"] = $err->getMessage();
			
			}
		}	//end if($result->rowCount() <= 0 )
		
	} catch (PDOException $err) {
		
		$response["ret_code"] = "NO";
		$response["ret_desc"] = $err->getMessage();
		
	}
	
	echo json_encode( $response );

?>