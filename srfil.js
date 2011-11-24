// ****************************************************************
// Fonction permettant de vérifier si le navigateur supporte l'AJAX
// Elle alerte si le navigateur ne supporte pas cette fonctionnalité

function getXMLHttp()
{
	var xmlHttp
	try
	{
		//Firefox, Opera 8.0+, Safari
		xmlHttp = new XMLHttpRequest();
	}
	catch(e)
	{
		//Internet Explorer
		try
		{
			xmlHttp = new ActiveXObject("Msxml2.XMLHTTP");
		}
		catch(e)
		{
			try
			{
				xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
			}
			catch(e)
			{
				alert("Votre navigateur ne permet pas d'utiliser cet outil")
				return false;
			}
		}
	}
	return xmlHttp;
}

// **************************************************************
// Fonction d'affichage du fichier XML/XSLT résultant du décodage

function displayResult(file)
{
	document.getElementById("content").innerHTML='';
	wait = '<div class="wait">';
	wait += '<p class="waitimg"><img src="image/roue.gif" alt="wait" /></p>';
	wait += '</div>';
	document.getElementById("content").innerHTML=wait;

	xmlfile=file;
	xslfile="srfil.xsl";

	// Code pour Internet Explorer
	if (window.ActiveXObject)
	{
		var xslDoc;
		var xmlDoc;
		var xlt;
		var xslProc;
		
		// Chargement de la feuille XSLT
		xslDoc = new ActiveXObject("Msxml2.FreeThreadedDOMDocument.6.0");
		xslDoc.async = false;
		xslDoc.load(xslfile);

		//Chargement du document XML
		xmlDoc = new ActiveXObject("Msxml2.DOMDocument.6.0");
		xmlDoc.async = true;
		xmlDoc.onreadystatechange = function ()
		{
			if (xmlDoc.readyState == 4)
			{
				xslProc.transform();
				//Affichage du résultat
				document.getElementById("content").innerHTML='';
				document.getElementById("content").innerHTML=xslProc.output;
			}
		}

		//Transformation
		xslt = new ActiveXObject("Msxml2.XSLTemplate.6.0");
		xslt.stylesheet = xslDoc;
		xslProc = xslt.createProcessor();
		xslProc.input = xmlDoc;
		
		// chargement du fichier XML en asynchrone
		xmlDoc.load(xmlfile);
	}

	// Code pour les autres navigateurs supportant XSLTProcessor()
	else
	{
		var xslhttp = getXMLHttp();
		var xmlhttp = getXMLHttp();
		var xsl;
		var xml;

		xslhttp.onreadystatechange = function()
		{
			if(xslhttp.readyState == 4 && xslhttp.status == 200)
			{
				// On récupère le contenu du fichier xsl
				xsl = xslhttp.responseXML;
				xmlhttp.onreadystatechange = function()
				{
					if(xmlhttp.readyState == 4 && xmlhttp.status == 200)
					{
						// Traitement de l'affichage
						// *************************

						// On récupère le contenu du fichier xml
						xml = xmlhttp.responseXML;
						xsltProcessor=new XSLTProcessor();
						xsltProcessor.importStylesheet(xsl);
						// Rendu de l'affichage
						resultDocument = xsltProcessor.transformToFragment(xml,document);
						// Affichage dans la page web
						document.getElementById("content").innerHTML='';
						document.getElementById("content").appendChild(resultDocument);
						// ********************************
						// Fin de traitement de l'affichage
					}
				}
				xmlhttp.open("GET", xmlfile, true);
				xmlhttp.send();
			}
		}

		xslhttp.open("GET", xslfile, true);
		xslhttp.send();
	}
}

