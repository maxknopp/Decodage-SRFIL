<?php

header('Content-Type: text/html;charset=UTF-8');


if (isset($_GET['file']))
{
	if ( empty($_GET['file']) )
	{
		$fichxml = "errorxml.xml";
	}
	else
	{
		if ( file_exists("./res/".$_GET['file']) && strpos($_GET['file'],'..') === false )
		{
			$fichxml = "res/".$_GET['file'];
		}
		else
		{
			$fichxml = "errorxml.xml";
		}
	}
}
else
{
	$fichxml = "errorxml.xml";
}  

if (isset($_GET['orig']))
{
	if ( empty($_GET['orig']) )
	{
		$source = "Nom de fichier source inconnu";
	}
	else
	{
		if ( file_exists("./log/".$_GET['orig']) && strpos($_GET['orig'],'..') === false )
		{
			$source = $_GET['orig'];
		}
		else if ( $_GET['orig'] == "erreur")
		{
			$source = $_GET['orig'];
		}
		else
		{
			$source = "Nom de fichier source inconnu";
		}
	}
}
else
{
	$source = "Nom de fichier source inconnu";
}  

if (isset($_GET['res']))
{
	$fichxml = "error.xml";
	$source = "Nom de fichier source inconnu";
}


echo '<?xml version="1.0" encoding="UTF-8"?>';

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"  dir="ltr" lang="fr-FR">
<head>
  <title>Décodage SRFIL</title>
  <link rel="shortcut icon" href="favicon.ico" />
  <link rel="stylesheet" href="style.css" type="text/css"/>
  <link rel="stylesheet" type="text/css" media="screen,projection" href="ui.totop.css" />
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <script type="text/javascript" src="srfil.js"></script>
	<script type="text/javascript" src="jquery-1.6.min.js"></script>
	<script type="text/javascript" src="easing.js"></script>
	<script type="text/javascript" src="jquery.ui.totop.js"></script>

	<script type="text/javascript">
		$(document).ready(function() { $().UItoTop({ easingType: 'easeOutQuart' });	});
	</script>
  
</head>

<body onload="init(<?php echo '\''.$fichxml.'\''; ?>)">
  <div id="header">
    <h1><a href='http://srfil.maxk.fr'>Décodage SRFIL  <span class="soustitre">Retour à l'accueil</span></a></h1>
    <?php
    if (file_exists("./log/".$source))
    {
      echo '<h2><a href="javascript:void(0)" onclick="window.open(\'';
      echo 'source.php?file='.$source;
      echo '\',\'log\',\'width=650,height=700,resizable=yes,menubar=no,location=no,status=no,directories=no,scrollbars=yes\')">';
      echo $source;
      echo '</a></h2>';
    }
    else
    {
       	echo '<h2>'.$source.'</h2>';
    }
    ?>
  </div>
  <div id="filtre">
    <form id="formfiltre" action="#" onsubmit="valider(<?php echo '\''.$fichxml.'\''; ?>);return false" onreset="Reset(<?php echo '\''.$fichxml.'\''; ?>);return false">
      <p>
        <label class="formsiglelb" for="sigle">Sigle</label>
        <input class="formsigle" type="text" name="sigle" value="" id="sigle" />
        <label class="formvaleurlb" for="valeur">Valeur</label>
        <input class="formvaleur"  type="text" name="valeur" value="" id="valeur"/>
        <input id="OKbouton" class="bouton" value="OK" type="submit"/>
        <input id="RESETbouton" class="bouton" type="reset" value="Reset"/>
      	<img class="aide" src="image/question.png" alt="Aide" onclick="see_bubble();"/>
      </p>
    </form>
    <div id="infobulle" style="display: none;">
    	<div class="titre">Aide à l'utilisation du filtre</div>
    	<div class="close"><img src="image/close.png" alt="fermer" onclick="javascript:kill_bubble();" /></div>
    	<div class="texte">
    		<p>Le système de filtrage ci-contre permet d'effectuer un filtrage de l'affichage des messages SRFIL sur la valeur ou la description d'un paramètre particulier (ex: evt, codm, etc..).</p>
    		<p>il est ansi possible d'afficher soit "que les messages qui correspondent au critère" soit "de ne pas afficher les messages qui correspondent au critère".</p>
    		<p>--------</p>
    		<p>Filtrer afin de n'afficher que les messages "evt=00" :</p>
    		<p>Mettre "evt" dans le champs "Sigle"<br />Mettre "00" dans le champs "Valeur"</p>
    		<p>--------</p>
    		<p>Filtrer afin de ne pas afficher les messages "codm=0000" (Requêtes RHM)&nbsp;:</p>
    		<p>Mettre "codm" dans le champs "Sigle"<br />Mettre "/0000" dans le champs "Valeur"</p>
    		<p>--------</p>
    		<p>Filtrer afin de ne pas afficher les messages liés a la station SMB7&nbsp;:</p>
    		<p>Mettre "am" dans le champs "Sigle"<br />Mettre "/SMB7" dans le champs "Valeur"</p>
    		<p>--------</p>
    		<p>Cliquer ensuite sur "OK" pour valider le filtrage ou "RESET" pour annuler le(s) filtrage(s)</p>
    		<p>Le système de filtrage permettant de ne pas afficher tel ou tel type de message peut être exécuté plusieurs fois de suite afin de filtrer successivement les messages désirés ou non</p>
    	</div>
    </div>
  </div>
  <div id="content">
  </div>
  
</body>

</html>