#! /usr/bin/perl -w

# *************************************************************
# Script d'analyse des messages SRFIL v2.0
# -----------------------------------------
#
# Ce script analyse les messages SRFIL edités en mode débug via
# SRFIL,DBG=H'F':.......
#
# Ce script nécéssite que le dictionnaire (SFRL_dic.xml) soit
# Présent dans le même répertoire que ce script
#
# Le lancement de ce script est simple:
# perl srfil.pl [fichier de log SRFIL]
#
# Le programme consiste en une séquence de chargement du dictionnaire
# Une lecture du fichier de log et son stockage dans un tableau
# L'extraction de chaque messages SRFIL
# Une fonction est alors appelée pour le décodage du message
#
# *************************************************************

use XML::Simple;
use XML::Writer;
use IO::File;
use Data::Dumper;
use Text::Wrap;
use strict;
use warnings;
use utf8;


#ActiverAccentDOS();

################################################################################
# Début du programme principal

# Déclaration et définition des variables globales
my $xmldic;
my $fichier;
my $fichiersortie;
my $fichiersortiexml;
my $ligne;
my @log;
my @msgtmp;
my $dic      = "SRFIL_dic.xml";
my $cpt      = 0;
my $cptmsg   = 0;
my $msg      = "";
my $cptline  = 1;

# Initialisation des variables et vérification des arguments
if (defined $ARGV[0])
{
    if ( $ARGV[0] eq "-h" || $ARGV[0] eq "--help" )
    {
        print "**************************************************************\n";
        print " Script d'analyse des messages SRFIL v1.50\n";
        print " -----------------------------------------\n\n";
        print " Ce script analyse les messages SRFIL edités en mode débug via\n";
        print " la commande : SRFIL,DBG=H'F':.......\n\n";
        print " Ce script nécéssite que le dictionnaire (SFRL_dic.xml) soit\n";
        print " Présent dans le même répertoire que ce script\n\n";
        print " Le lancement de ce script est simple:\n";
        print " perl srfil.pl [fichier de log SRFIL]\n\n";
        print " Le programme consiste a:\n";
        print "  - Charger le fichier dictionnaire (SRFIL_dic.xml)\n";
        print "  - Lire le fichier de log SRFIL et le stocker dans un tableau\n";
        print "  - Extraire de chaque messages SRFIL\n";
        print "  - Une fonction est alors appelée pour le décodage du message\n\n";
        print " Dans certains cas, il sera demandé de se reporter à la\n";
        print " documentation : Recueil des messages SRFIL (RECSRFIL)\n";
        print " Ref: 3BW 60437 AAAA RKAHB Ed04 Fr\n\n";
        print " **************************************************************\n";
        exit 1;
    }
    else
    {
        $fichier = $ARGV[0];
    }
}
else
{
    print "Aucun fichier donné en argument\n";
    exit 1;
}

# Vérification de l'existance des fichiers dictionnaire et fichier de log
if ( ! -e $dic )
{
    print "Le dictionnaire SRFIL \"SRFIL_dic.xml\" est introuvable\n";
    exit 1;
}

if ( ! -e $fichier )
{
    print "Le fichier de log indiqué ($fichier) n'existe pas ou est introuvable\n";
    exit 1;
}


# Ouverture du fichier de log SRFIL
open(FILE, "<$fichier")
  or die "Impossible d'ouvrir le fichier $!";

# Création du fichier de sortie on change son extention en ".res"
$fichiersortiexml    = $ARGV[1];

# Ouverture du fichier de sortie en écriture
my $output = new IO::File(">$fichiersortiexml");
my $outxml = new XML::Writer(OUTPUT => $output, NEWLINE => 1, DATA_MODE => 'true', DATA_INDENT => 2, ENCODING => 'utf-8');

# Entête du fichier XML de sortie
$outxml->xmlDecl('UTF-8');
$outxml->startTag('srfil');


# Chargement du fichier dictionnaire avec définition des clés
$xmldic = XMLin(
                $dic,
                KeyAttr => {
                            evt       => "code",
                            as        => "code",
                            ap        => "code",
                            etac      => "code",
                            nivs      => "code",
                            etas      => "code",
                            iac       => "code",
                            posp      => "code",
                            codm      => "code",
                            tyrq      => "code",
                            etad      => "code",
                            tych      => "code",
                            tychloc   => "code",
                            conf      => "code",
                            tyac      => "code",
                            ctrr      => "code",
                            vrsy      => "code",
                            crdp      => "code",
                            tyfm      => "code",
                            sec       => "code",
                            caus      => "code",
                            pare0     => "code",
                            pare1     => "code",
                            pdia      => "code",
                            ft        => "code",
                            numano    => "code",
                            info      => "code",
                            etch      => "code",
                            causi     => "code",
                            typa      => "code",
                            port      => "code",
                            etace     => "code",
                            setat     => "code",
                            tyre      => "code",
                            idmu      => "code",
                            form      => "code",
                            icmat     => "code",
                            icmatsmb  => "code",
                            tyml      => "code",
                            sad       => "code",
                            vect      => "code",
                            exlo      => "code",
                            ndch      => "code",
                            evch      => "code",
                            posptu    => "code",
                            etatpu    => "code",
                            type      => "code",
                            phad      => "code",
                            coco      => "code",
                            icom0     => "code",
                            opti      => "code",
                            swidft    => "code",
                            codi      => "code",
                            typt      => "code",
                            itype     => "code",
                            nbrah     => "code",
                            sfadrgad  => "code",
                            cinc      => "code",
                            typf      => "code",
                            mpcc      => "code",
                            cchg      => "code",
                            orig      => "code"
                           }
               );


# Lecture du fichier de log SRFIL et stockage de celui-ci dans un tableau
while ($ligne = <FILE>)
{
    chomp($ligne);

    #suppression des espace en début et fin de chaine
    $ligne =~ s/^\s+|\s+$//g;
    if (   $ligne !~ m/^$/
        && $ligne !~ m/LISTAGE SURETE DE FONCTIONNEMENT/)
    {
        $log[$cpt] = $ligne;
        $cpt = $cpt + 1;
    }
}

# Fermeture du fichier de log SRFIL
close FILE;

# Lecture du tableau et extraction des messages SRFIL
# A chaque message trouvé on l'analyse puis on passe au
# message suivant
for (my $i = 0 ; $i < $cpt ; $i++)
{
    $Text::Wrap::columns   = 48;
    $Text::Wrap::separator = "\n";

    # Test si début de message
    if ($log[$i] =~ m/^\d\d-\d\d-\d\d\/\d\d H \d\d MN \d\d/)
    {
        $outxml->startTag('msg', 'num' => $cptmsg+1);
        $outxml->startTag('msgbrut');
        $outxml->startTag('nom');
        $outxml->characters('Message SRFIL');
        $outxml->endTag('nom');
        $outxml->startTag('valeur');
        $outxml->startTag('line','num' => $cptline);
        $outxml->characters($log [$i]);
        $outxml->endTag('line');
        $cptline = $cptline + 1;
    }

    # Test si la ligne donne le nom de la station
    elsif (	  $log[$i] =~ m/\/AM = / 
    	   && $cptline > 1)
    {
        $outxml->startTag('line','num' => $cptline);
        $outxml->characters($log [$i]);
        $outxml->endTag('line');
        $cptline = $cptline + 1;
    }

    # Test si la ligne contient un partie du message
    elsif (   $log[$i]      =~ m/\/ ../
           && $i < $cpt - 1
           && $log[$i + 1]  =~ m/\/ ../
           && $cptline > 1)
    {
        $msg = $msg . $log[$i];
        $outxml->startTag('line','num' => $cptline);
        $outxml->characters($log [$i]);
        $outxml->endTag('line');
        $cptline = $cptline + 1;
    }

    # Test si la ligne contient la dernière ligne du message
    # Si oui on l'analyse
    elsif (   $log[$i] =~ m/\/ ../ && $i == $cpt - 1 && $cptline > 1
           || $log[$i] =~ m/\/ ../ && $log[$i + 1] !~ m/\/ ../ && $cptline > 1)
    {
        $msg = $msg . $log[$i];
        $msg =~ s/\/\s//g;
        $msg =~ s/\s//g;
        $outxml->startTag('line','num' => $cptline);
        $outxml->characters($log[$i]);
        $outxml->endTag('line');
        $cptline = 1;
        $outxml->endTag('valeur');
        $outxml->endTag('msgbrut');

        # Analyse du message SRFIL
        $outxml->startTag('msgdecode');
        analysesrfil($msg);
        $outxml->endTag('msgdecode'); # End Decode
        $outxml->endTag('msg'); # End msg

        # Fin de l'analyse on efface le message pour passer au suivant
        $msg = "";
        $cptmsg = $cptmsg + 1;
    }
}

if ( $cptmsg == 0 )
{
    printxmlwarn("nolog","Pas de message SRFIL trouvé", "Aucun message SRFIL DBG n'a été détecté dans le fichier de log indiqué","Vérifiez que la commande SRFIL a été éxécuté avec l'option DBG=H'F' (exemple: SRFIL,DBG=H'F':DD-10-12-03;)");
}

$outxml->endTag('srfil'); # End srfil
$outxml->end();   # End XML File
$output->close;   # Close XML file

# Fin du programme principal
################################################################################