// *****************************************
// Validation du formulaire pour le filtrage
function valider(file)
{
	// si les données sont présentes on fourni les données de filtrage
	// au script de rendu
	if(document.getElementById('formfiltre').sigle.value != "" && document.getElementById('formfiltre').valeur.value != "")
	{
		if ( document.getElementById('formfiltre').valeur.value.charAt(0) == "/" )
		{
			var valeur = document.getElementById('formfiltre').valeur.value.substring(1);
			$('.warning').remove();
			hide_div_class(document.getElementById('formfiltre').sigle.value,valeur);
			
		}
		else
		{
			$('.warning').remove();
			show_div_class(document.getElementById('formfiltre').sigle.value,document.getElementById('formfiltre').valeur.value);
		}
	}
	
	// si il n'y a pas de donnée, on lance le rendu sans filtrage
	else if (document.getElementById('formfiltre').sigle.value == "" && document.getElementById('formfiltre').valeur.value == "")
	{
		$('.warning').remove();
		show_all_msg();
	}

	// si les données sont incomplètes, on stop et on averti l'utilisateur
	else if (document.getElementById('formfiltre').sigle.value == "" && document.getElementById('formfiltre').valeur.value != "")
	{
		hide_all_msg();
		$('.warning').remove();
		warning = '<div class="warning">';
		warning += '<p class="warnname">Les données renseignées dans le filtre sont incorrectes</p>';
		warning += '<p class="warndesc">Le nom dans le champs "Sigle" n\'a pas été renseignée</p>';
		warning += '<p class="warndesc">Cliquer sur "Reset" pour supprimer le filtrage</p>';
		warning += '</div>';
		$('#content').append(warning);
	}
	else if (document.getElementById('formfiltre').sigle.value != "" && document.getElementById('formfiltre').valeur.value == "")
	{
		hide_all_msg();
		$('.warning').remove();
		warning = '<div class="warning">';
		warning += '<p class="warnname">Les données renseignées dans le filtre sont incorrectes</p>';
		warning += '<p class="warndesc">La donnée dans le champs "Valeur" n\'a pas été renseignée</p>';
		warning += '<p class="warndesc">Cliquer sur "Reset" pour supprimer le filtrage</p>';
		warning += '</div>';
		$('#content').append(warning);
	}
	return false;
}

// **************************************************************
// Fonction d'effacement des données présentes dans le formulaire
function Reset(file)
{
	document.getElementById('formfiltre').sigle.value = "";
	document.getElementById('formfiltre').valeur.value = "";
	$('.warning').remove();
	show_all_msg();
	return false;
}

// *************************************************************
// Fonction de lancement de l'affichage au chargement de la page
function init(file)
{
	document.getElementById('formfiltre').sigle.value = "";
	document.getElementById('formfiltre').valeur.value = "";
	displayResult(file);
	return false;
}

// *****************************************
// Fonction de filtrage des messages

function hide_all_msg()
{
	$('.msg').css({display:'none'});
}

function show_all_msg()
{
	$('.msg').css({display:'block'});
}

function show_div_class(code_value,valeur_value)
{
	var ifsomehide = find_hide_class();
	//alert(ifsomehide);
	if ( ifsomehide == 0 )
	{
		hide_all_msg();
		
		$('.msg .info').each(function()
		{
			var codeTxt = $(this).find('.code').first().text();  
			var valeurTxt = $(this).find('.valeur').first().text();
			var descTxt = $(this).find('.desc').first().text();
			var reg = new RegExp(valeur_value);
			if ( codeTxt == code_value && valeurTxt == valeur_value || codeTxt == code_value && reg.test(descTxt))
			{
				$(this).parents('.msg').first().css({display:'block'});
			}
		});
	}
	else
	{
		$('.msg:visible').each(function()
		{
			$(this).css({display:'none'});
		$(this).find('.info').each(function()
		{
			var codeTxt = $(this).find('.code').first().text();  
			var valeurTxt = $(this).find('.valeur').first().text();
			var descTxt = $(this).find('.desc').first().text();
			var reg = new RegExp(valeur_value);
			if ( codeTxt == code_value && valeurTxt == valeur_value || codeTxt == code_value && reg.test(descTxt))
			{
				$(this).parents('.msg').first().css({display:'block'});
			}
		});
		
		});
		
	}

	find_div_class();
}

function hide_div_class(code_value,valeur_value)
{
	//show_all_msg();

	$('.msg .info').each(function()
	{  
		var codeTxt = $(this).find('.code').first().text();  
		var valeurTxt = $(this).find('.valeur').first().text();
		var descTxt = $(this).find('.desc').first().text();
		var reg = new RegExp(valeur_value);
		if ( codeTxt == code_value && valeurTxt == valeur_value || codeTxt == code_value && reg.test(descTxt))
		{
			$(this).parents('.msg').first().css({display:'none'});
		}
	}); 

	find_div_class();
}

