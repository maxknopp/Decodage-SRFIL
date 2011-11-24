<?php

header('Content-Type: text/html;charset=UTF-8');
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

<body>
  <div id="header">
    <h1><a href='http://srfil.maxk.fr'>Décodage SRFIL</a></h1>
		<h2>Historique des décodages</h2>
	</div>		
  <div id="content">
    <div id="entete">
			<div class="date">Date</div>
			<div class="heure">Heure</div>
			<div class="ip">Adresse IP</div>
			<div class="host">Hostname</div>
			<div class="pays">Pays</div>
			<div class="ville">Ville</div>
			<div class="log">Fichier de log</div>										
		</div>		
<?php
$row = 1;
$fichier = "./visites//stats_visites.txt";
if (file_exists($fichier))
{
	if (($handle = fopen($fichier, "r")) !== FALSE) {
    while (($data = fgetcsv($handle, 1000, ";")) !== FALSE) {
        $num = count($data);
        $row++;
        echo '<div class="visite">';
        	if ( $data[0] != "" )
        	{
        		echo '<div class="date">'.$data[0].'</div>';
        	}
        	else
        	{
        		echo '<div class="date">&nbsp;</div>';
        	}
        	if ( $data[1] != "" )
        	{
						echo '<div class="heure">'.$data[1].'</div>';
					}
        	else
        	{
        		echo '<div class="heure">&nbsp;</div>';
        	}						
					if ( $data[2] != "" )
        	{
						echo '<div class="ip">'.$data[2].'</div>';
					}
        	else
        	{
        		echo '<div class="ip">&nbsp;</div>';
        	}						
					if ( $data[3] != "" )
        	{
						echo '<div class="host">'.$data[3].'</div>';
					}
        	else
        	{
        		echo '<div class="host">&nbsp;</div>';
        	}						
					if ( $data[4] != "" && $data[4] != "(Unknown Country?)" )
        	{
						echo '<div class="pays">'.$data[4].'</div>';
					}
        	else
        	{
        		echo '<div class="pays">&nbsp;</div>';
        	}						
					if ( $data[5] != "" && $data[5] != "(Unknown City?)")
        	{
						echo '<div class="ville">'.$data[5].'</div>';
					}
        	else
        	{
        		echo '<div class="ville">&nbsp;</div>';
        	}						
					if ( $data[6] != "" )
        	{
        		
        		if (file_exists("./log/".$data[6]))
    				{
    					$filelog = $data[6];
    					
    					$length = strlen(strrchr($filelog,'.'));
    					if ($length < 6 && $length != 0)
    					{
      					$longueur_chaine=strlen($filelog);
      					$filexml=substr($filelog, 0, $longueur_chaine - $length).".xml";
    					}
    					else
    					{
      					$filexml=$filelog.".xml";
    					}
    					$url = "srfil.php?file=".$filexml."&orig=".$filelog;
    					
      				echo '<div class="log"><a href="'.$url.'">'.$filelog.'</a></div>';
      				//echo 'srfil.php?file='.file;
      				
      				//echo '\',\'log\',\'width=650,height=700,resizable=yes,menubar=no,location=no,status=no,directories=no,scrollbars=yes\')">';
      				//echo $data[6];
      				//echo '</a></div>';
    				}
    				else
    				{
       				echo '<div class="log">'.$data[6].'</div>';
    				}       		
					}
        	else
        	{
        		echo '<div class="log">&nbsp;</div>';
        	}						
        echo '</div>';
    }
    fclose($handle);
	}
}
?>  
  
  
  </div>
  
</body>

</html>