################################################################################
# Fonction d'analyse du début des messages SRFIL
sub analysesrfil
{
    my $msg = $_[0];
    my $evtdesc;
    my $annee;
    my $mois;
    my $jour;
    my $heure;
    my $minute;
    my $seconde;
    my $adrml;
    my $etat;
    my $texte;
    my $cptml = 0;

    # ---------------------------------------------------------
    # Selon l'évenement on décode la première partie du message

    if (   hex(substr($msg,2,2)) == 24
        || hex(substr($msg,2,2)) == 34)
    {
        printxml("evt","Evènement",hex(substr($msg,2,2)),$xmldic->{evenement}->{evt}->{hex(substr($msg,2,2))}->{desc});
        printxml("date","Date",substr($msg,8,2)."/".substr($msg,6,2)."/20".substr($msg,4,2));
        printxml("heure","Heure",substr($msg,10,2).":".substr($msg,12,2).":".substr($msg,14,2));
        printxml("nivs","Niveau de fonctionnement du système",substr($msg, 46, 2),$xmldic->{ni}->{nivs}->{substr($msg, 46, 2)}->{desc});
        printxml("etas","Etat système",substr($msg, 48, 1),$xmldic->{es}->{etas}->{substr($msg, 48, 1)}->{desc});
        printxml("iac","Indicateur d'avancement",substr($msg, 49, 1),$xmldic->{es}->{etas}->{substr($msg, 48, 1)}->{iac}->{substr($msg, 49, 1)}->{desc});

        # Lancement de la fonction de décodage des infos complémentaires
        infocomp($msg);
    }
    else
    {
        if ( hex(substr($msg,2,2)) =~ m/^\d$/ )
        {
            printxml("evt","Evènement","0".hex(substr($msg,2,2)),$xmldic->{evenement}->{evt}->{hex(substr($msg,2,2))}->{desc});
        }
        else
        {
            printxml("evt","Evènement",hex(substr($msg,2,2)),$xmldic->{evenement}->{evt}->{hex(substr($msg,2,2))}->{desc});
        }
        printxml("date","Date",substr($msg,8,2)."/".substr($msg,6,2)."/20".substr($msg,4,2));
        printxml("heure","Heure",substr($msg,10,2).":".substr($msg,12,2).":".substr($msg,14,2));

        $outxml->startTag('info','sigle' => "am");
        $outxml->startTag('code');
        $outxml->characters("am");
        $outxml->endTag('code'); # End Code
        $outxml->startTag('nom');
        $outxml->characters("Station");
        $outxml->endTag('nom'); # End Nom
        $outxml->startTag('valeur');
        if (substr($msg, 16, 4))
        {
            $outxml->characters(substr($msg, 16, 4));
        }
        else
        {
            $outxml->characters("N/A");
        }
        $outxml->endTag('valeur'); # End Valeur
        if ($xmldic->{asml}->{as}->{substr($msg, 17, 3)}->{desc})
        {
            $outxml->startTag('desc');
            $outxml->characters($xmldic->{asml}->{as}->{substr($msg, 17, 3)}->{desc});
            $outxml->endTag('desc'); # End Desc
        }

        
        
        
        
        #printxml("am","Station",substr($msg, 16, 4),$xmldic->{asml}->{as}->{substr($msg, 17, 3)}->{desc});
        
        # Si présence adresses ML
        if ( substr($msg,21,3) ne "000")
        {
            $outxml->startTag('listeml');
            $outxml->startTag('nom');
            $outxml->characters('Liste des ML');
            $outxml->endTag('nom');
            $outxml->startTag('desc');
            $outxml->characters('Liste des ML supportées par la station avant l\'évènement');
            $outxml->endTag('desc');
            if (substr($msg, 20, 1) == 0)
            {
                for (my $i = 20 ; $i < 48 ; $i = $i + 4)
                {
                    if ( substr($msg,$i,4) ne "0000" )
                    {
                        $cptml = $cptml + 1;
                        printxmlnum("af",$cptml,"Adresse fonctionnelle de la ML",substr($msg,$i,4),$xmldic->{asml}->{as}->{substr($msg, $i+1, 3)}->{desc});
                    }
                }
            }
            else
            {
                printxml("af","ML","N/A","La station supporte plus de 8ML, Voir l'enregistrement " . substr($msg, 21, 3) . " du fichier FELML de l'archive ZSM pour le détail");
            }
            $outxml->endTag('listeml');
        }
        $outxml->endTag('info');# End Info

        if ( $xmldic->{asml}->{as}->{substr($msg, 17, 3)}->{desc} && $xmldic->{asml}->{as}->{substr($msg, 17, 3)}->{desc} =~ m/SM/ )
        {
            printxml("posp","Positionnement primaire",substr($msg,48,1),$xmldic->{pe}->{posp}->{substr($msg, 48, 1)}->{desc});
            printxml("etac","Etat courant",substr($msg, 49, 1),$xmldic->{pe}->{etac}->{substr($msg, 49, 1)}->{desc});
        }
        elsif ( $xmldic->{asml}->{as}->{substr($msg, 17, 3)}->{desc} && $xmldic->{asml}->{as}->{substr($msg, 17, 3)}->{desc} !~ m/SM/ )
        {
            printxml("etac","Etat courant",substr($msg, 49, 1),$xmldic->{pe}->{etac}->{substr($msg, 49, 1)}->{desc});
        }
        
        # Lancement de la fonction de décodage des infos complémentaires
        infocomp($msg);
    }
}

# Fin fonction d'analyse du début des messages SRFIL
################################################################################

################################################################################
# Fonctions permettant l'export vers le fichier xml de sortie

sub printxml
{
    my $sigle     = $_[0];
    my $nom       = $_[1];
    my $valeur    = $_[2];
    my $desc      = $_[3];
    my $detail    = $_[4];

    $outxml->startTag('info','sigle' => $sigle);
    $outxml->startTag('code');
    $outxml->characters($sigle);
    $outxml->endTag('code'); # End Code
    $outxml->startTag('nom');
    $outxml->characters($nom);
    $outxml->endTag('nom'); # End Nom
    $outxml->startTag('valeur');
    if ($valeur ne "")
    {
        $outxml->characters($valeur);
    }
    else
    {
        $outxml->characters("N/A");
    }
    $outxml->endTag('valeur'); # End Valeur
    if (defined $desc)
    {
        $outxml->startTag('desc');
        $outxml->characters($desc);
        $outxml->endTag('desc'); # End Desc
    }
    if ($detail)
    {
        $outxml->startTag('detail');
        $outxml->characters($detail);
        $outxml->endTag('detail'); # End Valeur
    }
    $outxml->endTag('info');# End Info
}

sub printxmlnum
{
    my $sigle      = $_[0];
    my $num        = $_[1];
    my $nom        = $_[2];
    my $valeur     = $_[3];
    my $desc       = $_[4];
    my $detail     = $_[5];

    $outxml->startTag('info','sigle' => $sigle,'num' => $num);
    $outxml->startTag('code');
    $outxml->characters($sigle);
    $outxml->endTag('code'); # End Code
    $outxml->startTag('nom');
    $outxml->characters($nom);
    $outxml->endTag('nom'); # End Nom
    $outxml->startTag('valeur');
    if ($valeur ne "")
    {
        $outxml->characters($valeur);
    }
    $outxml->endTag('valeur'); # End Valeur
    if ($desc)
    {
        $outxml->startTag('desc');
        $outxml->characters($desc);
        $outxml->endTag('desc'); # End Desc
    }
    if ($detail)
    {
        $outxml->startTag('detail');
        $outxml->characters($detail);
        $outxml->endTag('detail'); # End Valeur
    }
    $outxml->endTag('info');# End Info
}

sub printxmlwarn
{
    my $sigle     = $_[0];
    my $nom       = $_[1];
    my $desc      = $_[2];
    my $detail    = $_[3];

    $outxml->startTag('warning','sigle' => $sigle);
    $outxml->startTag('nom');
    $outxml->characters($nom);
    $outxml->endTag('nom'); # End Nom
    if ($desc)
    {
        $outxml->startTag('desc');
        $outxml->characters($desc);
        $outxml->endTag('desc'); # End Desc
    }
    if ($detail)
    {
        $outxml->startTag('detail');
        $outxml->characters($detail);
        $outxml->endTag('detail'); # End Valeur
    }
    $outxml->endTag('warning');# End Info
}

# Fin Fonctions permettant l'export vers le fichier xml de sortie
################################################################################

################################################################################
# Fonction permettant l'affichage en paragraphe d'un texte long
sub printl
{
    my $desc        = $_[0];
    my $texte       = $_[1];
    my $decal       = $_[2];
    my $nbdecal     = $decal;
    my $string      = "\n";
    my $textelength = length($texte);
    my @textetmp;
    
    $nbdecal =~ s/-//;
    for (my $i=0; $i<=$nbdecal; $i++)
    {
        $string = $string . " ";
    }
    $string = $string . "  ";
    
    $Text::Wrap::columns   = 52;
    $Text::Wrap::separator = $string;

    if ($textelength < 52)
    {
        printf OUT ("%*s : %s\n", $decal,$desc, $texte);
    }
    else
    {
        printf OUT ("%*s : %s\n", $decal,$desc, wrap("", "", $texte));
    }
}

# Fin fonction permettant l'affichage en paragraphe d'un texte long
################################################################################

################################################################################
# Fonction permettant l'affichage du registre de faute materielle (icmat)
sub printicmat
{
    my $desc        = $_[0];
    my $nom         = $_[1];
    my $texte       = $_[2];
    my @nomtmp      = split(/ \/ /,$nom);
    my @textetmp    = split(/ \/ /,$texte);

    printf OUT ("%-26s : %s : %s\n", $desc, $nomtmp[0], $textetmp[0]);

    for (my $i=1; $i<scalar(@textetmp); $i++)
    {
        printf OUT ("%-26s   %s : %s\n", " ", $nomtmp[$i], $textetmp[$i]);
    }
    
}

# Fin fonction permettant l'affichage en paragraphe d'un texte long
################################################################################

