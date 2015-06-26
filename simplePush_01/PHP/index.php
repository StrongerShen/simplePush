<?php
/*
 ==============================
    功能說明 : 	使用 Web 介面進行推播
    建立者 : James
    建立日期 : 2015/06/18
    異動記錄 :
	2015/06/22	Samma	1、改寫為mvc處理架構
						2、javascript 另外拆出，獨立為 js 檔
						3、更改檔名，由 admin.php 調整成 index.php，易識別為專案執行的第 1 支程式
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
<form id="form1" name="form1" method="post" action="pushNotification.php">
  <p>
    <label for="msg">News Broadcast</label>
    <br/>
    <textarea rows="6" cols="50" name="msg" id="msg"></textarea>
  </p>
  <p>&nbsp;</p>

  <div id="chk_box"></div>
  
  <p>
    <input type="submit" name="Submit" id="button" value="Send" />
  </p>
</form>
</body>
</html>

