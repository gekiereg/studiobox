#!/bin/bash

# variables générales
FICHIERCS='.Scripts/config/cs'
FICHIERPM='.Scripts/config/pm'
FICHIERQDIFF='.Scripts/config/qdiff'
FICHIERQREC='.Scripts/config/qrec'
IP=$(sudo ifconfig  | grep 'inet adr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')

function configPM {
# formulaire zenity
CFPM=$(zenity --forms \
    --title="Configuration du point de diffusion" \
    --text="Définition du point de montage et du mot de passe" \
    --add-entry="Nom du point de diffusion (sous la forme etab-type-ville.mp3 ou etab-type-ville.ogg" \
    --add-password="Mot de passe" \
    --add-password="Confirmer le mot de passe" \
    --separator="|" 2>/dev/null)
# possibilité d'annuler la config en cliquant sur annuler
if [ "$?" -eq 1 ]; then
    exit
fi

# récupération des valeurs
point=$(echo $CFPM | cut -d"|" -f1)
pass=$(echo $CFPM | cut -d"|" -f2)
pass1=$(echo $CFPM | cut -d"|" -f3)
while [ "$pass" !=  "$pass1" ] || [ -z "$pass" ]; do
zenity --info --title="Mot de passe?" --text="Les mots de passe ne coïncident pas. Relance 
de la configuration du point de diffusion."
CFPASS=$(zenity --forms \
    --title="Configuration du mot de passe" \
    --text="Définition du mot de passe" \
    --add-password="Mot de passe" \
    --add-password="Confirmer le mot de passe" \
    --separator="|" 2>/dev/null)
pass=$(echo $CFPASS | cut -d"|" -f1)
pass1=$(echo $CFPASS | cut -d"|" -f2)
done

##Nommer le point de montage.Tant que la variable est vide attente de la saisie.
#while [ -z ${point[$i]} ]; do
#read -p "Veuillez saisir le nom du point de montage : " point
#done
#
##Tant que la variable est vide, j'attends la saisie
#while [ -z ${pass[$i]} ]; do
#read -p "Veuillez saisir le mot de passe: " pass
#done

echo "pm,$point
pass,$pass" > $FICHIERPM
zenity --info --title="Point de diffusion configuré" --text="Le point de diffusion qui sera utilisé est $point.
Les auditeurs pourront vous écouter à l'adresse suivante: http://webradio.ac-versailles.fr/$point" 2>/dev/null
}

function configCS {
FICHIERCS='.Scripts/config/cs'
FICHIERCS2='.Scripts/config/cs2'

CARTES=$(aplay -l | grep ^carte)
aplay -l | grep ^carte > $FICHIERCS
sed -i 's/ /_/g' $FICHIERCS

LISTECARTES=$(cat $FICHIERCS)

CARTE=$(zenity --entry --title="Configuration de la carte son" --text="Veuillez indiquer la carte son à utiliser" $LISTECARTES 2>/dev/null)

nombre=$(echo $CARTE | cut -d":" -f1 | tail -c2)
nombre1=$(echo $CARTE | cut -d":" -f2 | tail -c2)

##Jusqu'a ce que la reponse soit composée par un nombre, j'attends la saisie
#until [[ ${nombre} =~ ^[0-9]+$ ]]; do
#read -p "Quel est l'identifiant de la carte à utiliser ? (0, 1, etc.): " nombre
#done
#
#NBRECARTES=$(aplay -l | grep ^"carte $nombre" | wc -l)
#
##si plusieurs cartes ont le même identifiant, on choisit par le numéro de périphérique
#if [ $NBRECARTES -ge 2 ]; then
#	echo "Plusieurs cartes sont identifiées par le chiffre $nombre"
#	echo "Indiquez le numéro de 'périphérique' de la carte à utiliser"
#	echo "(en cas de doute, indiquez '0')"
#	aplay -l | grep ^"carte $nombre"
#	until [[ ${nombre1} =~ ^[0-9]+$ ]]; do
#		read -p "Quel est l'identifiant du périphérique de la carte à utiliser ? (0, 1, etc.): " nombre1
#	done
#else
#	nombre1="0"
#fi

echo "$nombre,$nombre1" > $FICHIERCS
CARTEOK=$(aplay -l | grep ^"carte $nombre" | grep "périphérique $nombre1")
	zenity --info --title="Carte son configurée" --text="La configuration est maintenant terminée. Au prochain enregistrement ou à la prochaine diffusion, la carte suivante sera utilisée:
$CARTEOK" 2>/dev/null
}

