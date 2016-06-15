#!/bin/bash

# variables générales: fichiers qui stockent les réglages et test de l'existence d'une IP
FICHIERCS='.Scripts/config/cs'
FICHIERPM='.Scripts/config/pm'
FICHIERQDIFF='.Scripts/config/qdiff'
FICHIERQREC='.Scripts/config/qrec'
IP=$(sudo ifconfig  | grep 'inet adr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')

function annulzen {
# possibilité d'annuler la config en cliquant sur annuler
if [ "$?" -eq 1 ]; then
    exit
fi
}

function configPM {
# formulaire zenity
CFPM=$(zenity --forms \
    --title="Configuration du point de diffusion" \
    --text="Définition du point de montage et du mot de passe" \
    --add-entry="Nom du point de diffusion (sous la forme etab-type-ville.mp3 ou etab-type-ville.ogg" \
    --add-password="Mot de passe" \
    --add-password="Confirmer le mot de passe" \
    --separator="|" 2>/dev/null)
annulzen

# récupération des valeurs (amélioration possible: regex sur le point de montage pour tester cohérence)
point=$(echo $CFPM | cut -d"|" -f1)
pass=$(echo $CFPM | cut -d"|" -f2)
pass1=$(echo $CFPM | cut -d"|" -f3)
while [ "$pass" !=  "$pass1" ] || [ -z "$pass" ]; do
zenity --info --title="Mot de passe?" --text="Les mots de passe ne coïncident pas. Relance 
de la configuration du mot de passe"
CFPASS=$(zenity --forms \
    --title="Configuration du mot de passe" \
    --text="Définition du mot de passe" \
    --add-password="Mot de passe" \
    --add-password="Confirmer le mot de passe" \
    --separator="|" 2>/dev/null)
annulzen
pass=$(echo $CFPASS | cut -d"|" -f1)
pass1=$(echo $CFPASS | cut -d"|" -f2)
done

echo "pm,$point
pass,$pass" > $FICHIERPM
zenity --info --title="Point de diffusion configuré" --text="Le point de diffusion qui sera utilisé est $point.
Les auditeurs pourront vous écouter à l'adresse suivante: http://webradio.ac-versailles.fr/$point" 2>/dev/null
}

function configCS {
FICHIERCS='.Scripts/config/cs'

CARTES=$(aplay -l | grep ^carte)
aplay -l | grep ^carte > $FICHIERCS
# zenity n'aime pas les espaces pour la fonction 'entry', donc suppression des espaces dans le nom des cartes
sed -i 's/ /_/g' $FICHIERCS

LISTECARTES=$(cat $FICHIERCS)

CARTE=$(zenity --entry --title="Configuration de la carte son" --text="Veuillez indiquer la carte son à utiliser" $LISTECARTES 2>/dev/null)
annulzen

nombre=$(echo $CARTE | cut -d":" -f1 | tail -c2)
nombre1=$(echo $CARTE | cut -d":" -f2 | tail -c2)

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
annulzen
echo $QREC > $FICHIERQREC
}

function configQDIFF {
QDIFF=$(zenity --scale --min-value=1 --max-value=9 --value=5 --title="Qualité de la diffusion" --text="Choisissez la qualité de la diffusion. (1 = très faible, 9 = excellente)")
annulzen
echo $QDIFF > $FICHIERQDIFF
}

function verifQREC {
CHIFFREVORBISREC=$(cat $FICHIERQREC 2>/dev/null)
if [ ! -z $CHIFFREVORBIS ]; then
	QUALITEVORBISREC="quality=0.$CHIFFREVORBISREC"
else
	QUALITEVORBISREC="quality=0.9"
fi
}

function verifQDIFF {
# en fonction du mode de diffusion et du format du point de montage, transformation du choix
# de la qualité de diffusion en valeur lisible par liquidsoap
if [ "$1" = local ] || [ "$1" = airtime ] ; then
	CHIFFREVORBISDIFF=$(cat $FICHIERQDIFF 2>/dev/null)
	if [ ! -z $CHIFFREVORBISDIFF ]; then
		QUALITEVORBISDIFF="quality=0.$CHIFFREVORBISDIFF"
	else
		QUALITEVORBISDIFF="quality=0.7"
	fi
else
	if [ "$TYPEPM" = ogg ]; then
		CHIFFREVORBISDIFF=$(cat $FICHIERQDIFF 2>/dev/null)
		if [ ! -z $CHIFFREVORBISDIFF ]; then
			QUALITEVORBISDIFF="quality=0.$CHIFFREVORBISDIFF"
		else
			QUALITEVORBISDIFF="quality=0.5"
		fi
	else
		CHIFFREMP3DIFF=$(cat $FICHIERQDIFF 2>/dev/null)
		if [ ! -z $CHIFFREMP3DIFF ]; then
			case $CHIFFREMP3DIFF in
				'1')
				QUALITEMP3DIFF='bitrate=48'
				;;
				'2')
				QUALITEMP3DIFF='bitrate=64'
				;;
				'3')
				QUALITEMP3DIFF='bitrate=96'
				;;
				'4')
				QUALITEMP3DIFF='bitrate=128'
				;;
				'5')
				QUALITEMP3DIFF='bitrate=160'
				;;
				'6')
				QUALITEMP3DIFF='bitrate=192'
				;;
				'7')
				QUALITEMP3DIFF='bitrate=224'
				;;
				'8')
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
# on vérifie que le flux source maître est bien configuré dans airtime avant de permettre une diffusion vers celui-ci
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
TEXTEMONITOR="Souhaitez-vous monitorer le flux avec VLC?"

