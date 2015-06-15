<?php
require_once("connectsql.php");
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Admin push</title>
</head>

<body>
<form id="form1" name="form1" method="post" action="SimplePush.php">
  <p>
    <label for="msg">Message</label>
    <input type="text" name="msg" id="msg" />
  </p>
  <p>
    <label for="device_token">device token</label>
    <select name="device_token" id="device_token">
<?php
$sql="select device_token,member_name,member_id from users order by member_id";
$result=mysql_query($sql,$link);
while($post=mysql_fetch_assoc($result)){
	//if ($post[0]) 
	{
		$deviceToken = $post['device_token'];
		$member_name = $post['member_name'];
		$member_id = $post['member_id'];
		echo "<option value=$member_id>$member_name</option>";
	}
}
	
?>
    </select>
  </p>
  <p>&nbsp;</p>
  <p>

<?php
$sql="select device_token,member_name,member_id from users order by member_id";
$result=mysql_query($sql,$link);
$i=1;
while($post=mysql_fetch_assoc($result)){
	//if ($post[0]) 
	{
		$deviceToken = $post['device_token'];
		$member_name = $post['member_name'];
		$member_id = $post['member_id'];
		$chkID = "CheckboxGroup1_" . $i;
		$i++;
		echo "<label><input type='checkbox' name='list[]' value='$member_id' id='$chkID' />$member_name</label><br />";
	}
}
?>
  </p>
  <p>
    <input type="submit" name="Submit" id="button" value="Send" />
  </p>
</form>
</body>
</html>