function verifIP {
if  [ -z "$IP" ]; then
	zenity --info --title="Diffusion impossible" --text="Studiobox ne possède pas d'adresse sur le réseau de 
l'établissement: il est donc impossible de procéder à une diffusion. Vous pouvez par contre lancer un enregistrement." 2>/dev/null
	exit
fi
}

function verifCS {
nombre=$(cat $FICHIERCS | cut -d"," -f1)
nombre1=$(cat $FICHIERCS | cut -d"," -f2)
DISPO=$(aplay -l | grep ^"carte $nombre" |  grep "périphérique $nombre1")
if [ -z "$DISPO" ] || [ -z "$nombre" ] ; then
        zenity --info --title="Carte son indisponible" --text="Il semblerait que la carte son configurée soit indisponible.
Veuillez la reconfigurer (menu 'Outils WebRadio' > 'Configurer la webradio' > 'Configurer la carte son des flux')" 2>/dev/null
	exit
fi
}

function verifPM {
TYPEPM=$(cat $FICHIERPM | grep ^pm | cut -d"," -f2 | cut -d"." -f2)
if [ "$TYPEPM" != ogg ] && [ "$TYPEPM" != mp3 ]; then
	zenity --info --text="Votre point de diffusion est mal ou non configuré (il doit être de forme 'type-nom-ville.mp3' ou 'type-nom-ville.ogg'.
Veuillez le reconfigurer (menu 'Outils WebRadio' > 'Configurer la webradio' > 'Configurer le point de diffusion radio')" 2>/dev/null
	exit
fi
}

function configQREC {
QREC=$(zenity --scale --min-value=1 --max-value=9 --value=9 --title="Qualité de l'enregistrement" --text="Choisissez la qualité de l'enregistrement. (1 = très faible, 9 = excellente)")
echo $QREC > $FICHIERQREC
}

function configQDIFF {
QDIFF=$(zenity --scale --min-value=1 --max-value=10 --value=5 --title="Qualité de la diffusion" --text="Choisissez la qualité de la diffusion. (1 = très faible, 9 = excellente)")
echo $QDIFF > $FICHIERQDIFF
}

function verifQREC {
CHIFFREVORBISREC=$(cat $FICHIERQREC)
if [ -n $CHIFFREVORBIS ]; then
	QUALITEVORBISREC="quality=0.$CHIFFREVORBISREC"
else
	QUALITEVORBISREC="quality=0.6"
fi
}

function verifQDIFF {
if [ "$1" = local ] || [ "$1" = airtime ] ; then
	CHIFFREVORBISDIFF=$(cat $FICHIERQDIFF)
	if [ -n $CHIFFREVORBISDIFF ]; then
		QUALITEVORBISDIFF="quality=0.$CHIFFREVORBISDIFF"
	else
		QUALITEVORBISDIFF="quality=0.7"
	fi
else
	if [ "$TYPEPM" = ogg ]; then
		CHIFFREVORBISDIFF=$(cat $FICHIERQDIFF)
		if [ -n $CHIFFREVORBISDIFF ]; then
			QUALITEVORBISDIFF="quality=0.$CHIFFREVORBISDIFF"
		else
			QUALITEVORBISDIFF="quality=0.5"
		fi
	else
		CHIFFREMP3DIFF=$(cat $FICHIERQDIFF)
		if [ -n $CHIFFREMP3DIFF ]; then
			case $CHIFFREMP3DIFF in
				'1' | '2')
				QUALITEMP3DIFF='bitrate=64'
				;;
				'3' | '4')
				QUALITEMP3DIFF='bitrate=96'
				;;
				'5' | '6')
				QUALITEMP3DIFF='bitrate=128'
				;;
				'7' | '8')
				QUALITEMP3DIFF='bitrate=256'
				;;
				'9')
				QUALITEMP3DIFF='bitrate=320'
				;;
			esac
		else
			QUALITEMP3DIFF='bitrate=128'
		fi	
	fi
