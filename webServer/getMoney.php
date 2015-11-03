<?php
$inID = $_GET["id"];

$link = mysql_connect('127.0.0.1','root','root') or die('could not connect');
mysql_set_charset('utf8',$link);
mysql_select_db('bingGu') or die('could not select db!');

//here check the quest code

$query = 'select * from ticket where cardID="'.$inID.'"';
$result = mysql_query($query) or die('query faild:' . mysql_error());
if($row = mysql_fetch_array($result)){
  
  $output = array(
    'validate' => 200,
    'money' => $row['money']
    );
  echo json_encode($output);
}else{
    $output = array(
    'validate' => 0,
    ); 
  echo json_encode($output);
}
mysql_free_result($result);
mysql_close($link);

?>