function find_hide_class()
{
	var nbdisplay = 0;
	var nbmsg = 0;
	var somehide = 1;
	
	$('.msg').each(function()
	{
		nbmsg++;
		if ( $(this).css('display') != "none")
		{
			nbdisplay++;
		}
	});
	
	if ( nbmsg == nbdisplay && nbmsg != 0)
	{
		somehide = 0;
	}
	
	return somehide;
}

// *****************************************
// Fonction de comptage des messages masqués
function find_div_class()
{
	var nbnotdisplay = 0;
	var nbmsg = 0;
	
	$('.msg').each(function()
	{
		nbmsg++;
		if ( $(this).css('display') == "none")
		{
			nbnotdisplay++;
		}
	});
	
	if ( nbmsg == nbnotdisplay && nbmsg != 0)
	{
		warning = '<div class="warning">';
		warning += '<p class="warnname">Pas de message SRFIL trouvé</p>';
		warning += '<p class="warndesc">Veuillez vérifier les paramètres de filtrage "sigle" et "valeur"</p>';
		warning += '<p class="warndesc">Cliquer sur "Reset" pour supprimer le filtrage</p>';
		warning += '</div>';
		$('#content').append(warning);
	}
}

// *****************************************
// Fonctions d'affichage de l'aide du filtre

// affiche la bubble
function see_bubble()
{
	$('#infobulle').toggle();
}

// cache la bubble
function kill_bubble()
{
	$('#infobulle').toggle();
}

// *****************************************************
// Fonction d'envoi du SRFIL et de lancement du décodage

// Affichage de la roue lors de l'envoi d'un fichier de log
function fileUpload()
{
	document.getElementById('file_upload_send').style.visibility = 'visible';
	document.getElementById('file_upload').style.visibility = 'hidden';
	document.getElementById('file_upload_error').style.display = 'none';
	return true;
}

// Affichage de la roue lors de l'envoi d'un texte de log
function textUpload()
{
	document.getElementById('text_upload_send').style.visibility = 'visible';
	document.getElementById('text_upload').style.visibility = 'hidden';
	document.getElementById('text_upload_error').style.display = 'none';
	return true;
}

// Lancement du décodage du log (envoi de fichier) et affichage de la roue durant son execution
function fileDecode(success,url)
{
	var result = '';
	if (success == 1)
	{
		document.getElementById('file_upload_error').style.display = 'none';
		document.getElementById('file_upload_send').style.visibility = 'hidden';
		document.getElementById('file_upload_decode').style.visibility = 'visible';
		document.getElementById('file_upload').style.visibility = 'hidden';
		decode(url);
	}
	else
	{
		document.getElementById('file_upload_send').style.visibility = 'hidden';
		document.getElementById('file_upload_decode').style.visibility = 'hidden';
		document.getElementById('file_upload_error').style.display = 'block';
		document.getElementById('file_upload').style.visibility = 'visible';
	}
	return true;
}

// Lancement du décodage du log (envoi de texte) et affichage de la roue durant son execution
function textDecode(success,url)
{
	var result = '';
	if ( success == 1 )
	{
		document.getElementById('text_upload_send').style.visibility = 'hidden';
		document.getElementById('text_upload_decode').style.visibility = 'visible';
		document.getElementById('text_upload').style.visibility = 'hidden';
		document.getElementById('text_upload_error').style.display = 'none';
		decode(url);
	}
	else
	{
		document.getElementById('text_upload_send').style.visibility = 'hidden';
		document.getElementById('text_upload_decode').style.visibility = 'hidden';
		document.getElementById('text_upload_error').style.display = 'block';
		document.getElementById('text_upload').style.visibility = 'visible';
	}
	return true;
}

// Fonction AJAX lancant la commande de décodage du fichier
// de log SRFIL via le script "decode.php"
// Elle boucle en attendant la fin de l'execution du script php
// Lorsque le script est terminé, on est redirigé vers l'affichage
// du résultat

function decode(url)
{
	var requete = getXMLHttp();
	requete.onreadystatechange = function()
	{
		if(requete.readyState == 4 && requete.status == 200)
		{
			if ( /srfil\.php/.test(requete.responseText) )
			{
				window.location = requete.responseText;
			}
			return true;
		}
	}

	requete.open("GET", url, true);
	requete.send();
}