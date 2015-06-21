<?php
/*
 ==============================
    功能說明 : 	使用 Web 介面進行推播

    Input  =>	(string)    member_id   :	chechbox 勾選對象得到 member_id
                (string)    message     :   輸入推播訊息
    Output =>   (string)    member_id   :	送出推播對象的 member_id
                (string)    message     :   送出推播訊息
    建立者 : James
    建立日期 : 2015/06/18
    異動記錄 :

 ==============================
 */
require_once("connectsql.php");
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Admin push</title>
</head>

<body>
<form id="form1" name="form1" method="post" action="pushNotification.php">
  <p>
    <label for="msg">News Broadcast</label>
	<br/>
    <textarea rows="6" cols="50" name="msg" id="msg"></textarea>
  </p>
  <p>&nbsp;</p>
  <p>

<?php

	$result=$db->query("select device_token,member_name,member_id from users order by member_id");

	$i = 1;

	while($rows = $result->fetch()) {
	
		$deviceToken = $rows['device_token'];
		$member_name = $rows['member_name'];
		$member_id = $rows['member_id'];
		$chkID = "CheckboxGroup1_" . $i;
		$i++;
		
		echo "<label><input type='checkbox' name='list[]' value='$member_id' id='$chkID' />$member_id $member_name</label><br />";

	}
?>
  </p>
  <p>
    <input type="submit" name="Submit" id="button" value="Send" />
  </p>
</form>
</body>
</html>
