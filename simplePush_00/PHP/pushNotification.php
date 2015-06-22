<?php
/*
 ==============================
    功能說明 : 	存檔：將推播相關訊息存入資料庫(Table `news`)
                推播：製作推播內容，與 APNS 建立連線，並傳送至 APNS，發出推播給 users

    Input  =>	(array)     lists       :	推播對象與對象的 Member Id([0] device_token ; [1] member_id)
                (string)    message     :   推播訊息
    Output =>   (resource)  fp          :   與 APNS push server (development) 建立連線
	 			(string)    msg	    :	推播 command 1 的格式
                                        // The enhanced notification format
                                        $msg = chr(1)                       // command (1 byte)
                                             . pack('N', $messageId)        // identifier (4 bytes)
                                             . pack('N', time() + 86400)    // expire after 1 day (4 bytes)
                                             . pack('n', 32)                // token length (2 bytes)
                                             . pack('H*', $deviceToken)     // device token (32 bytes)
                                             . pack('n', strlen($payload))  // payload length (2 bytes)
                                             . $payload;                    // the JSON payload
                // Table `news`
                (int)    seq_no	:	user 的流水號

    建立者 : James
    建立日期 : 2015/06/20
    異動記錄 :
    2015/06/20	James v1.0 實作推播功能與計算未讀訊息，以及推播內容存入資料庫
    2015/06/21	James v1.1 重構程式
    2015/06/22	James v1.2 table `news` 欄位增加兩欄 `mem_No`, `seq_no`，所需的修改。

 ==============================
 */
try {
	require_once("connectsql.php");
	require_once("push_config.php");

	$obj = new APNS_Push($db,$push_config);
    $obj->start();

} catch (Exception $e) {
	echo ($e);
}

////////////////////////////////////////////////////////////////////////////////
class APNS_Push
{
    private $fp=NULL;
    private $db;
    private $push_server;
    private $certificate;
    private $passphrase;

    function __construct($db, $push_config)
    {
        $this->fp;
        $this->db = $db;
        $this->push_server = $push_config['development']['push_server'];
        $this->certificate = $push_config['development']['certificate'];
        $this->passphrase = $push_config['development']['passphrase'];
    }

    function start()
    {
        $this->connectToAPNS();

        // 取得推播對象的 device_token, mem_no
        $lists = $_POST["list"];
        $message = $_POST["msg"];

        // echo "$message</br>";
//         foreach($lists as $member_id){
//         	echo "checked: $member_id</br>";
//         }

        if ($lists && $message){
            foreach ($lists as $value) {
                $result = $this->db->prepare("SELECT device_token,mem_no FROM users WHERE member_id='$value' AND stop_push_mk = 0");
                $result->execute();
                $temp = $result->fetch();
//                echo $temp[0]."<br>".$temp[1]."<br>";
                    if ($temp && $temp[0] != NULL && $temp[1] != NULL) {
                        $this->insertDataBase($message, $temp[0], $temp[1]);
                        $this->sendNotification($message, $temp[0], $temp[1]);
                    }

            }
        }
        $this->disconnectFromAPNS();
    }

    // Open a connection to the APNS server
    function connectToAPNS()
    {
        $ctx = stream_context_create();
        stream_context_set_option($ctx, 'ssl', 'local_cert', $this->certificate);
        stream_context_set_option($ctx, 'ssl', 'passphrase', $this->passphrase);
        // Open a connection to the APNS server
        $this->fp = stream_socket_client(
            'ssl://' . $this->push_server, $err,
            $errstr, 60, STREAM_CLIENT_CONNECT | STREAM_CLIENT_PERSISTENT, $ctx);

        if (!$this->fp) exit("<p>Failed to connect: $err $errstr </p>");
        echo "<p>Connected to APNS</p>";
    }

    // Close the connection to the server
    function disconnectFromAPNS()
    {
        fclose($this->fp);
        $this->fp = NULL;
        echo "<p>Close connect with APNS</p>";
    }

        // 傳送推播內容至 APNS 給指定對象
	function sendNotification($message,$deviceToken,$memNo){
        // 取得 user 未讀訊息的 badgeNember 且 user 的 stop_push_mk 為0的對象(可推播對象)
        $result = $this->db->prepare("SELECT COUNT(seq_no) FROM news WHERE have_read = 0 AND mem_No = '$memNo'");
		$result->execute();
		$temp = $result->fetch();
		$badge = $temp[0];
		// Create the payload body
		$body['aps'] = array(
				'alert' => $message,
				'sound' => 'default',
				'badge' => (int)$badge
		);
		// Encode the payload as JSON
		$payload = json_encode($body);

		// Build the binary notification
		// $msg = chr(0). pack('n',32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;
		$id = time();
		$expire = time() + 600;//10 minutes
		if ($expire) {
			$msg = chr(1) . pack('N',$id) . pack('N',$expire) .pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;
		}

		// Send it to the server
		$fwresult = fwrite($this->fp, $msg, strlen($msg));

		if (!$fwresult)
			echo "Message not delivered.</br>";
		else
			echo "Message successfully delivered.</br>";
	}
    //存檔：將推播訊息存入資料表
	function insertDataBase($message,$deviceToken,$memNo){
        // 組成流水號 seq_no
        $result = $this->db->prepare("SELECT MAX(seq_no) FROM news WHERE mem_No = '$memNo'");
        $result->execute();
        $temp = $result->fetch();
        $seqNo = $temp[0];
        if ($seqNo==NULL){
            $seqNo = 0;
        }
        $seqNo++;
        // 寫入資料庫 table `news` mem_No & seq_no & device_token & msg
        $result = $this->db->prepare("INSERT INTO news (mem_No, seq_no, msg, device_token) VALUES (?, ?, ?, ?)");
        $result->execute(array($memNo, $seqNo, $message, $deviceToken));
        echo "inserDB1!<br>";
    }

}


