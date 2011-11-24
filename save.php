<?php
$content = htmlentities($_POST['message'],ENT_QUOTES,'UTF-8');
if ( $content != "" )
{
	$date = date("Y-m-d-H-i-s");
	$filename = "SRFIL_".$date.".log";
	$file = "log/".$filename;
	$Saved_File = fopen($file, 'w');
	fwrite($Saved_File, $content);
	fclose($Saved_File);
	chmod ( $file, 0666 );
	$result = 1;
	$url = "decode.php?file=".$filename;
}
else
{
	$result = 0;
}
?>

<script language="javascript" type="text/javascript">
	window.top.window.textDecode(<?php echo $result.",'".$url."'";?>);
</script>   