# amélioration possible sur toutes les fonctions de diffusion et d'enregistrement: effectuer un test 
# pour vérifier que la diffusion et / ou l'enregistrement se déroulent correctement

function difflocal {
zenity --question --title="Diffusion en direct" --text="$TEXTEZENDIFFLOCAL
$TEXTEMONITOR" 2>/dev/null
annulzen
if [ $? = 0 ]; then
	liquidsoap "output.icecast(%vorbis($QUALITEVORBISDIFF), mount=\"$PMLOCAL\",host=\"$SERVEURLOCAL\", port=$PORTICECAST , password=\"$PASSLOCAL\",input.alsa(device=\"hw:$nombre,$nombre1\"))" &
	vlc --zoom 0.5 http://localhost:$PORTICECAST/$PMLOCAL --audio-visual visual --effect-list spectrum 2>/dev/null
else
	liquidsoap "output.icecast(%vorbis($QUALITEVORBISDIFF), mount=\"$PMLOCAL\",host=\"$SERVEURLOCAL\", port=$PORTICECAST , password=\"$PASSLOCAL\",input.alsa(device=\"hw:$nombre,$nombre1\"))"
fi
}

function difflocalrec {
zenity --question --title="Diffusion et enregistrement" --text="$TEXTEZENDIFFLOCAL
$TEXTEZENREC
$TEXTEMONITOR" 2>/dev/null
annulzen
if [ $? = 0 ]; then
	liquidsoap "s=output.icecast(%vorbis($QUALITEVORBISDIFF), mount=\"$PMLOCAL\",host=\"$SERVEURLOCAL\", port=$PORTICECAST , password=\"$PASSLOCAL\",input.alsa(device=\"hw:$nombre,$nombre1\")) output.file(%vorbis($QUALITEVORBISREC),\"~/$REPREC/$FICHIERREC\",s)" &
	vlc --zoom 0.5 http://localhost:$PORTICECAST/$PMLOCAL --audio-visual visual --effect-list spectrum 2>/dev/null
else
	liquidsoap "s=output.icecast(%vorbis($QUALITEVORBISDIFF), mount=\"$PMLOCAL\",host=\"$SERVEURLOCAL\", port=$PORTICECAST , password=\"$PASSLOCAL\",input.alsa(device=\"hw:$nombre,$nombre1\")) output.file(%vorbis($QUALITEVORBISREC),\"~/$REPREC/$FICHIERREC\",s)"
fi
}

function localrec {
zenity --question --title="Enregistrement" --text="L'enregistrement se lancera quand vous fermerez cette fenêtre.
$TEXTEZENREC
$TEXTEMONITOR" 2>/dev/null
annulzen
if [ $? = 0 ]; then
	liquidsoap "s=output.icecast(%vorbis($QUALITEVORBISDIFF), mount=\"$PMLOCAL\",host=\"$SERVEURLOCAL\", port=$PORTICECAST , password=\"$PASSLOCAL\",input.alsa(device=\"hw:$nombre,$nombre1\")) output.file(%vorbis($QUALITEVORBISREC),\"~/$REPREC/$FICHIERREC\",s)" &
	vlc --zoom 0.5 http://localhost:$PORTICECAST/$PMLOCAL --audio-visual visual --effect-list spectrum 2>/dev/null
else
	liquidsoap "output.file(%vorbis($QUALITEVORBISREC),\"~/$REPREC/$FICHIERREC\",input.alsa(device=\"hw:$nombre,$nombre1\"))"
fi
}

