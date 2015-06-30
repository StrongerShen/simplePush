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