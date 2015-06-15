<?php
$link = mysql_connect("192.168.0.12","root","root") or exit (mysql_error());
mysql_query("set names utf8" );
if($link)
{
	mysql_select_db("userdbs",$link) or exit("...".mysql_error());
}
?>