fi
}

function verifINT {
wget -q --tries=20 --timeout=10 http://www.google.com -O /tmp/google.idx &> /dev/null
if [ ! -s /tmp/google.idx ]
then
	zenity --info --text="Vous n'êtes pas connecté à internet. La diffusion est impossible." 2>/dev/null
	exit
else
	rm /tmp/google.idx
fi
}

function verifAIR {
CONFAIR=$(cat /etc/airtime/liquidsoap.cfg | grep ^master_live_stream_mp | grep $PMAIRTIME)
if [ -z "$CONFAIR" ]; then
	zenity --info --title="Configurer Airtime" --text="Pour diffuser un flux vers Airtime, celui-ci doit être configuré.
	Vous trouverez une description précise de la configuration à effectuer dans 'Documents/memento_airtime.pdf'
	(rubrique 'Configurer Airtime > Configuration des flux')" 2>/dev/null
	exit
fi
}

# variables liquidsoap
PORTICECAST='8000'
PORTAIRTIME='8001'
PMLOCAL='webradio.ogg'
PMACAD=$(cat $FICHIERPM | grep ^pm | cut -d"," -f2)
PASSACAD=$(cat $FICHIERPM | grep ^pass | cut -d"," -f2)
PMAIRTIME='webradio.ogg'
PASSLOCAL='webradio'
PASSAIRTIME='webradio'
USERAIRTIME='source'
SERVEURACAD='webradio.ac-versailles.fr'
SERVEURLOCAL='localhost'
REPREC='Enregistrements'
FICHIERREC='%Y-%m-%d-%H_%M_%S.ogg'
# variables zenity
TEXTEZENREC="Vous retrouverez l'enregistrement dans le répertoire '$REPREC' (fichier .ogg horodaté)."
TEXTEZENDIFFLOCAL="Le direct se lancera quand vous validerez cette boîte de dialogue.
Pour vous écouter sur le réseau de l'établissement, ouvrir un navigateur web et y indiquer l'url suivante:
http://$IP:$PORTICECAST/$PMLOCAL"
TEXTEZENDIFFINT="La diffusion commencera quand vous validerez cette boîte de dialogue.
Les auditeurs pourront vous écouter à l'adresse suivante:
http://$SERVEURACAD/$PMACAD"
TEXTEZENAIR="Le flux radio sera envoyé vers le serveur Airtime quand vous validerez cette boîte de dialogue.
Pour diffuser ce flux sur internet, ouvrez Airtime et basculez la source de flux sur 'Source Maître'"

function difflocal {
zenity --info --title="Diffusion en direct" --text="$TEXTEZENDIFFLOCAL" 2>/dev/null
liquidsoap "output.icecast(%vorbis($QUALITEVORBISDIFF), mount=\"$PMLOCAL\",host=\"$SERVEURLOCAL\", port=$PORTICECAST , password=\"$PASSLOCAL\",input.alsa(device=\"hw:$nombre,$nombre1\"))"
}

function difflocalrec {
zenity --info --title="Diffusion et enregistrement" --text="$TEXTEZENDIFFLOCAL
$TEXTEZENREC" 2>/dev/null
liquidsoap "s=output.icecast(%vorbis($QUALITEVORBISDIFF), mount=\"$PMLOCAL\",host=\"$SERVEURLOCAL\", port=$PORTICECAST , password=\"$PASSLOCAL\",input.alsa(device=\"hw:$nombre,$nombre1\")) output.file(%vorbis($QUALITEVORBISREC),\"~/$REPREC/$FICHIERREC\",s)"
}

function localrec {
zenity --info --title="Enregistrement" --text="L'enregistrement se lancera quand vous fermerez cette fenêtre.
$TEXTEZENREC" 2>/dev/null
liquidsoap "output.file(%vorbis($QUALITEVORBISREC),\"~/$REPREC/$FICHIERREC\",input.alsa(device=\"hw:$nombre,$nombre1\"))"
}

