<?php
$lastID = $_GET["lastID"];

$link = mysql_connect('127.0.0.1','root','root') or die('could not connect');
mysql_set_charset('utf8',$link);
mysql_select_db('bingGu') or die('could not select db!');

$query = 'select * from ticket where cardID="'.$lastID.'"';
$result = mysql_query($query) or die('query faild:' . mysql_error());
if($row = mysql_fetch_array($result)){
  $eventID = $row["enentID"];
  $query = 'select * from event where eventID='.$eventID;
  $result = mysql_query($query) or die('query faild:' . mysql_error());
  if($row2 = mysql_fetch_array($result)){
  
    $output = array(
      'validate' => 200,
      'A' => $row2['A'],
      'B' => $row2['B'],
      'C' => $row2['C'],
      'D' => $row2['D'],
      'E' => $row2['E'],
      );
    echo json_encode($output);
  }else{
      $output = array(
      'validate' => 0,
      ); 
    echo json_encode($output);
  }
}else{
  $output = array(
    'validate' => 0,
  ); 
  echo json_encode($output);
}


mysql_free_result($result);
mysql_close($link);

?>








