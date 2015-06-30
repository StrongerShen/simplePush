/*
 ==============================
    功能說明 : 搭配 index.php 的 Control 部份
    建立者 	: Samma
    建立日期 : 2015/06/22
    異動記錄 :
	2015/06/30	Samma	1、增加全選 & 取消全選功能
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