################################################################################
# Fonction de décodage des information complémentaire en fonction de codm
sub infocomp
{
    my $msg = $_[0];
    my $codm;
    my $tyrq;
    my $offset;
    my $offset2;
    my $offset3;
    my $nbcartehs;
    my $nbml;
    my $nomsigle;
    my $adrml;
    my $posp;
    my $etac;
    my $sec;

		# *****************
		# Gestion du numéro de CODM commun à tous les messages
    $codm = substr($msg, 50, 4);
    printxml("codm","Classe et code du message",substr($msg, 50, 4),$xmldic->{cause}->{codm}->{substr($msg, 50, 4)}->{desc},$xmldic->{cause}->{codm}->{substr($msg, 50, 4)}->{detail});
    $outxml->startTag('infocomp');

		# *****************
		# Gestions des messages en fonction de leur CODM		

    # CODM = 0000 => Requête issue d'une RHM
    if ($codm eq "0000")
    {
        printxml("tyrq","Type de requête",substr($msg, 54, 4),$xmldic->{cause}->{codm}->{$codm}->{tyrq}->{substr($msg, 57, 1)}->{desc});
        printxml("assm","Adresse système de la SM",substr($msg, 58, 4),$xmldic->{asml}->{as}->{substr($msg, 59, 3)}->{desc});
        printxml("etad","Etat demandé",substr($msg, 62, 2),$xmldic->{cause}->{codm}->{$codm}->{etad}->{substr($msg, 62, 2)}->{desc});

        # si tyrq n'est pas un locavar (différent de 4)
        if (substr($msg, 57, 1) == 1)
        {
            printxml("tych","Type de chargement",substr($msg, 66, 2),$xmldic->{cause}->{codm}->{$codm}->{tych}->{substr($msg, 66, 2)}->{desc});
        }

        # si tyrq signifie un locavar (égal à 4)
        elsif (substr($msg, 57, 1) == 4)
        {
            printxml("tych","Type de LOCAVAR",substr($msg, 66, 2),$xmldic->{cause}->{codm}->{$codm}->{tychloc}->{substr($msg, 66, 2)}->{desc});
        }

        printxml("conf","Confirmation",substr($msg, 68, 2),$xmldic->{cause}->{codm}->{$codm}->{conf}->{substr($msg, 68, 2)}->{desc});
    }

    # CODM = AC11 => Message de positionnement émis par la défense centrale vers une station
    elsif ($codm eq "AC11")
    {
        printxml("tyac","Type d'action",substr($msg, 54, 4),$xmldic->{cause}->{codm}->{$codm}->{tyac}->{substr($msg, 57, 1)}->{desc});
        printxml("posp","Positionnement primaire",substr($msg, 58, 1),$xmldic->{pe}->{posp}->{substr($msg, 58, 1)}->{desc});

        # en fonction du type d'action
        if (substr($msg, 57, 1) == 0)
        {
            printxml("ctrr","Type de contrôle",substr($msg,60,2),$xmldic->{cause}->{codm}->{$codm}->{tyac}->{substr($msg, 57, 1)}->{ctrr}->{substr($msg, 60, 2)}->{desc});
        }
        elsif (substr($msg, 57, 1) == 1)
        {
            printxml("ctrr","Type d'insertion",substr($msg,60,2),$xmldic->{cause}->{codm}->{$codm}->{tyac}->{substr($msg, 57, 1)}->{ctrr}->{substr($msg, 60, 2)}->{desc});
        }
        elsif (substr($msg, 57, 1) == 5)
        {
            printxml("ctrr","Type de LOCAVAR",substr($msg,60,2),$xmldic->{cause}->{codm}->{$codm}->{tyac}->{substr($msg, 57, 1)}->{ctrr}->{substr($msg, 60, 2)}->{desc});
        }

        printxml("tych","Type de chargement",substr($msg, 62, 4),$xmldic->{cause}->{codm}->{$codm}->{tych}->{substr($msg, 65, 1)}->{desc});
        printxml("vrsy","Version des données systèmes",substr($msg, 66, 4),$xmldic->{cause}->{codm}->{$codm}->{vrsy}->{substr($msg, 66, 4)}->{desc});
        printxml("apso","Adresse physique de la source de chargement",substr($msg, 70, 4),calcapml(substr($msg, 70, 4)));
        printxml("asso","Adresse système de la source de chargement",substr($msg, 74, 4),$xmldic->{asml}->{as}->{substr($msg, 75, 3)}->{desc});
        printxml("nofb","Numéro du fichier de boot à charger",substr($msg, 78, 4));
        printxml("etas","Etat système",substr($msg, 82, 1),$xmldic->{es}->{etas}->{substr($msg, 82, 1)}->{desc});
        printxml("iac","Indicateur d'avancement",substr($msg, 83, 1),$xmldic->{es}->{etas}->{substr($msg, 82, 1)}->{iac}->{substr($msg, 83, 1)}->{desc});
        printxml("nivs","Niveau de fonctionnement du système",substr($msg, 84, 2),$xmldic->{ni}->{nivs}->{substr($msg, 84, 2)}->{desc});
        printxml("apho","Adresse physique de l'homologue",substr($msg, 86, 4),calcapml(substr($msg, 86, 4)));
        printxml("asho","Adresse système de l'homologue",substr($msg, 90, 4),$xmldic->{asml}->{as}->{substr($msg, 91, 3)}->{desc});
    }

    # CODM = AE11 => Message émis par une station en fin d'execution d'une demande de positionnement
    elsif ($codm eq "AE11")
    {
        printxml("crdp","Compte rendu",substr($msg, 54, 4),$xmldic->{cause}->{codm}->{$codm}->{crdp}->{substr($msg, 57, 1)}->{desc});
        printxml("tyfm","Format du message",substr($msg, 58, 1),$xmldic->{cause}->{codm}->{$codm}->{tyfm}->{substr($msg, 58, 1)}->{desc});

        # test si tyfm indique si il y a plus ou moins de 8 ML
        if (substr($msg, 58, 1) == 0)
        {
            $offset = 58;
            $nbml = 8;
            $nomsigle = "tabet";
        }
        else
        {
            $offset = 138;
            $nbml = 16;
            $nomsigle = "tmlse";
        }
        
        if ( substr($msg, $offset + 1, 3) ne "000" )
        {
            $outxml->startTag('info','sigle' => $nomsigle);
            $outxml->startTag('code');
            $outxml->characters($nomsigle);
            $outxml->endTag('code');
            $outxml->startTag('nom');
            $outxml->characters("Etat des ML");
            $outxml->endTag('nom');
            #$outxml->startTag('valeur');
            #$outxml->characters(substr($msg,$offset,$nbml*8));
            #$outxml->endTag('valeur');

            for (my $i = 0 ; $i < $nbml ; $i++)
            {
                $adrml = substr($msg, $offset + 1, 3);
                $posp  = substr($msg, $offset + 4, 1);
                $etac  = substr($msg, $offset + 5, 1);
                $sec   = substr($msg, $offset + 6, 2);
                if ($adrml ne "000")
                {
                    $outxml->startTag('ml','num' => $i+1);
                    printxml("asml","Adresse système de la ML","0".$adrml,$xmldic->{asml}->{as}->{$adrml}->{desc});
                    printxml("posp","Positionnement primaire",$posp,$xmldic->{pe}->{posp}->{$posp}->{desc});
                    if ($xmldic->{asml}->{as}->{$adrml}->{desc} && $xmldic->{asml}->{as}->{$adrml}->{desc} =~ m/SM/)
                    {
                        printxml("etac","Etat courant",$etac,$xmldic->{pe}->{etac}->{$etac}->{desc});
                    }
                    elsif ($xmldic->{asml}->{as}->{$adrml}->{desc} && $xmldic->{asml}->{as}->{$adrml}->{desc} !~ m/SM/)
                    {
                        printxml("sec","Indicateur de secours",$sec,$xmldic->{se}->{sec}->{$sec}->{desc});
                    }
                    $outxml->endTag('ml'); # End ml
                }
                $offset = $offset + 8;
            }
            $outxml->endTag('info');
        }
        
        &getcause($msg);
    }

    # CODM = AE91 => Message émis en fin de locavar
    elsif ($codm eq "AE91")
    {
        printxml("pdia","Présence d'un diagnostique",substr($msg, 54, 2),$xmldic->{locavar}->{station}->{pdia}->{substr($msg, 54, 2)}->{desc});

        if (substr($msg, 54, 2) ne "00")
        {
            $nbcartehs = substr($msg, 56, 2);
            $nbcartehs =~ s/^0//;
            printxml("nbac","Nombre de cartes accusée",$nbcartehs);
            if ($nbcartehs > 0)
            {
                $offset = 58;
                for (my $i = 0 ; $i < $nbcartehs ; $i++)
                {
                    printxmlnum("rgca",$i,"Rang de la carte accusée",sprintf("%02d",hex(substr($msg, $offset, 2))));
                    $offset = $offset + 2;
                }
            }

            # Calcul des nglr
            if ( substr($msg, 90, 4) ne "0000" )
            {
                $outxml->startTag('info','sigle' => 'nglr');
                $outxml->startTag('code');
                $outxml->characters('nglr');
                $outxml->endTag('code');
                $outxml->startTag('nom');
                $outxml->characters('Groupe de LR accusée');
                $outxml->endTag('nom');
                $outxml->startTag('valeur');
                $outxml->characters(substr($msg, 90, 4));
                $outxml->endTag('valeur');
                if (bin2hex(substr(hex2bin(substr($msg, 90, 4)),0,2,)) == 0 )
                {
						        printxml("itype","Type de groupe de LR",bin2hex(substr(hex2bin(substr($msg, 90, 4)),0,2,)),$xmldic->{cause}->{codm}->{$codm}->{itype}->{bin2hex(substr(hex2bin(substr($msg, 90, 4)),0,2,))}->{desc});
						        printxml("nbra","Branche réseau",bin2hex(substr(hex2bin(substr($msg, 90, 4)),2,6,)),$xmldic->{cause}->{codm}->{$codm}->{nbra}->{bin2hex(substr(hex2bin(substr($msg, 90, 4)),2,6,))}->{desc});
						        printxml("nglr","Numéro de groupe de LR",bin2hex(substr(hex2bin(substr($msg, 90, 4)),8,8,)));
                }
                elsif (bin2hex(substr(hex2bin(substr($msg, 90, 4)),0,2,)) == 1 )
                {
						        printxml("itype","Type de groupe de LR",bin2hex(substr(hex2bin(substr($msg, 90, 4)),0,2,)),$xmldic->{cause}->{codm}->{$codm}->{itype}->{bin2hex(substr(hex2bin(substr($msg, 90, 4)),0,2,))}->{desc});
						        printxml("nbra","Branche réseau",bin2hex(substr(hex2bin(substr($msg, 90, 4)),2,2,)),$xmldic->{cause}->{codm}->{$codm}->{nbra}->{bin2hex(substr(hex2bin(substr($msg, 90, 4)),2,2,))}->{desc});
						        printxml("nglr","Numéro de groupe de LR",bin2hex(substr(hex2bin(substr($msg, 90, 4)),4,12,)));
                }
                $outxml->endTag('info');
            }

            printxml("elac","Elément accusé",substr($msg, 94, 2));

            # Traitement de idia
            if ( substr($msg, 96, 2) == 24)
            {
                $outxml->startTag('info','sigle' => 'idia');
                $outxml->startTag('code');
                $outxml->characters('idia');
                $outxml->endTag('code');
                $outxml->startTag('nom');
                $outxml->characters('Informations complémentaires');
                $outxml->endTag('nom');
                #$outxml->startTag('valeur');
                #$outxml->characters(substr($msg, 98, 72));
                #$outxml->endTag('valeur');
                # Si HC
                if ($xmldic->{asml}->{as}->{substr($msg, 17, 3)}->{desc} =~ m/SMB/)
                {
                    printxml("ntst","Numéro de test",substr($msg, 98,  4));
                    printxml("icmat","Registre icmat",substr($msg, 102, 2),$xmldic->{cause}->{codm}->{$codm}->{icmatsmb}->{substr($msg, 102, 2)}->{desc});
                }

                # Sinon techno non HC
                else
                {
                    printxml("nstr","Numéro de stratégie",substr($msg, 98,  1));
                    printxml("nbstr","Nombre de stratégies",substr($msg, 99,  1));
                    printxml("ntst","Numéro de test",bin2hex(substr(hex2bin(substr($msg, 100, 2)),0,7)));
                    printxml("icmat","Registre icmat",substr($msg, 102, 2),$xmldic->{cause}->{codm}->{$codm}->{icmat}->{substr($msg, 102, 2)}->{desc});
                }
                
                printxml("nseq","Numéro de séquence",substr($msg, 104, 2));
                $offset = 106;
                for (my $i = 0 ; $i < 8 ; $i++)
                {
                    printxmlnum("iddi",$i,"Identification du diagnostique",substr($msg, $offset, 8));
                    $offset = $offset + 8;
                }
                $outxml->endTag('info');
            }
            printxml("nbcae","Nombre de cartes externes accusées",substr($msg,170,2));
            
            my $position = 172;
            for (my $i = 0 ; $i < 4 ; $i++)
            {
                my $apsm = substr($msg, $position, 4);
                my $sfca = substr($msg, $position + 4, 2);
                my $rgsf = substr($msg, $position + 6, 2);
                if ($apsm ne "000")
                {
                		$outxml->startTag('info','sigle' => 'apsm');
            				$outxml->startTag('code');
            				$outxml->characters('apsm');
            				$outxml->endTag('code');
            				$outxml->startTag('nom');
            				$outxml->characters('Adresse physique de la station');
            				$outxml->endTag('nom');
            				$outxml->startTag('valeur');
            				$outxml->characters($apsm);
            				$outxml->endTag('valeur');
            				$outxml->startTag('desc');
        						$outxml->characters(calcapml($apsm));
        						$outxml->endTag('desc');
                    printxml("sfca","sfca de la carte externe",$sfca);
                    printxml("rgsf","rgsf de la carte externe",$rgsf);
                    $outxml->endTag('info');
                }
                $position = $position + 8;
            }
        }
    }
    
    # CODM = AF10 => Débordement de temporisation 
    elsif ($codm eq "AF10")
    {
        if ( substr($msg, 54, 4) )
        {
            if ( $xmldic->{cause}->{codm}->{$codm}->{info}->{substr($msg, 54, 4)}->{desc} )
            {
                printxml("info1","Cause de l'initialisation générale",substr($msg, 54, 4),$xmldic->{cause}->{codm}->{$codm}->{info}->{substr($msg, 54, 4)}->{desc});
            }
            else
            {
                printxml("info1","Cause de l'initialisation générale",substr($msg, 56, 2),$xmldic->{typml}->{tyml}->{substr($msg, 56, 2)}->{desc},"type de ML");
            }
        }
    }
    
    # CODM = AF16 => Diagnostique adaptateur HS
    elsif ($codm eq "AF16")
    {
        printxml("amring","Adresse système de l'anneau",substr($msg, 54, 4),$xmldic->{asml}->{as}->{substr($msg, 55, 3)}->{desc});
        printxml("assm","Adresse système de la station",substr($msg, 58, 4),$xmldic->{asml}->{as}->{substr($msg, 59, 3)}->{desc});
        printxml("sfad","Spécification fonctionnelle de la carte support de l'adaptateur",substr($msg, 62, 4));
        printxml("rgad","Rang de la carte support de l'adaptateur",substr($msg, 66, 4));
        
        if ( $xmldic->{asml}->{as}->{substr($msg, 59, 3)}->{desc} &&  $xmldic->{asml}->{as}->{substr($msg, 59, 3)}->{desc} =~ m/SMB/ )
        {
            printxml("sfca","SFCA de la carte",$xmldic->{cause}->{codm}->{$codm}->{sfadrgad}->{substr($msg, 62, 8)}->{smb}->{sfca});
            printxml("rgca","RGCA de la carte",$xmldic->{cause}->{codm}->{$codm}->{sfadrgad}->{substr($msg, 62, 8)}->{smb}->{rgsf});
        }
        else
        {
            printxml("sfca","SFCA de la carte",$xmldic->{cause}->{codm}->{$codm}->{sfadrgad}->{substr($msg, 62, 8)}->{nonHC}->{sfca});
            printxml("rgca","RGCA de la carte",$xmldic->{cause}->{codm}->{$codm}->{sfadrgad}->{substr($msg, 62, 8)}->{nonHC}->{rgsf});
        }
    }

		# CODM = AF20 => Signalisation d'incohérence d'état    
    elsif ($codm eq "AF20")
    {
        printxml("tyfm","Format du message",substr($msg, 54, 1),$xmldic->{cause}->{codm}->{$codm}->{tyfm}->{substr($msg, 54, 1)}->{desc});

        if (substr($msg, 54, 1) == 0)
        {
            $nbml = 8;
            $nomsigle = "tabet";
        }
        else
        {
            $nbml = 16;
            $nomsigle = "tmlse";
        }
        
        $outxml->startTag('info','sigle' => $nomsigle);
        $outxml->startTag('code');
        $outxml->characters($nomsigle);
        $outxml->endTag('code');
        $outxml->startTag('nom');
        $outxml->characters('Etats des ML');
        $outxml->endTag('nom');

        $offset=58;
        for (my $i = 0 ; $i < $nbml ; $i++)
        {
            $adrml = substr($msg, $offset + 1, 3);
            $posp  = substr($msg, $offset + 4, 1);
            $etac  = substr($msg, $offset + 5, 1);
            $sec   = substr($msg, $offset + 6, 2);
            if ($adrml ne "000")
            {
                $outxml->startTag('ml','num' => $i+1);
                printxml("asml","Adresse système de la ML","0".$adrml,$xmldic->{asml}->{as}->{$adrml}->{desc});
                printxml("posp","Positionnement primaire",$posp,$xmldic->{pe}->{posp}->{$posp}->{desc});
                if ($xmldic->{asml}->{as}->{$adrml}->{desc} && $xmldic->{asml}->{as}->{$adrml}->{desc} =~ m/SM/)
                {
                    printxml("etac","Etat courant",$etac,$xmldic->{pe}->{etac}->{$etac}->{desc});
                }
                elsif ($xmldic->{asml}->{as}->{$adrml}->{desc} && $xmldic->{asml}->{as}->{$adrml}->{desc} !~ m/SM/)
                {
                    printxml("sec","Indicateur de secours",$sec,$xmldic->{se}->{sec}->{$sec}->{desc});
                }
                $outxml->endTag('ml'); # End ml
            }
            $offset = $offset + 8;
        }
        $outxml->endTag('info');
    }
    
    # CODM = AF23 => Diffusion d'état de charge
    elsif ($codm eq "AF23" )
    {
        printxml("asml","Adresse système de la station",substr($msg, 54, 4),$xmldic->{asml}->{as}->{substr($msg, 55, 3)}->{desc});
        printxml("tyfm","Format du message",substr($msg, 58, 1),$xmldic->{cause}->{codm}->{$codm}->{tyfm}->{substr($msg, 58, 1)}->{desc});

        # Format de message standard ( <= 8 ML )
        if ( substr($msg, 58, 1) == 0 )
        {
            $nbml = 8;
            $offset = 58;
            $offset2= 90;
            $offset3= 130;
        }
        # Format de message Long ( > 8 ML )
        else
        {
            $nbml = 16;
            $offset = 130;
            $offset2= 122;
            $offset3= 258;
        }
        
        $outxml->startTag('info','sigle' => 'chml');
        $outxml->startTag('code');
        $outxml->characters('chml');
        $outxml->endTag('code');
        $outxml->startTag('nom');
        $outxml->characters('Etat de charge des ML');
        $outxml->endTag('nom');
        
        for (my $i = 0 ; $i < $nbml ; $i++)
        {
            if (substr($msg, $offset + 1, 3) ne "000")
            {
                $outxml->startTag('ml','num' => $i+1);
                printxml("asml","Adresse système de la ML",substr($msg, $offset, 4),$xmldic->{asml}->{as}->{substr($msg, $offset + 1, 3)}->{desc});
                printxml("etch","Etat de charge",substr($msg, $offset + 6, 2),$xmldic->{charge}->{etch}->{substr($msg, $offset + 6, 2)}->{desc},$xmldic->{charge}->{etch}->{substr($msg, $offset + 6, 2)}->{info});
                $outxml->endTag('ml'); # End ml
            }
            $offset = $offset + 8;
        }
        
        $outxml->endTag('info');
        
        if ( substr($msg,90,2) eq "00" )
        {
            printxml("rafr","Indicateur de rafraicchissement",substr($msg, $offset2, 2),"Changement d'état");
        }
        else
        {
            printxml("rafr","Indicateur de rafraicchissement",substr($msg, $offset2, 2),"Rafraichissement");
        }
        printxml("nmes","Numéro de message",substr($msg, $offset3, 4));
    }
    
    # CODM = AF30 => Signalisation d'incohérence interne
    elsif ($codm eq "AF30")
    {
        printxml("asor","Adresse système de l'emetteur",substr($msg, 54, 4),$xmldic->{asml}->{as}->{substr($msg, 55, 3)}->{desc},$xmldic->{cause}->{codm}->{$codm}->{orig}->{substr($msg, 55, 3)}->{desc});
        if ( $xmldic->{asml}->{as}->{substr($msg, 55, 3)}->{desc} ne "OM" )
        {
            printxml("causi","Cause du basculement",substr($msg, 58, 4),$xmldic->{cause}->{codm}->{$codm}->{causi}->{substr($msg, 58, 4)}->{desc});
        }
    }
    
    # CODM = AF40 => Requête interne de positionnement de SM
    elsif ($codm eq "AF40")
    {		
        printxml("typa","Type d'accusation",substr($msg, 54, 4),$xmldic->{cause}->{codm}->{$codm}->{typa}->{substr($msg, 54, 4)}->{desc});
        printxml("asml","Adresse système accusée",substr($msg, 58, 4),$xmldic->{asml}->{as}->{substr($msg, 59, 3)}->{desc});
        printxml("asem","Adresse système de l'émetteur de l'anomalie",substr($msg, 62, 4),$xmldic->{asml}->{as}->{substr($msg, 63, 3)}->{desc});
        # Accusation par traitement statistique des anomalies
        if ( substr($msg, 54, 4) eq "0000" && length($msg)>66 )
        {
            $outxml->startTag('info','sigle' => 'info');
            $outxml->startTag('code');
            $outxml->characters('info');
            $outxml->endTag('code');
            $outxml->startTag('nom');
            $outxml->characters("Mot 0 à 8 de l'anomalie");
            $outxml->endTag('nom');
            $offset = 66;
            for (my $i=0; $i<9; $i++)
            {
                printxmlnum("info",$i,"Mot ".$i." de l'anomalie",substr($msg, $offset, 4));
                $offset = $offset + 4;
            
            }
            $outxml->endTag('info');
            printxml("ft","Fonction et type du message d'anomalie",substr($msg, $offset, 2),$xmldic->{anomalie}->{general}->{ft}->{substr($msg, $offset, 2)}->{nom},$xmldic->{anomalie}->{general}->{ft}->{substr($msg, $offset, 2)}->{desc});
        }
    }
    
    # CODM = AF41 => Signalisation de changement d'état
    elsif ($codm eq "AF41")
    {
        printxml("tyfm","Format du message",substr($msg, 54, 1),$xmldic->{cause}->{codm}->{$codm}->{tyfm}->{substr($msg, 54, 1)}->{desc});
        printxml("asml","Adresse système de la ML",substr($msg,54,4),$xmldic->{asml}->{as}->{substr($msg, 55, 3)}->{desc});
        $offset = 58;

        # test si tyfm indique si il y a plus ou moins de 8 ML
        if (substr($msg, 54, 1) == 0)
        {
            $nbml = 8;
            $nomsigle = "tabet";
        }
        else
        {
            $nbml = 16;
            $nomsigle = "tmlse";
        }

        $outxml->startTag('info','sigle' => $nomsigle);
        $outxml->startTag('code');
        $outxml->characters($nomsigle);
        $outxml->endTag('code');
        $outxml->startTag('nom');
        $outxml->characters("Etat des ML");
        $outxml->endTag('nom');
        for (my $i = 0 ; $i < $nbml ; $i++)
        {
            $adrml = substr($msg, $offset + 1, 3);
            $posp  = substr($msg, $offset + 4, 1);
            $etac  = substr($msg, $offset + 5, 1);
            $sec   = substr($msg, $offset + 6, 2);
            if ($adrml ne "000")
            {
                $outxml->startTag('ml','num' => $i+1);
                printxml("asml","Adresse système de la ML","0".$adrml,$xmldic->{asml}->{as}->{$adrml}->{desc});
                printxml("posp","Positionnement primaire",$posp,$xmldic->{pe}->{posp}->{$posp}->{desc});
                if ($xmldic->{asml}->{as}->{$adrml}->{desc} && $xmldic->{asml}->{as}->{$adrml}->{desc} =~ m/SM/)
                {
                    printxml("etac","Etat courant",$etac,$xmldic->{pe}->{etac}->{$etac}->{desc});
                }
                elsif ($xmldic->{asml}->{as}->{$adrml}->{desc} && $xmldic->{asml}->{as}->{$adrml}->{desc} !~ m/SM/)
                {
                    printxml("sec","Indicateur de secours",$sec,$xmldic->{se}->{sec}->{$sec}->{desc});
                }
                $outxml->endTag('ml'); # End ml
            }
            $offset = $offset + 8;
        }
        $outxml->endTag('info');
    }
    
    # CODM = AF44 => Changement d'état d'instance de service
    elsif ($codm eq "AF44")
    {
        $outxml->startTag('info','sigle' => 'tmlse');
        $outxml->startTag('code');
        $outxml->characters('tmlse');
        $outxml->endTag('code');
        $outxml->startTag('nom');
        $outxml->characters("Etat d'une à 4 instances");
        $outxml->endTag('nom');
        $offset = 54;
        for (my $i=0; $i<4; $i++)
        {
            if ( substr($msg, $offset+1,3) ne "000" )
            {
                printxml("asmle","Adresse système de l'instance",substr($msg, $offset, 4),$xmldic->{asml}->{as}->{substr($msg, $offset+1, 3)}->{desc});
                printxml("port","Numéro de port",substr($msg, $offset+4, 4),$xmldic->{cause}->{codm}->{$codm}->{port}->{substr($msg, $offset+4, 4)}->{desc});
                printxml("etas","Etat système (inutilisé)",substr($msg, $offset+8, 1),$xmldic->{es}->{etas}->{substr($msg, $offset+8, 1)}->{desc});
                printxml("etace","Etat courant",substr($msg, $offset+9, 1),$xmldic->{cause}->{codm}->{$codm}->{etace}->{substr($msg, $offset+9, 1)}->{desc});
                printxml("setat","Sous état",substr($msg, $offset+10, 1),$xmldic->{cause}->{codm}->{$codm}->{setat}->{substr($msg, $offset+10, 1)}->{desc});
                printxml("iac","Indicateur d'avancement",substr($msg, $offset+11, 1),$xmldic->{es}->{etas}->{substr($msg, $offset+8, 1)}->{iac}->{substr($msg, $offset+11, 1)}->{desc});
            }
            $offset = $offset + 12;
        }
        $outxml->endTag('info');
    }
    
    # CODM = AF61 => Requête de positionnement de SM
    elsif ($codm eq "AF61" )
    {
        printxml("tyre","Type de requête",substr($msg, 54, 4),$xmldic->{cause}->{codm}->{$codm}->{tyre}->{substr($msg, 54, 4)}->{desc});
        printxml("rgca","rgca de la carte ou applique en faute",sprintf("%02d",hex(substr($msg, 58, 2))));

        if ($xmldic->{asml}->{as}->{substr($msg, 17, 3)}->{desc} =~ m/SMB/)
        {
            printxml("icmat","Registre de faute matérielle",substr($msg, 60, 2),$xmldic->{cause}->{codm}->{$codm}->{icmatsmb}->{substr($msg, 60, 2)}->{nom},$xmldic->{cause}->{codm}->{$codm}->{icmatsmb}->{substr($msg, 60, 2)}->{desc});
        }
        else
        {
            printxml("icmat","Registre de faute matérielle",substr($msg, 60, 2),$xmldic->{cause}->{codm}->{$codm}->{icmat}->{substr($msg, 60, 2)}->{nom},$xmldic->{cause}->{codm}->{$codm}->{icmat}->{substr($msg, 60, 2)}->{desc});
        }

        printxml("iclog","Registre de faute logicielle",substr($msg, 62, 2),$xmldic->{cause}->{codm}->{$codm}->{iclog});
        
        # Si form = 02
        if ( substr($msg, 80, 2) eq "02" )
        {
            printxml("idmu","Identification du multiplex",substr($msg, 64, 2),$xmldic->{cause}->{codm}->{$codm}->{idmu}->{substr($msg, 64, 2)}->{desc});
            if ( hex(substr($msg, 66,2))%2 == 0 )
            {
                printxml("idad","Identification de l'adaptateur",substr($msg, 66,2),"Adaptateur A");
            }
            else
            {
                printxml("idad","Identification de l'adaptateur",substr($msg, 66,2),"Adaptateur B");
            }
        }
        
        printxml("asml","Adresse système du composant actif lors de la faute",substr($msg, 68, 4),$xmldic->{asml}->{as}->{substr($msg, 69, 3)}->{desc},"Ce composant n'est pas obligatoirement à l'origine de la faute");
        printxml("form","Format du message",substr($msg, 80, 2),$xmldic->{cause}->{codm}->{$codm}->{form}->{substr($msg, 80, 2)}->{desc});
        printxml("numano","Numéro de l'anomalie",substr($msg, 82, 4),$xmldic->{anomalie}->{numanomlsm}->{numano}->{substr($msg, 82, 4)}->{desc});
        if ($xmldic->{asml}->{as}->{substr($msg, 17, 3)}->{desc} =~ m/SMB/)
        {
            printxml("diapr","rgem de l'élément matériel",substr($msg, 86, 2),"rgem précise l'élément en faute sur la carte ou l'applique");
        }
        else
        {
            printxml("diapr","Diagnostique PROM",substr($msg, 86, 2));
        }
        
        $outxml->startTag('infocomp');
        $outxml->startTag('code');
        $outxml->characters('inf8');
        $outxml->endTag('code');
        $outxml->startTag('nom');
        $outxml->characters("Informations complémentaires");
        $outxml->endTag('nom');
        $outxml->startTag('desc');
        $outxml->characters("selon form et numano");
        $outxml->endTag('desc');
            
        # **************
        # Traitement des info complémentaires
        # form = 01
        if ( substr($msg, 80, 2) eq "01" )
        {
            printxml("sens3","Sous ensemble 3",substr($msg, 72, 2),"Signification en fonction de tyml et numano");
            printxml("sens2","Sous ensemble 2",substr($msg, 74, 2),"Signification en fonction de tyml et numano");
            printxml("sens1","Sous ensemble 1",substr($msg, 76, 2),"Signification en fonction de tyml et numano");
            printxml("tyml","Type de ML",substr($msg, 78, 2),$xmldic->{typml}->{tyml}->{substr($msg, 78, 2)}->{desc});
            $outxml->startTag('infosup');
            $outxml->startTag('code');
            $outxml->characters('infs');
            $outxml->endTag('code');
            $outxml->startTag('nom');
            $outxml->characters("Informations supplémentaires");
            $outxml->endTag('nom');
            $outxml->startTag('desc');
            $outxml->characters("selon numano");
            $outxml->endTag('desc');
            $offset = 88;
            for (my $i=0; $i<7; $i++)
            {
                printxmlnum("infs",$i,"Information supplémentaire ".$i,substr($msg, $offset, 2));
                $offset = $offset + 2;
            }
            $outxml->endTag('infosup');
        }
        # form = 02
        elsif ( substr($msg, 80, 2) eq "02" )
        {
            printxml("cinc","Cause d'indisponibilité du canal",substr($msg, 72, 2),$xmldic->{cause}->{codm}->{$codm}->{cinc}->{substr($msg, 72, 2)}->{desc});
            if ( hex(substr($msg, 74, 2))%2 == 0)
            {
                printxml("ran","Rang de l'adaptateur",substr($msg, 74, 2),"Adaptateur A");
            }
            else
            {
                printxml("ran","Rang de l'adaptateur",substr($msg, 74, 2),"Adaptateur B");
            }
            printxml("cmde","Commande",substr($msg, 76, 2));
            printxml("caus","Cause de la panne",substr($msg, 78, 2),$xmldic->{cause}->{codm}->{$codm}->{caus}->{substr($msg, 78, 2)}->{desc});
            $outxml->startTag('infosup');
            $outxml->startTag('code');
            $outxml->characters('infs');
            $outxml->endTag('code');
            $outxml->startTag('nom');
            $outxml->characters("Informations supplémentaires");
            $outxml->endTag('nom');
            $outxml->startTag('desc');
            $outxml->characters("selon numano");
            $outxml->endTag('desc');
            $offset = 88;
            for (my $i=0; $i<7; $i++)
            {
                printxmlnum("infs",$i,"Information supplémentaire ".$i,substr($msg, $offset, 2));
                $offset = $offset + 2;
            }
            $outxml->endTag('infosup');
        }
        # form = 03
        elsif ( substr($msg, 80, 2) eq "03" )
        {
            printxml("sens3","Sous ensemble 3 selon tyml et numano",substr($msg, 72, 2));
            printxml("sens3","Sous ensemble 2 selon tyml et numano",substr($msg, 74, 2));
            printxml("sad","Sous adresse du composant",substr($msg, 76, 2));
            printxml("tyml","Type de ML",substr($msg, 78, 2),$xmldic->{typml}->{tyml}->{substr($msg, 78, 2)}->{desc});
            # Si ML = SM et techno HC
            if ( $xmldic->{typml}->{tyml}->{substr($msg, 78, 2)}->{desc} =~ m/SM/ && $xmldic->{asml}->{as}->{substr($msg, 69, 3)}->{desc} =~ m/SMB/ )
            {
                printxml("comp","Nom du composant","",$xmldic->{sadmlsm}->{sad}->{substr($msg, 76, 2)}->{desc});
            }
            # Si ML = SM et techno RCX
            elsif ( $xmldic->{typml}->{tyml}->{substr($msg, 78, 2)}->{desc} =~ m/SM/ && $xmldic->{asml}->{as}->{substr($msg, 69, 3)}->{desc} !~ m/SMB/ )
            {
                printxml("comp","Nom du composant","",$xmldic->{sadml}->{sad}->{substr($msg, 76, 2)}->{desc});
            }
            # Si ML != SM
            elsif ( $xmldic->{typml}->{tyml}->{substr($msg, 78, 2)}->{desc} !~ m/SM/ )
            {
                printxml("comp","Nom du composant","",$xmldic->{typml}->{tyml}->{substr($msg, 78, 2)}->{sad}->{substr($msg, 76, 2)}->{desc});
            }
            $outxml->startTag('infosup');
            $outxml->startTag('code');
            $outxml->characters('infs');
            $outxml->endTag('code');
            $outxml->startTag('nom');
            $outxml->characters("Informations supplémentaires");
            $outxml->endTag('nom');
            $outxml->startTag('desc');
            $outxml->characters("selon numano");
            $outxml->endTag('desc');
            $offset = 88;
            for (my $i=0; $i<7; $i++)
            {
                printxmlnum("infs",$i,"Information supplémentaire ".$i,substr($msg, $offset, 2));
                $offset = $offset + 2;
            }
            $outxml->endTag('infosup');
        }
        # form = 04
        elsif ( substr($msg, 80, 2) eq "04" )
        {
            printxml("crt","Compte rendu d'échec émission",substr($msg, 76, 4));
            $outxml->startTag('infosup');
            $outxml->startTag('code');
            $outxml->characters('infs');
            $outxml->endTag('code');
            $outxml->startTag('nom');
            $outxml->characters("Informations supplémentaires");
            $outxml->endTag('nom');
            $outxml->startTag('desc');
            $outxml->characters("selon numano");
            $outxml->endTag('desc');
            $offset = 88;
            for (my $i=0; $i<7; $i++)
            {
                printxmlnum("infs",$i,"Information supplémentaire ".$i,substr($msg, $offset, 2));
                $offset = $offset + 2;
            }
            $outxml->endTag('infosup');
        }
        # form = 05 et numano = 00BC
        elsif ( substr($msg, 80, 2) eq "05" && substr($msg, 82, 4) eq "00BC")
        {
            printxml("vect","Vecteurs d'interruption",substr($msg, 72, 4),$xmldic->{vecteur}->{vect}->{substr($msg, 72, 4)}->{desc});
            printxml("sad","Sous adresse du composant",substr($msg,76 , 2));
            printxml("tyml","Type de ML",substr($msg,78 , 2),$xmldic->{typml}->{tyml}->{substr($msg,78 , 2)}->{desc});
            # Si ML = SM et techno HC
            if ( $xmldic->{typml}->{tyml}->{substr($msg, 78, 2)}->{desc} =~ m/SM/ && $xmldic->{asml}->{as}->{substr($msg, 69, 3)}->{desc} =~ m/SMB/ )
            {
                printxml("comp","Nom du composant","",$xmldic->{sadmlsm}->{sad}->{substr($msg, 76, 2)}->{desc});
            }
            # Si ML = SM et techno RCX
            elsif ( $xmldic->{typml}->{tyml}->{substr($msg, 78, 2)}->{desc} =~ m/SM/ && $xmldic->{asml}->{as}->{substr($msg, 69, 3)}->{desc} !~ m/SMB/ )
            {
                printxml("comp","Nom du composant","",$xmldic->{sadml}->{sad}->{substr($msg, 76, 2)}->{desc});
            }
            # Si ML != SM
            elsif ( $xmldic->{typml}->{tyml}->{substr($msg, 78, 2)}->{desc} !~ m/SM/ )
            {
                printxml("comp","Nom du composant","",$xmldic->{typml}->{tyml}->{substr($msg, 78, 2)}->{sad}->{substr($msg, 76, 2)}->{desc});
            }

            $outxml->startTag('infosup');
            $outxml->startTag('code');
            $outxml->characters('infs');
            $outxml->endTag('code');
            $outxml->startTag('nom');
            $outxml->characters("Informations supplémentaires");
            $outxml->endTag('nom');
            $outxml->startTag('desc');
            $outxml->characters("selon numano");
            $outxml->endTag('desc');
            
            if ( $xmldic->{asml}->{as}->{substr($msg, 17, 3)}->{desc} =~ m/SMB/ )
            {
                printxml("exlo","Exception logique",substr($msg, 88, 8),$xmldic->{cause}->{codm}->{$codm}->{exlo}->{substr($msg, 88, 8)}->{desc});
            }
            else
            {
                printxml("pc","Programm Counter",substr($msg, 88, 8));
            }

            $outxml->endTag('infosup');
            
        }
        # form = 05 et numano = 00FE
        elsif ( substr($msg, 80, 2) eq "05" && substr($msg, 82, 4) eq "00FE")
        {
            printxml("pc","Programm Counter",substr($msg, 72, 8));
            $outxml->startTag('infosup');
            $outxml->startTag('code');
            $outxml->characters('infs');
            $outxml->endTag('code');
            $outxml->startTag('nom');
            $outxml->characters("Informations supplémentaires");
            $outxml->endTag('nom');
            $outxml->startTag('desc');
            $outxml->characters("selon numano");
            $outxml->endTag('desc');
            $offset = 88;
            for (my $i=0; $i<7; $i++)
            {
                printxmlnum("infs",$i,"Information supplémentaire ".$i,substr($msg, $offset, 2));
                $offset = $offset + 2;
            }
            $outxml->endTag('infosup');
        }
        # form = 05 et numano = 00FF
        elsif ( substr($msg, 80, 2) eq "05" && substr($msg, 82, 4) eq "00FF")
        {
            if ( $xmldic->{asml}->{as}->{substr($msg, 17, 3)}->{desc} =~ m/SMB/ )
            {
                if ( substr($msg, 76,4) eq "0000" )
                {
                    printxml("icloge","Registre de faute logicielle étendu (SMB)",substr($msg, 76, 4),"Non significatif");
                }
                else
                {
                    $outxml->startTag('info','sigle' => 'icloge');
                    $outxml->startTag('code');
                    $outxml->characters('icloge');
                    $outxml->endTag('code');
                    $outxml->startTag('nom');
                    $outxml->characters("Registre de faute logicielle étendu (SMB)");
                    $outxml->endTag('nom');
                    $outxml->startTag('valeur');
                    $outxml->characters(substr($msg, 76,4));
                    $outxml->endTag('valeur');
                    printxml("typf","Type de faute",substr(hex2bin(substr($msg, 76, 4)),0,1),$xmldic->{cause}->{codm}->{$codm}->{typf}->{substr(hex2bin(substr($msg, 76, 4)),0,1)}->{desc});
                    printxml("tyml","Type de ML",bin2hex(substr(hex2bin(substr($msg,76,4)),1,5)),$xmldic->{typml}->{tyml}->{bin2hex(substr(hex2bin(substr($msg,76,4)),1,5))}->{desc});
                    printxml("nano","Numéro d'anomalie",bin2hex(substr(hex2bin(substr($msg,76,4)),6,10)));
                    $outxml->endTag('info');
                }
                
                $outxml->startTag('infosup');
                $outxml->startTag('code');
                $outxml->characters('infs');
                $outxml->endTag('code');
                $outxml->startTag('nom');
                $outxml->characters("Informations supplémentaires");
                $outxml->endTag('nom');
                $outxml->startTag('desc');
                $outxml->characters("selon numano");
                $outxml->endTag('desc');
                printxml("exlo","Exception logique",substr($msg, 88, 8),$xmldic->{cause}->{codm}->{$codm}->{exlo}->{substr($msg, 88, 8)}->{desc});
                $outxml->endTag('infosup');
            }
            
            else
            {
                $outxml->startTag('infosup');
                $outxml->startTag('code');
                $outxml->characters('infs');
                $outxml->endTag('code');
                $outxml->startTag('nom');
                $outxml->characters("Informations supplémentaires");
                $outxml->endTag('nom');
                $outxml->startTag('desc');
                $outxml->characters("selon numano");
                $outxml->endTag('desc');
                $offset = 88;
                for (my $i=0; $i<7; $i++)
                {
                    printxmlnum("infs",$i,"Information supplémentaire ".$i,substr($msg, $offset, 2));
                    $offset = $offset + 2;
                }
                $outxml->endTag('infosup');
            }
        }
        else
        {
            $offset = 72;
            for (my $i=0; $i<7; $i++)
            {
                printxmlnum("inf8",$i,"Information complémentaire ".$i,substr($msg, $offset, 2));
                $offset = $offset + 2;
            }
        
            $outxml->startTag('infosup');
            $outxml->startTag('code');
            $outxml->characters('infs');
            $outxml->endTag('code');
            $outxml->startTag('nom');
            $outxml->characters("Informations supplémentaires");
            $outxml->endTag('nom');
            $outxml->startTag('desc');
            $outxml->characters("selon numano");
            $outxml->endTag('desc');
            $offset = 88;
            for (my $i=0; $i<7; $i++)
            {
                printxmlnum("infs",$i,"Information supplémentaire ".$i,substr($msg, $offset, 2));
                $offset = $offset + 2;
            }
            $outxml->endTag('infosup');
        }
        $outxml->endTag('infocomp');
    }
    
    elsif ($codm eq "AF63")
    {
        if ( substr($msg, 58, 2) eq "3D" || substr($msg, 58, 2) eq "3F" || substr($msg, 58, 2) eq "3D" )
        {
            printxml("apsm","Adresse physique de la station",bin2hex(substr(hex2bin(substr($msg, 54, 4)),0,9)),calcapml(bin2hex(substr(hex2bin(substr($msg, 54, 4)),0,9))));
            printxml("rgtu","Numéro d'ETU",bin2hex(substr(hex2bin(substr($msg, 54, 4)),10,7)));
            printxml("ndch","Numéro de point de détection",substr($msg, 58, 2),$xmldic->{cause}->{codm}->{$codm}->{ndch}->{substr($msg, 58, 2)}->{desc});
        }
        else
        {
            printxml("asml","Adresse système de la ML en surcharge",substr($msg, 54, 4),$xmldic->{asml}->{as}->{substr($msg, 55, 3)}->{desc});
            printxml("ndch","Numéro de point de détection",substr($msg, 58, 2),$xmldic->{cause}->{codm}->{$codm}->{ndch}->{substr($msg, 58, 2)}->{desc});
        }
        printxml("etch","Etat de charge",substr($msg, 60, 2),$xmldic->{charge}->{etch}->{substr($msg, 60, 2)}->{desc});
        printxml("evch","Evènement de charge",substr($msg, 62, 2),$xmldic->{charge}->{evch}->{substr($msg, 62, 2)}->{desc});
        printxml("infc","Informations complémentaires",substr($msg, 64, 16));
        printxml("asmla","Adresse système de la ML autonome",substr($msg, 80, 4),$xmldic->{asml}->{as}->{substr($msg, 81, 3)}->{desc});
        printxml("etcha","Etat de charge résultant pour la ML autonome",substr($msg, 84, 2),$xmldic->{charge}->{etch}->{substr($msg, 84, 2)}->{desc});
        printxml("nmes","Numéro du message (circulaire)",substr($msg, 88, 4));
    }
    
    elsif ($codm eq "AF71")
    {
        if ( substr($msg, 55, 1) eq "2" )
        {
            printxml("etac","Etat courant",substr($msg, 55, 1),"BLOS (Bloqué système)");
        }
        else
        {
            printxml("etac","Etat courant", substr($msg, 55, 1),$xmldic->{pe}->{etac}->{substr($msg, 55, 1)}->{desc});
        }
    }
    
    elsif ($codm eq "AF73")
    {
        my $adetp = substr($msg, 54, 4);
        my $adetpbin = hex2bin($adetp);
        my $tyro = hex(bin2hex(substr($adetpbin,0,2)));
        my $rgtu = hex(bin2hex(substr($adetpbin,2,9)));
        my $rget = hex(bin2hex(substr($adetpbin,11,5)));
        $outxml->startTag('info','sigle' => 'adetp');
        $outxml->startTag('code');
        $outxml->characters('adetp');
        $outxml->endTag('code');
        $outxml->startTag('nom');
        $outxml->characters("Adresse de l'ETP");
        $outxml->endTag('nom');
        $outxml->startTag('valeur');
        $outxml->characters($adetp);
        $outxml->endTag('valeur');
        printxml("tyro","Type de routage",$tyro);
        printxml("rgtu","Numéro d'ETU (1 à 128)",$rgtu);
        printxml("rget","Rand du premier ET de l'ETP (1 à 31)",$rget);
        $outxml->endTag('info');
        printxml("cetu","Numéro d'évènement",substr($msg, 58, 2),$xmldic->{cause}->{codm}->{$codm}->{evt}->{substr($msg, 58, 2)}->{desc});
        printxml("posptu","Positionnement primaire de l'ETU",substr($msg, 60, 1),$xmldic->{cause}->{codm}->{$codm}->{posptu}->{substr($msg, 60, 1)}->{desc});
        printxml("etatpu","Etat courant de l'ETU",substr($msg, 61, 1),$xmldic->{cause}->{codm}->{$codm}->{etatpu}->{substr($msg, 61, 1)}->{desc});

        # si mise HS sur Faute
        if ( substr($msg, 58, 2) eq "01" )
        {
            printxml("type","Type d'évènement",substr($msg, 64, 2),$xmldic->{cause}->{codm}->{$codm}->{evt}->{substr($msg, 58, 2)}->{type}->{substr($msg, 64, 2)}->{desc});
            printxml("asml","Adresse système de la ML accusatrice",substr($msg, 66, 4),$xmldic->{asml}->{as}->{substr($msg, 67, 3)}->{desc});
            printxml("mpcc","Classe code du message d'accusation",substr($msg, 70, 4),$xmldic->{cause}->{codm}->{$codm}->{evt}->{substr($msg, 58, 2)}->{mpcc}->{substr($msg, 70, 4)}->{desc});

            $outxml->startTag('info','sigle' => 'infc');
            printxml("inf1","Informations complémentaires",substr($msg, 74, 4));
            printxml("inf2","Informations complémentaires",substr($msg, 78, 4));
            printxml("inf3","Informations complémentaires",substr($msg, 82, 2));
            $outxml->endTag('info');
            printxml("mpccu","Classe code du message d'accusation",substr($msg, 84, 4),$xmldic->{cause}->{codm}->{$codm}->{evt}->{substr($msg, 58, 2)}->{mpcc}->{substr($msg, 84, 4)}->{desc},"Si accusation MLSM-U");
        }
        
        # sinon si fin Locavar ETP KO
        elsif ( substr($msg, 58, 2) eq "02" )
        {
            printxml("phad","Phase de diagnostic",substr($msg, 64, 2),$xmldic->{cause}->{codm}->{$codm}->{evt}->{substr($msg, 58, 2)}->{phad}->{substr($msg, 64, 2)}->{desc});
            if ( substr($msg, 64, 2) eq "02" )
            {
                printxml("pdia","Diagnostique locavar",substr($msg, 66, 2),$xmldic->{locavar}->{etu}->{pdia}->{substr($msg, 66, 2)}->{desc});
                printxml("iddi","Information du diagnostique",substr($msg, 68, 40));
            }
            else
            {
                printxml("npro", "Numéro de processus", substr($msg, 74, 4));
                printxml("ndls", "Numéro/Etat du service", substr($msg, 78, 4));
                printxml("ci", "Code interne message", substr($msg, 82, 2));
                printxml("mpcc", "Classe et codm à l'origine", substr($msg, 84, 4));
            }
        }
        
        # sinon si positionnement par RHM
        elsif ( substr($msg, 58, 2) eq "03" )
        {
            printxml("coco","Code de commande",substr($msg, 64, 2),$xmldic->{cause}->{codm}->{$codm}->{evt}->{substr($msg, 58, 2)}->{coco}->{substr($msg, 64, 2)}->{desc});
        }
        
        # sinon si basculement sur ETU de secours
        elsif ( substr($msg, 58, 2) eq "05" )
        {
            printxmlnum("icom","0","Code d'erreur",substr($msg, 64, 2),$xmldic->{cause}->{codm}->{$codm}->{icom0}->{substr($msg, 64, 2)}->{desc});
            printxmlnum("icom","1","RGTU de l'ETU de secours", hex(substr($msg, 66, 2)));
            printxmlnum("icom","2","RGTU de l'ETU secouru", hex(substr($msg, 68, 2)));
        }

        # sinon si retour sur ETU normal
        elsif ( substr($msg, 58, 2) eq "06" )
        {
            printxmlnum("icom","0","Code d'erreur",substr($msg, 64, 2),$xmldic->{cause}->{codm}->{$codm}->{icom0}->{substr($msg, 64, 2)}->{desc});
            printxmlnum("icom","1","RGTU de l'ETU de secours", hex(substr($msg, 66, 2)));
            printxmlnum("icom","2","RGTU de l'ETU secouru", hex(substr($msg, 68, 2)));
        }

        # sinon si echec basculement sur ETU de secours
        elsif ( substr($msg, 58, 2) eq "07" )
        {
            printxmlnum("icom","0","Code d'erreur",substr($msg, 64, 2),$xmldic->{cause}->{codm}->{$codm}->{icom0}->{substr($msg, 64, 2)}->{desc});
            printxmlnum("icom","1","RGTU de l'ETU de secours", hex(substr($msg, 66, 2)));
            printxmlnum("icom","2","RGTU de l'ETU secouru", hex(substr($msg, 68, 2)));
            printxmlnum("icom","3","RTU de l'ETU de secours (position dans le rack", hex(substr($msg, 70, 2)), substr($msg, 70, 2));
            if ( substr($msg, 64, 2) eq "01" || substr($msg, 64, 2) eq "11" )
            {
                printxml("tuCause","Cause TU local (TU de secours)",substr($msg, 72, 2));
                printxml("rtuCause","Cause TU distant (TU à secourir)",substr($msg, 74, 2));
                printxmlnum("alsCause","0","Cause TU ALS",substr($msg, 76, 2));
                printxmlnum("alsCause","1","Cause TU ALS",substr($msg, 78, 2));
            }
        }
    }
    
    elsif ($codm eq "AF80" )
    {
        printxml("opti", "Option d'initialisation",substr($msg, 54, 4),$xmldic->{cause}->{codm}->{$codm}->{opti}->{substr($msg, 56, 2)}->{desc});
        printxml("etas", "Etat sytème", substr($msg, 58, 1), $xmldic->{es}->{etas}->{substr($msg, 58, 1)}->{desc});
        printxml("iac", "Indicateur d'avancement", substr($msg, 59, 1), $xmldic->{es}->{etas}->{substr($msg, 58, 1)}->{iac}->{substr($msg, 59, 1)}->{desc});
        printxml("nivs", "Niveau de fct du système", substr($msg, 60, 2), $xmldic->{ni}->{nivs}->{substr($msg, 60, 2)}->{desc});
        printxml("swidft", "Origine du basculement", substr($msg, 66, 4), $xmldic->{cause}->{codm}->{$codm}->{swidft}->{substr($msg, 66, 4)}->{desc});
    }
    
    elsif ($codm eq "AF82")
    {
        # Aucune info complémentaire à décoder
    }
    elsif ($codm eq "AF90")
    {
        if ( length($msg) < 342 )
        {
            printxml("codi", "Code Interne", substr($msg, 54, 4), $xmldic->{cause}->{codm}->{$codm}->{codi}->{substr($msg, 54, 4)}->{desc});
            if ( substr($msg, 54, 4) eq "0001" )
            {
                printxml("asml", "Adresse système de la station",substr($msg, 62, 4), $xmldic->{asml}->{as}->{substr($msg, 63, 3)}->{desc});
            }
            elsif (substr($msg, 54, 4) eq "0002" )
            {
                printxml("cchg","Code de chargement",substr($msg, 66, 4),$xmldic->{cause}->{codm}->{$codm}->{cchg}->{substr($msg, 66, 4)}->{desc});
                printxml("etas", "Etat sytème", substr($msg, 70, 1), $xmldic->{es}->{etas}->{substr($msg, 70, 1)}->{desc});
                printxml("iac", "Indicateur d'avancement", substr($msg, 71, 1), $xmldic->{es}->{etas}->{substr($msg, 70, 1)}->{iac}->{substr($msg, 71, 1)}->{desc});
                printxml("nivs", "Niveau de fct du système", substr($msg, 72, 2), $xmldic->{ni}->{nivs}->{substr($msg, 72, 2)}->{desc});
            }
        }
        else
        {
            printxml("tindl", "Tempo d'attente de libé", substr($msg, 78, 4));
            printxml("nbcc", "Nb context ML TX", substr($msg, 82, 4));
            printxml("lsta", "Liste des stations",substr($msg, 86));
        }
    }
    elsif ($codm eq "AFA1" )
    {
        if ( length($msg) <= 54 )
        {
            printxml("tyfm","Format du message","","Court");
        }
        else
        {
            printxml("tyfm","Format du message","","Long");
            printxml("typt","Type de traitement",substr($msg, 54, 4),$xmldic->{cause}->{codm}->{$codm}->{typt}->{substr($msg, 54, 4)}->{desc});
            printxml("nfcsm","Nombre d'article modifiés du fichier FCSM", substr($msg, 58, 4));

            $outxml->startTag('info','sigle' => 'lfcsm');
            $outxml->startTag('code');
            $outxml->characters('lfcsm');
            $outxml->endTag('code');
            $outxml->startTag('nom');
            $outxml->characters("Articles FSCM");
            $outxml->endTag('nom');
            $outxml->startTag('detail');
            $outxml->characters("Numéro et contenu des articles FSCM modifiés");
            $outxml->endTag('detail');

            $offset = 62;
            for (my $i=0; $i<4; $i++)
            {
                if ( substr($msg, $offset, 4) ne "0000" )
                {
                    printxml("apsm","Adresse physique de la station",substr($msg, $offset, 4),calcapml(substr($msg, $offset+1, 3)));
                    printxml("fcsm","Contenu de l'article FCSM",substr($msg, $offset+4, 100));
                }
                $offset = $offset + 104;
            }
            $outxml->endTag('info');
            
            printxml("nfcas","Nombre d'article modifiés du fichier FCAS", substr($msg, 478, 4));

            $outxml->startTag('info','sigle' => 'lfcas');
            $outxml->startTag('code');
            $outxml->characters('lfcas');
            $outxml->endTag('code');
            $outxml->startTag('nom');
            $outxml->characters("Articles FCAS");
            $outxml->endTag('nom');
            $outxml->startTag('detail');
            $outxml->characters("Numéro et contenu des articles FSAS modifiés");
            $outxml->endTag('detail');

            $offset = 482;
            for (my $i=0; $i<16; $i++)
            {
                if ( substr($msg, $offset, 4) ne "0000" )
                {
                    printxml("asml","Adresse système de la station",substr($msg, $offset, 4),$xmldic->{asml}->{as}->{substr($msg, $offset+1, 3)}->{desc});
                    printxml("fcas","Contenu de l'article FCSM",substr($msg, $offset+4, 12));
                }
                $offset = $offset + 16;
            }
            $outxml->endTag('info');
            
        }
    }
    else
    {
        printxml("erreur","cdom inconnu ou pas encore implémenté");
    }
    $outxml->endTag('infocomp');
}

