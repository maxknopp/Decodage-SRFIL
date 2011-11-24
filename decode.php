<?php
// Fonction permettant de faire des stats d'utilisation de la fonction décodage
function getUserIP() {
    if($_SERVER) {
        if($_SERVER['HTTP_X_FORWARDED_FOR']) $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
        elseif($_SERVER['HTTP_CLIENT_IP']) $ip = $_SERVER['HTTP_CLIENT_IP'];
        else $ip = $_SERVER['REMOTE_ADDR'];
    }
    else {
        if(getenv('HTTP_X_FORWARDED_FOR')) $ip = getenv('HTTP_X_FORWARDED_FOR');
        elseif(getenv('HTTP_CLIENT_IP')) $ip = getenv('HTTP_CLIENT_IP');
        else $ip = getenv('REMOTE_ADDR');
    }
    return ($ip);
}

function countryCityFromIP($ipAddr)
{
	//verify the IP address for the
	ip2long($ipAddr)== -1 || ip2long($ipAddr) === false ? trigger_error("Invalid IP", E_USER_ERROR) : "";
	$ipDetail=array(); //initialize a blank array

	//get the XML result from hostip.info
	$xml = file_get_contents("http://api.hostip.info/?ip=".$ipAddr);

	//get the city name inside the node <gml:name> and </gml:name>
	preg_match("@<Hostip>.*<gml:name>(.*?)</gml\:name>@si",$xml,$match);

	//assing the city name to the array
	$ipDetail['city']=$match[1]; 

	//get the country name inside the node <countryName> and </countryName>
	preg_match("@<countryName>(.*?)</countryName>@si",$xml,$matches);

	//assign the country name to the $ipDetail array
	$ipDetail['country']=$matches[1];

	//get the country name inside the node <countryName> and </countryName>
	preg_match("@<countryAbbrev>(.*?)</countryAbbrev>@si",$xml,$cc_match);
	$ipDetail['country_code']=$cc_match[1]; //assing the country code to array

	//return the array containing city, country and country code
	return $ipDetail;
}

function statvisite($logfile)
{
	$date=date('d/m/Y');
	$heure=date('H:i:s');
	$dossier="visites";
	$fichier="stats_visites.txt";
	$visiteur=getUserIP();  
	$nomvisiteur=gethostbyaddr($visiteur);
	$IPDetail=countryCityFromIP($visiteur);
	$pathfile=$dossier."/".$fichier;
	$fp=fopen($pathfile,"a");
	$string=$date.";".$heure.";".$visiteur.";".$nomvisiteur.";".$IPDetail['country'].";".$IPDetail['city'].";".$logfile."\n";
	fwrite($fp,$string);
	fclose($fp);
}


// Supression des fichiers ayant plus de 1 jour dans le répertoire log/
$folder = new DirectoryIterator('log/');
foreach($folder as $file)
	if($file->isFile() && !$file->isDot() && (time() - $file->getMTime() > 86400) && $file->getFilename != "index.html")
		unlink($file->getPathname());

// Supression des fichiers ayant plus de 1 jour dans le répertoire res/
$folder = new DirectoryIterator('res/');
	foreach($folder as $file)
		if($file->isFile() && !$file->isDot() && (time() - $file->getMTime() > 86400) && $file->getFilename != "index.html")
			unlink($file->getPathname());

// test de la variable file
if (isset($_GET['file']))
{
	if ( empty($_GET['file']))
	{
		$go = 0;
	}
	else if ( $_GET['file'] == '.')
	{
		$go = 0;
	}
	else
	{
    $go = 1;
	}
}
else
{
	$go = 0;
}

if ($go == 1)
{
	$f=$_GET['file'];
	$logfile=escapeshellcmd($f);
	
	// Test si le nom de fichier contient ".."
    // interdit l'utilisation des nom de fichier du type ../../toto.txt
    if( strpos($logfile,'..') !== false )
    {
    	echo "srfil.php?res=erreur";
    }
    else
    {
      // test si le nom de fichier contient un espace
	    // si Oui, on remplace les espaces par des "_"
    	// Le script uploadify converti les espace en "_" lors de l'enregistrement du fichier sur le serveur
    	// mais le nom de fichier qu'il retourne contient toujours les espaces.
    	
   	 	if( strpos($logfile,' ',1) )
    	{
      		$logfile=str_replace(' ','_',$logfile);
    	}

      // change le groupe du fichier (gestion des log pour le user admin du serveur)
      
    	// --------------
    	// Calcul du nom de fichier xml: on elève l'extention et on la remplace par ".xml"
    
    	// récupération de l'exention du fichier: on extrait la dernière chaine après un "."
    	$longext = strlen(strrchr($logfile,'.'));
    
    	if ($longext < 6 && $longext != 0)
    	{
      		$longueur_chaine=strlen($logfile);
      		$xmlfile=substr($logfile, 0, $longueur_chaine - $longext).".xml";
    	}
    	else
    	{
      		$xmlfile=$logfile.".xml";
    	}	

    	// Execution du script perl pour le décodage du log srfil
    	$fileinfo = finfo_open(FILEINFO_MIME_TYPE);

    	if ( file_exists("./log/".$logfile) && strpos(finfo_file($fileinfo,"./log/".$logfile),'text') !==false )
    	{
					statvisite($logfile);
      		exec("perl srfil.pl ./log/".$logfile." ./res/".$xmlfile." >/dev/null 2>&1", $output);
      		chmod ( "./res/".$xmlfile, 0666 );
      		echo "srfil.php?file=".$xmlfile."&orig=".$logfile;
			}
		else
		{
			echo "srfil.php?res=erreur";
		}
	}
}
else
{
	echo "srfil.php?res=erreur";
}

?>
