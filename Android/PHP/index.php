<?php
/*
 ==============================
    功能說明 : 使用 Web 介面進行推播
    建立者 	: Samma
    建立日期 : 2015/07/04
    異動記錄 :
	2015/07/15	Samma	1、增加表單送出前資料檢查
 ==============================
 */
?>

<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <title>News Push</title>
  <script type="text/javascript" src="jquery/jquery-1.9.1.min.js"></script>
  <script type="text/javascript" src="js/getUserList.js"></script>
</head>

<body>
<form id="form1" name="form1" method="post" action="pushNotification.php" OnSubmit="return dataCheck();">
  <p>
  	<label for="msgTitle">News Broadcast Title</label>
  	<br/>
  	<input type="text" name="msgTitle" id="msgTitle" size=50/>
  </p>
  <p>
    <label for="msg">News Broadcast Content</label>
    <br/>
    <textarea rows="6" cols="50" name="msg" id="msg"></textarea>
  </p>
  <p>&nbsp;</p>

  <p>
  <div id="choiceAll">
  	<!-- value=1表示選取狀態，value=0表示未選取狀態 -->
  	<label><input type="radio" id="choiceSelect" name="choiceA">全選</label>
  	<label><input type="radio" id="choiceCancel" name="choiceA">取消全選</label>
  </div>
  </p>
  
  <div id="chk_box"></div>
  
  <p>
  	<input type="hidden" name="sendAll" id="sendAll" value="0" />
    <input type="submit" name="Submit" id="button" value="Send" />
    <input type="reset"/>
  </p>
</form>
</body>
</html>