# Fin fonction de décodage des information complémentaire en fonction de codm
################################################################################


################################################################################
# Fonction de recherche de la cause d'erreur appelée lorsque codm = AE11
sub getcause
{
    my $msg   = $_[0];
    my $asmc  = substr($msg, 127, 3);
    my $caus  = substr($msg, 122, 4);
    my $pare0 = substr($msg, 130, 4);
    my $pare1 = substr($msg, 134, 4);

    # définition du tableau pour pointer sur le bon champs XML de la cause
    my @origine;
    $origine[0][0]  = "SMB";
    $origine[0][1]  = "SMB";
    $origine[1][0]  = "TR|TX|MQ";
    $origine[1][1]  = "TRTXMQ";
    $origine[2][0]  = "COM1G";
    $origine[2][1]  = "COM1G";
    $origine[3][0]  = "COM2G";
    $origine[3][1]  = "COM2G";
    $origine[4][0]  = "GX";
    $origine[4][1]  = "GX";
    $origine[5][0]  = "PC|PUPE";
    $origine[5][1]  = "PCPUPE";
    $origine[6][0]  = "MR|CC|GS";
    $origine[6][1]  = "MRCCGS";
    $origine[7][0]  = "AN|MGI";
    $origine[7][1]  = "ANMGI";
    $origine[8][0]  = "URM1G";
    $origine[8][1]  = "URM1G";
    $origine[9][0]  = "URM2G";
    $origine[9][1]  = "URM2G";
    $origine[10][0] = "ETA";
    $origine[10][1] = "ETA";

    my $trouve = 0;

    if ($caus eq "0000")
    {
        printxml("caus","Cause de l'echec de positionnement",$caus,$xmldic->{echec}->{communs}->{caus}->{$caus}->{desc});
    }
    else
    {
        for (my $i = 0 ; $i < 11 ; $i++)
        {
            if ($xmldic->{asml}->{as}->{$asmc}->{desc} =~ m/$origine[$i][0]/)
            {
                if ($xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{desc})
                {
                    printxml("caus","Cause de l'echec de positionnement",$caus,$xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{desc});
                    printxml("asmc","Adresse de la ML cause de l'echec","0".$asmc,$xmldic->{asml}->{as}->{$asmc}->{desc});
                    if ( $xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{pare0}->{$pare0}->{desc} )
                    {
                        printxml("pare0","Paramètre de l'echec 0",$pare0,$xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{pare0}->{$pare0}->{desc});
                    }
                    elsif ( $xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{pare0}->{substr($pare0,0,3)}->{desc} )
                    {
                        printxml("pare0","Paramètre de l'echec 0",$pare0,$xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{pare0}->{substr($pare0,0,3)}->{desc});
                    }
                    elsif ( $xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{pare0}->{substr($pare0,0,2)}->{desc} )
                    {
                        printxml("pare0","Paramètre de l'echec 0",$pare0,$xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{pare0}->{substr($pare0,0,2)}->{desc});
                    }
                    elsif ( $xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{pare0}->{substr($pare0,0,1)}->{desc} )
                    {
                        printxml("pare0","Paramètre de l'echec 0",$pare0,$xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{pare0}->{substr($pare0,0,1)}->{desc});
                    }
                    else
                    {
                        printxml("pare0","Paramètre de l'echec 0",$pare0,$xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{pare0}->{$pare0}->{desc});
                    }
                    
                    if ( $xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{pare1}->{$pare1}->{desc} )
                    {
                        printxml("pare1","Paramètre de l'echec 1",$pare1,$xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{pare1}->{$pare1}->{desc});
                    }
                    elsif ( $xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{pare1}->{substr($pare1,0,3)}->{desc} )
                    {
                        printxml("pare1","Paramètre de l'echec 1",$pare1,$xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{pare1}->{substr($pare1,0,3)}->{desc});
                    }
                    elsif ( $xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{pare1}->{substr($pare1,0,2)}->{desc} )
                    {
                        printxml("pare1","Paramètre de l'echec 1",$pare1,$xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{pare1}->{substr($pare1,0,2)}->{desc});
                    }
                    elsif ( $xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{pare1}->{substr($pare1,0,1)}->{desc} )
                    {
                        printxml("pare1","Paramètre de l'echec 1",$pare1,$xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{pare1}->{substr($pare1,0,1)}->{desc});
                    }
                    else
                    {
                        printxml("pare1","Paramètre de l'echec 1",$pare1,$xmldic->{echec}->{$origine[$i][1]}->{caus}->{$caus}->{pare1}->{$pare1}->{desc});
                    }
                }
                else
                {
                    printxml("caus","Cause de l'echec de positionnement",$caus,$xmldic->{echec}->{communs}->{caus}->{$caus}->{desc});
                    printxml("asmc","Adresse de la ML cause de l'echec","0".$asmc,$xmldic->{asml}->{as}->{$asmc}->{desc});
                    if ( $xmldic->{echec}->{communs}->{caus}->{$caus}->{pare0}->{$pare0}->{desc} )
                    {
                        printxml("pare0","Paramètre de l'echec 0",$pare0,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare0}->{$pare0}->{desc});
                    }
                    elsif ( $xmldic->{echec}->{communs}->{caus}->{$caus}->{pare0}->{substr($pare0,0,3)}->{desc} )
                    {
                        printxml("pare0","Paramètre de l'echec 0",$pare0,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare0}->{substr($pare0,0,3)}->{desc});
                    }
                    elsif ( $xmldic->{echec}->{communs}->{caus}->{$caus}->{pare0}->{substr($pare0,0,2)}->{desc} )
                    {
                        printxml("pare0","Paramètre de l'echec 0",$pare0,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare0}->{substr($pare0,0,2)}->{desc});
                    }
                    elsif ( $xmldic->{echec}->{communs}->{caus}->{$caus}->{pare0}->{substr($pare0,0,1)}->{desc} )
                    {
                        printxml("pare0","Paramètre de l'echec 0",$pare0,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare0}->{substr($pare0,0,1)}->{desc});
                    }
                    else
                    {
                        printxml("pare0","Paramètre de l'echec 0",$pare0,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare0}->{$pare0}->{desc});
                    }

                    if ( $xmldic->{echec}->{communs}->{caus}->{$caus}->{pare1}->{$pare1}->{desc} )
                    {
                        printxml("pare1","Paramètre de l'echec 1",$pare1,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare1}->{$pare1}->{desc});
                    }
                    elsif ( $xmldic->{echec}->{communs}->{caus}->{$caus}->{pare1}->{substr($pare1,0,3)}->{desc} )
                    {
                        printxml("pare1","Paramètre de l'echec 1",$pare1,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare1}->{substr($pare1,0,3)}->{desc});
                    }
                    elsif ( $xmldic->{echec}->{communs}->{caus}->{$caus}->{pare1}->{substr($pare1,0,2)}->{desc} )
                    {
                        printxml("pare1","Paramètre de l'echec 1",$pare1,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare1}->{substr($pare1,0,2)}->{desc});
                    }
                    elsif ( $xmldic->{echec}->{communs}->{caus}->{$caus}->{pare1}->{substr($pare1,0,1)}->{desc} )
                    {
                        printxml("pare1","Paramètre de l'echec 1",$pare1,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare1}->{substr($pare1,0,1)}->{desc});
                    }
                    else
                    {
                        printxml("pare1","Paramètre de l'echec 1",$pare1,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare1}->{$pare1}->{desc});
                    }
                }
                $trouve = 1;
            }
        }

        if ($trouve == 0)
        {
            printxml("caus","Cause de l'echec de positionnement",$caus,$xmldic->{echec}->{communs}->{caus}->{$caus}->{desc});
            printxml("asmc","Adresse de la ML cause de l'echec","0".$asmc,$xmldic->{asml}->{as}->{$asmc}->{desc});
            if ( $xmldic->{echec}->{communs}->{caus}->{$caus}->{pare0}->{$pare0}->{desc} )
            {
                printxml("pare0","Paramètre de l'echec 0",$pare0,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare0}->{$pare0}->{desc});
            }
            elsif ( $xmldic->{echec}->{communs}->{caus}->{$caus}->{pare0}->{substr($pare0,0,3)}->{desc} )
            {
                printxml("pare0","Paramètre de l'echec 0",$pare0,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare0}->{substr($pare0,0,3)}->{desc});
            }
            elsif ( $xmldic->{echec}->{communs}->{caus}->{$caus}->{pare0}->{substr($pare0,0,2)}->{desc} )
            {
                printxml("pare0","Paramètre de l'echec 0",$pare0,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare0}->{substr($pare0,0,2)}->{desc});
            }
            elsif ( $xmldic->{echec}->{communs}->{caus}->{$caus}->{pare0}->{substr($pare0,0,1)}->{desc} )
            {
                printxml("pare0","Paramètre de l'echec 0",$pare0,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare0}->{substr($pare0,0,1)}->{desc});
            }
            else
            {
                printxml("pare0","Paramètre de l'echec 0",$pare0,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare0}->{$pare0}->{desc});
            }

            if ( $xmldic->{echec}->{communs}->{caus}->{$caus}->{pare1}->{$pare1}->{desc} )
            {
                printxml("pare1","Paramètre de l'echec 1",$pare1,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare1}->{$pare1}->{desc});
            }
            elsif ( $xmldic->{echec}->{communs}->{caus}->{$caus}->{pare1}->{substr($pare1,0,3)}->{desc} )
            {
                printxml("pare1","Paramètre de l'echec 1",$pare1,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare1}->{substr($pare1,0,3)}->{desc});
            }
            elsif ( $xmldic->{echec}->{communs}->{caus}->{$caus}->{pare1}->{substr($pare1,0,2)}->{desc} )
            {
                printxml("pare1","Paramètre de l'echec 1",$pare1,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare1}->{substr($pare1,0,2)}->{desc});
            }
            elsif ( $xmldic->{echec}->{communs}->{caus}->{$caus}->{pare1}->{substr($pare1,0,1)}->{desc} )
            {
                printxml("pare1","Paramètre de l'echec 1",$pare1,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare1}->{substr($pare1,0,1)}->{desc});
            }
            else
            {
                printxml("pare1","Paramètre de l'echec 1",$pare1,$xmldic->{echec}->{communs}->{caus}->{$caus}->{pare1}->{$pare1}->{desc});
            }
        }
    }
}