function diffinternet {
zenity --info --title="Diffusion en direct sur internet" --text="$TEXTEZENDIFFINT" 2>/dev/null
if [ "$TYPEPM" = "ogg" ]; then
liquidsoap "output.icecast(%vorbis($QUALITEVORBISDIFF), mount=\"$PMACAD\",host=\"$SERVEURACAD\", port=$PORTICECAST , password=\"$PASSACAD\",input.alsa(device=\"hw:$nombre,$nombre1\"))"
else
liquidsoap "output.icecast(%mp3($QUALITEMP3DIFF), mount=\"$PMACAD\",host=\"$SERVEURACAD\", port=$PORTICECAST , password=\"$PASSACAD\",input.alsa(device=\"hw:$nombre,$nombre1\"))"
fi
}

function diffinternetrec {
zenity --info --title="Diffusion en direct sur internet" --text="$TEXTEZENDIFFINT
$TEXTEZENREC" 2>/dev/null 
if [ "$TYPEPM" = "ogg" ]; then
	liquidsoap "s=output.icecast(%vorbis($QUALITEVORBISDIFF), mount=\"$PMACAD\",host=\"$SERVEURACAD\", port=$PORTICECAST , password=\"$PASSACAD\",input.alsa(device=\"hw:$nombre,$nombre1\")) output.file(%vorbis($QUALITEVORBISREC),\"~/$REPREC/$FICHIERREC\",s)"
else
	liquidsoap "s=output.icecast(%mp3($QUALITEMP3DIFF), mount=\"$PMACAD\",host=\"$SERVEURACAD\", port=$PORTICECAST , password=\"$PASSACAD\",input.alsa(device=\"hw:$nombre,$nombre1\")) output.file(%vorbis($QUALITEVORBISREC),\"~/$REPREC/$FICHIERREC\",s)"
fi
}

function diffairtime {
	zenity --info --title="Lancement de la diffusion" --text="$TEXTEZENAIR" 2>/dev/null
liquidsoap "output.icecast(%vorbis($QUALITEVORBISREC), mount=\"$PMAIRTIME\",host=\"$SERVEURLOCAL\",port=$PORTAIRTIME,user=\"$USERAIRTIME\",password=\"$PASSAIRTIME\",input.alsa(device=\"hw:$nombre,$nombre1\"))"
}

function diffairtimerec {
	zenity --info --title="Lancement de la diffusion et de l'enregistrement" --text="$TEXTEZENAIR
$TEXTEZENREC" 2>/dev/null 
liquidsoap "s=output.icecast(%vorbis($QUALITEVORBISREC), mount=\"$PMAIRTIME\",host=\"$SERVEURLOCAL\",port=$PORTAIRTIME,user=\"$USERAIRTIME\",password=\"$PASSAIRTIME\",input.alsa(device=\"hw:$nombre,$nombre1\")) output.file(%vorbis($QUALITEVORBISREC),\"~/$REPREC/$FICHIERREC\",s)"
}

if [ "$1" = configureCS ]; then
	configCS
elif [ "$1" = configurePM ]; then
	configPM
elif [ "$1" = configureQDIFF ]; then
	configQDIFF
elif [ "$1" = configureQREC ]; then
	configQREC
elif [ "$1" = local ] && [ -z "$2" ]; then
	verifIP
	verifCS
	verifQDIFF $1
	difflocal
elif [ "$1" = local ] && [ "$2" = rec ]; then
	verifIP
	verifCS
	verifQDIFF $1
	verifQREC
	difflocalrec
elif [ "$1" = rec ]; then
	verifCS
	verifQREC
	localrec
elif [ "$1" = internet ] && [ -z "$2" ]; then
	verifINT
	verifPM
	verifCS
	verifQDIFF $1
	diffinternet
elif [ "$1" = internet ] && [ "$2" = rec ]; then
	verifINT
	verifPM
	verifCS
	verifQDIFF $1
	verifQREC
	diffinternetrec
elif [ "$1" = airtime ] && [ -z "$2" ]; then
	verifINT
	verifCS
	verifAIR
	verifQDIFF $1
	diffairtime
elif [ "$1" = airtime ] && [ "$2" = rec ]; then
	verifINT
	verifCS
	verifAIR
	verifQDIFF $1
	verifQREC
	diffairtimerec
else
	echo "Ce script nécessite des arguments pour fonctionner!"
fi 