function diffinternet {
zenity --question --title="Diffusion en direct sur internet" --text="$TEXTEZENDIFFINT
$TEXTEMONITOR" 2>/dev/null
annulzen
if [ $? = 0 ]; then
	if [ "$TYPEPM" = "ogg" ]; then
		liquidsoap "output.icecast(%vorbis($QUALITEVORBISDIFF), mount=\"$PMACAD\",host=\"$SERVEURACAD\", port=$PORTICECAST , password=\"$PASSACAD\",input.alsa(device=\"hw:$nombre,$nombre1\"))" &
		vlc --zoom 0.5 http://$SERVEURACAD/$PMACAD --audio-visual visual --effect-list spectrum 2>/dev/null
	else
		liquidsoap "output.icecast(%mp3($QUALITEMP3DIFF), mount=\"$PMACAD\",host=\"$SERVEURACAD\", port=$PORTICECAST , password=\"$PASSACAD\",input.alsa(device=\"hw:$nombre,$nombre1\"))" &
		vlc --zoom 0.5 http://$SERVEURACAD/$PMACAD --audio-visual visual --effect-list spectrum 2>/dev/null
	fi
else
	if [ "$TYPEPM" = "ogg" ]; then
		liquidsoap "output.icecast(%vorbis($QUALITEVORBISDIFF), mount=\"$PMACAD\",host=\"$SERVEURACAD\", port=$PORTICECAST , password=\"$PASSACAD\",input.alsa(device=\"hw:$nombre,$nombre1\"))"
	else
		liquidsoap "output.icecast(%mp3($QUALITEMP3DIFF), mount=\"$PMACAD\",host=\"$SERVEURACAD\", port=$PORTICECAST , password=\"$PASSACAD\",input.alsa(device=\"hw:$nombre,$nombre1\"))"
	fi

fi
}

function diffinternetrec {
zenity --question --title="Diffusion en direct sur internet" --text="$TEXTEZENDIFFINT
$TEXTEZENREC
$TEXTEMONITOR" 2>/dev/null 
annulzen
if [ $? = 0 ]; then
	if [ "$TYPEPM" = "ogg" ]; then
		liquidsoap "s=output.icecast(%vorbis($QUALITEVORBISDIFF), mount=\"$PMACAD\",host=\"$SERVEURACAD\", port=$PORTICECAST , password=\"$PASSACAD\",input.alsa(device=\"hw:$nombre,$nombre1\")) output.file(%vorbis($QUALITEVORBISREC),\"~/$REPREC/$FICHIERREC\",s)" &
		vlc --zoom 0.5 http://$SERVEURACAD/$PMACAD --audio-visual visual --effect-list spectrum 2>/dev/null
	else
		liquidsoap "s=output.icecast(%mp3($QUALITEMP3DIFF), mount=\"$PMACAD\",host=\"$SERVEURACAD\", port=$PORTICECAST , password=\"$PASSACAD\",input.alsa(device=\"hw:$nombre,$nombre1\")) output.file(%vorbis($QUALITEVORBISREC),\"~/$REPREC/$FICHIERREC\",s)" &
		vlc --zoom 0.5 http://$SERVEURACAD/$PMACAD --audio-visual visual --effect-list spectrum 2>/dev/null
	fi
else
	if [ "$TYPEPM" = "ogg" ]; then
		liquidsoap "s=output.icecast(%vorbis($QUALITEVORBISDIFF), mount=\"$PMACAD\",host=\"$SERVEURACAD\", port=$PORTICECAST , password=\"$PASSACAD\",input.alsa(device=\"hw:$nombre,$nombre1\")) output.file(%vorbis($QUALITEVORBISREC),\"~/$REPREC/$FICHIERREC\",s)"
	else
		liquidsoap "s=output.icecast(%mp3($QUALITEMP3DIFF), mount=\"$PMACAD\",host=\"$SERVEURACAD\", port=$PORTICECAST , password=\"$PASSACAD\",input.alsa(device=\"hw:$nombre,$nombre1\")) output.file(%vorbis($QUALITEVORBISREC),\"~/$REPREC/$FICHIERREC\",s)"
	fi
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


case $1 in
	'configureCS')
	configCS
	;;
	'configurePM')
	configPM
	;;
	'configureQDIFF')
	configQDIFF
	;;
	'configureQREC')
	configQREC
	;;
	'rec')
	verifCS
	verifQREC
	localrec
	;;
	'local')
	if [ -z "$2" ]; then
		verifIP
		verifCS
		verifQDIFF $1
		difflocal
	else
		verifIP
		verifCS
		verifQDIFF $1
		verifQREC
		difflocalrec
	fi
	;;
	'internet')
	if [ -z "$2" ]; then
		verifINT
		verifPM
		verifCS
		verifQDIFF $1
		diffinternet
	else
		verifINT
		verifPM
		verifCS
		verifQDIFF $1
		verifQREC
		diffinternetrec
	fi
	;;
	'airtime')
	if [ -z "$2" ]; then
		verifINT
		verifCS
		verifAIR
		verifQDIFF $1
		diffairtime
	else
		verifINT
		verifCS
		verifAIR
		verifQDIFF $1
		verifQREC
		diffairtimerec
	fi
	;;	
esac
