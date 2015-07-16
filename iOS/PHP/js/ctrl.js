/*
 ==============================
    功能說明 : 搭配 index.php 的 Control 部份
    建立者 	: Samma
    建立日期 : 2015/06/22
    異動記錄 :
	2015/06/30	Samma	1、增加全選 & 取消全選功能
	2015/07/15	Samma	1、增加dataCheck()，用於表單送出前的資料檢查
 ==============================
 */

$(document).ready( initChkbox );

function initChkbox() {

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
  
  //radioButton 事件掛載
  initRadio();

}

function initRadio () {
	$("#choiceSelect").on("change",fn_selectAll);
	$("#choiceCancel").on("change",fn_cancelSelectAll);
}

function fn_selectAll() {
	//選擇全部的checkbox
	for(var i=0; i<$("input[name='list[]']").length; i++) {
		$("#CheckboxGroup1_"+i).prop("checked","checked");
	}
}

function fn_cancelSelectAll () {
	//取消選擇全部的checkbox
	for(var i=0; i<$("input[name='list[]']").length; i++) {
		$("#CheckboxGroup1_"+i).removeAttr("checked");
	}
}

function dataCheck() {
	
	//檢查msgTitle是否有輸入資料
	var msgTitle = $("#msgTitle").val();
	if( msgTitle.length <= 0) {
		alert("News Broadcast Title 尚未輸入");
		return false;
	}
	
	//檢查msg是否有輸入資料
	var msg = $("#msg").val();
	if( msg.length <= 0) {
		alert("News Broadcast Content 尚未輸入");
		return false;
	}
	
	//檢查是否至少有選擇一個推播對象
	var cnt = 0;
	for(var i=0; i<$("input[name='list[]']").length; i++) {
		if( $("#CheckboxGroup1_"+i).prop("checked") ){
			cnt++;
		}
	}
	if ( cnt <= 0 ) {
		alert("請至少選擇一個推播對象");
		return false;
	}
	
	return true;
	
}