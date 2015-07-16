<?php
/*
 ==============================
    功能說明 : 使用 Web 介面進行推播
    建立者 	: James
    建立日期 : 2015/06/18
    異動記錄 :
	2015/06/22	Samma	1、改寫為mvc處理架構
						2、javascript 另外拆出，獨立為 js 檔
						3、更改檔名，由 admin.php 調整成 index.php，易識別為專案執行的第 1 支程式
	2015/06/30	Samma	1、增加全選、取消全選功能 => getUserList.js
						2、增加News Broadcast Title 欄位，原本的 News Broadcast 更名為 News Broadcast Content 
						3、增加重設按鈕
	2015/07/15	Samma	1、增加表單送出前資料檢查
	2015/07/16	Samma	1、調整 js 的檔名
 ==============================
 */
?>

<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <title>News Push</title>
  <script type="text/javascript" src="jquery/jquery-1.9.1.min.js"></script>
  <script type="text/javascript" src="js/ctrl.js"></script>
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
    <input type="submit" name="Submit" id="button" value="Send" />
    <input type="reset"/>
  </p>
</form>
</body>
</html>

