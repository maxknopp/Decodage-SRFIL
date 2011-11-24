<?php
   // Edit upload location here
   $destination_path = getcwd()."/log/";

   $result = 0;
   $filename = basename( $_FILES['myfile']['name']);
   $filename = str_replace(' ','_',$filename);
   $target_path = $destination_path . $filename;
   $url = "decode.php?file=".$filename;

   if(@move_uploaded_file($_FILES['myfile']['tmp_name'], $target_path)) {
      $result = 1;
      chmod ( $target_path, 0666 );
   }
   sleep(1);
?>

<script language="javascript" type="text/javascript">
	window.top.window.fileDecode(<?php echo $result.",'".$url."'";?>);
</script>   
