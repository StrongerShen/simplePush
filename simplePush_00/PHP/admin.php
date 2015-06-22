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
	2015/06/22	Samma	1、改寫為mvc處理架構
 ==============================
 */
?>

<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <title>News Push</title>
  <script type="text/javascript" src="jquery/jquery-1.9.1.min.js"></script>
  <script type="text/javascript">
    $(document).ready( initChkbox );

    function initChkbox() {

      //如果本支程式以 HTML 存檔，URL 會以 FILE 開頭，變成不同網域存取而限制，無法取回 JSON 資料，因此存為 PHP 檔
      $.ajax({
        url:    "getUserList.php",
        type:   "post",
        dataType: "json",
        success:  function( result ) {
          var chk_box = "";
          var chkID = "";
          var cnt = 0;
          for(var i in result) {
            chkID = "CheckboxGroup1_" + cnt;
            chk_box = chk_box.concat("<label><input type='checkbox' name='list[]' value='" + result[i]["member_id"] + "' id='" + chkID + "' />" + result[i]["member_id"] + " " + result[i]["member_name"] + "</label><br />");
            cnt ++;
          }
          $("#chk_box").html(chk_box);
        },
        error:    function(  result ) {
          
          alert("ajax execute error => " + result.statusText );
        }
      });

    }
    
  </script>
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

