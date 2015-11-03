<?php
$inID = $_GET["id"];
$money = intval($_GET["money"]);


$link = mysql_connect('127.0.0.1','root','root') or die('could not connect');
mysql_set_charset('utf8',$link);
mysql_select_db('bingGu') or die('could not select db!');

//here check the quest code

$query = 'select * from ticket where cardID="'.$inID.'"';
$result = mysql_query($query) or die('query faild:' . mysql_error());
if($row = mysql_fetch_array($result)){
  if($money == -1){
    $set_money_zero = 'update ticket set money=0 where cardID="'.$inID.'"';
    $result = mysql_query($set_money_zero) ;
  }else{
    $add_money = 'update ticket set money = money + '.$money.' where cardID="'.$inID.'"';
    $result = mysql_query($add_money) ;
  }
    $output = array(
      'validate' => 200,
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