# Fin fonction de recherche de la cause d'erreur appelée lorsque codm = AE11
################################################################################

################################################################################
# Fonction de calcul des Adresses Physique des Stations
sub calcapml
{
    my $apml = shift;
    my $asmldec;
    my $asml;
    
    if ($apml eq "801E")
    {
    		return "OM";
    }
    if ($apml =~ m/^0+$/)
    {
    		if ( $apml =~ m/0{4}/ )
    		{
    				$apml =~ s/^0//;
    		}
    		$asml = $apml;
    		return $xmldic->{asml}->{as}->{$asml}->{desc}
    }
    else
    {
    		if (length($apml) == 4 )
    		{
    				$apml =~ s/^.//;
    		}
    		$asmldec = hex($apml) + 768;
    		$asml = sprintf("%x", $asmldec);
    		$asml =~ tr/a-z/A-Z/;
    		return $xmldic->{asml}->{as}->{$asml}->{desc};
    }
}

# Fin fonction de convertion d'un nombre Hexadécimal en Binaire
################################################################################

################################################################################
# Fonction de convertion d'un nombre Hexadécimal en Binaire
sub hex2bin
{
    my $h = shift;
    my $hlen = length($h);
    my $blen = $hlen*4;
    return unpack("B$blen", pack("H$hlen", $h));
}

# Fin fonction de convertion d'un nombre Hexadécimal en Binaire
################################################################################

################################################################################
# Fonction de convertion d'un nombre Binaire en Hexadécimal
sub bin2hex
{
    my $b = shift;
    my $blen = length($b);
    my $modulo;
    while ( $blen%4 != 0 )
    {
        $b = "0".$b;
        $blen = length($b);
    }
    my $hlen = $blen/4;
    my $h =unpack("H$hlen", pack("B$blen", $b));
    $h =~ tr/a-z/A-Z/;
    return $h;
}

# Fin fonction de convertion d'un nombre Binaire en Hexadécimal
################################################################################

################################################################################
# Fonction Gestion des accents sous DOS
sub ActiverAccentDOS {
  my ($codepage) = ( `chcp` =~ m/:\s+(\d+)/ );
  foreach my $h ( \*STDOUT, \*STDERR, \*STDIN ) {
    binmode $h, ":encoding(cp$codepage)";
  }
}

# Fin Fonction Gestion des accents sous DOS
################################################################################