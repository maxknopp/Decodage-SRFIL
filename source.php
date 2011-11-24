<?php

header('Content-Type: text/html;charset=UTF-8');

if (isset($_GET['file']))
{
	if ( ! empty($_GET['file']) )
	{
		if ( file_exists("./log/".$_GET['file']) && strpos($_GET['file'],'..') === false )
		{
			$file = $_GET['file'];
		}
	}
}

echo '<?xml version="1.0" encoding="UTF-8"?>';

?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"  dir="ltr" lang="fr-FR">
<head>
  <title>Décodage SRFIL</title>
  <link rel="shortcut icon" href="favicon.ico" />
  <link rel="stylesheet" href="style.css" type="text/css"/>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>

<body style="width: 630px">
  <div id="source">

<?php

if (isset($file))
{
    $fileinfo = finfo_open(FILEINFO_MIME_TYPE);
    if ( strpos(finfo_file($fileinfo,"./log/".$file),'text') !==false)
    {
        $raw = file("./log/".$file) or die("cannot open file");
        $data = join('',$raw);
        $html = nl2br($data);
        echo '<p>'.$html.'</p>';
    }
}
?>
  </div>
</body>

</html>