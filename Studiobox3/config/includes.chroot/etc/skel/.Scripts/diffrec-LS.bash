#!/bin/bash

FICHIERCS='.Scripts/config/cs'
FICHIERPM='.Scripts/config/pm'
IP=$(sudo ifconfig  | grep 'inet adr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')

function configPM {
#Nommer le point de montage.Tant que la variable est vide attente de la saisie.
while [ -z ${point[$i]} ]; do
read -p "Veuillez saisir le nom du point de montage : " point
done

#Tant que la variable est vide, j'attends la saisie
while [ -z ${pass[$i]} ]; do
read -p "Veuillez saisir le mot de passe: " pass
done

echo "pm,$point
pass,$pass" > $FICHIERPM
zenity --info --title="Point de diffusion configuré" --text="Le point de diffusion qui sera utilisé est $point.
Les auditeurs pourront vous écouter à l'adresse suivante: http://webradio.ac-versailles.fr/$point"
}

function configCS {
echo "Les cartes sons suivantes sont installées sur votre système :"
aplay -l
#Jusqu'a ce que la reponse soit composée par un nombre, j'attends la saisie
until [[ ${nombre} =~ ^[0-9]+$ ]]; do
read -p "Quel est l'identifiant de la carte à utiliser ? (0, 1, etc.): " nombre
done

NBRECARTES=$(aplay -l | grep ^"carte $nombre" | wc -l)

#si plusieurs cartes ont le même identifiant, on choisit par le numéro de périphérique
if [ $NBRECARTES -ge 2 ]; then
	echo "Plusieurs cartes sont identifiées par le chiffre $nombre"
	echo "Indiquez le numéro de 'périphérique' de la carte à utiliser"
	echo "(en cas de doute, indiquez '0')"
	aplay -l | grep ^"carte $nombre"
	until [[ ${nombre1} =~ ^[0-9]+$ ]]; do
		read -p "Quel est l'identifiant du périphérique de la carte à utiliser ? (0, 1, etc.): " nombre1
	done
else
	nombre1="0"
fi

echo "$nombre,$nombre1" > $FICHIERCS
CARTEOK=$(aplay -l | grep ^"carte $nombre" | grep "périphérique $nombre1")
	zenity --info --title="Carte son configurée" --text="La configuration est maintenant terminée. Au prochain enregistrement ou à la prochaine diffusion, la carte suivante sera utilisée:
$CARTEOK"
}

function verifIP {
if  [ -z "$IP" ]; then
	zenity --info --title="Diffusion impossible" --text="Studiobox ne possède pas d'adresse sur le réseau de 
l'établissement: il est donc impossible de procéder à une diffusion. Vous pouvez par contre lancer un enregistrement."
	exit
fi
}

function verifCS {
nombre=$(cat $FICHIERCS | cut -d"," -f1)
nombre1=$(cat $FICHIERCS | cut -d"," -f2)
DISPO=$(aplay -l | grep ^"carte $nombre" |  grep "périphérique $nombre1")

if [ -z "$DISPO" ]; then
        zenity --info --title="Carte son indisponible" --text="Il semblerait que la carte son configurée soit indisponible. Veuillez la reconfigurer (menu 'Outils WebRadio' > 'Configurer la WebRadio' > 'Configurer la carte son des flux')"
	exit
fi
}

function verifPM {
TYPEPM=$(cat $FICHIERPM | grep ^pm | cut -d"," -f2 | cut -d"." -f2)
if [ "$TYPEPM" != ogg ] && [ "$TYPEPM" != mp3 ]; then
	zenity --info --text="Votre point de diffusion est mal ou non configuré (il doit être de forme 'type-nom-ville.mp3' ou 'type-nom-ville.ogg'. Veuillez le reconfigurer (menu 'Outils WebRadio' > 'Configurer la WebRadio' > 'Configurer le point de diffusion radio')"
	exit
fi
point=$(cat $FICHIERPM | grep ^pm | cut -d"," -f2)
pass=$(cat $FICHIERPM | grep ^pass | cut -d"," -f2)
}

function verifint {
wget -q --tries=20 --timeout=10 http://www.google.com -O /tmp/google.idx &> /dev/null
if [ ! -s /tmp/google.idx ]
then
	zenity --info --text="Vous n'êtes pas connecté à internet. La diffusion est impossible."
	exit
else
	rm /tmp/google.idx
fi
}

function difflocal {
zenity --info --title="Pour vous écouter..." --text="Le direct se lancera quand vous fermerez cette fenêtre.
Pour vous écouter sur le réseau de l'établissement, ouvrir un navigateur web et y indiquer l'url suivante:
http://$IP:8000/webradio.ogg"
liquidsoap "output.icecast(%vorbis(quality=0.6), mount=\"webradio.ogg\",host=\"localhost\", port=8000 , password=\"webradio\",input.alsa(device=\"hw:$nombre,$nombre1\"))"
}

function difflocalrec {
zenity --info --title="Pour vous écouter..." --text="Le direct se lancera quand vous fermerez cette fenêtre.
Pour vous écouter sur le réseau de l'établissement, ouvrir un navigateur web et y indiquer l'url suivante:
http://$IP:8000/webradio.ogg
Vous retrouverez l'enregistrement de votre émission dans le répertoire 'Musique' (fichier .ogg horodaté)"
liquidsoap "s=output.icecast(%vorbis(quality=0.6), mount=\"webradio.ogg\",host=\"localhost\", port=8000 , password=\"webradio\",input.alsa(device=\"hw:$nombre,$nombre1\")) output.file(%vorbis(quality=0.9),\"~/Musique/%Y-%m-%d-%H_%M_%S.ogg\",s)"
}

function localrec {
zenity --info --title="Enregistrement" --text="L'enregistrement se lancera quand vous fermerez cette fenêtre.
Vous retrouverez l'enregistrement de votre émission dans
le répertoire 'Musique' (fichier .ogg horodaté)" 
liquidsoap "output.file(%vorbis(quality=0.9),\"~/Musique/%Y-%m-%d-%H_%M_%S.ogg\",input.alsa(device=\"hw:$nombre,$nombre1\"))"
}

function diffinternet {
zenity --info --title="Diffusion en direct sur internet" --text="La diffusion commencera quand vous validerez cette boîte de dialogue.
Les auditeurs pourront vous écouter à l'adresse suivante: http://webradio.ac-versailles.fr/$point"
if [ "$TYPEPM" = "ogg" ]; then
liquidsoap "output.icecast(%vorbis(quality=0.5), mount=\"$point\",host=\"webradio.ac-versailles.fr\", port=8000 , password=\"$pass\",input.alsa(device=\"hw:$nombre,$nombre1\"))"
else
liquidsoap "output.icecast(%mp3(bitrate=128), mount=\"$point\",host=\"webradio.ac-versailles.fr\", port=8000 , password=\"$pass\",input.alsa(device=\"hw:$nombre,$nombre1\"))"
fi
}

function diffinternetrec {
zenity --info --title="Diffusion en direct sur internet" --text="La diffusion commencera quand vous validerez cette boîte de dialogue.
Les auditeurs pourront vous écouter à l'adresse suivante: http://webradio.ac-versailles.fr/$point
Vous retrouverez l'enregistrement de votre émission dans
le répertoire 'Musique' (fichier .ogg horodaté)" 
if [ "$TYPEPM" = "ogg" ]; then
	liquidsoap "s=output.icecast(%vorbis(quality=0.5), mount=\"$point\",host=\"webradio.ac-versailles.fr\", port=8000 , password=\"$pass\",input.alsa(device=\"hw:$nombre,$nombre1\")) output.file(%vorbis(quality=0.9),\"~/Musique/%Y-%m-%d-%H_%M_%S.ogg\",s)"
else
	liquidsoap "s=output.icecast(%mp3(bitrate=128), mount=\"$point\",host=\"webradio.ac-versailles.fr\", port=8000 , password=\"$pass\",input.alsa(device=\"hw:$nombre,$nombre1\")) output.file(%vorbis(quality=0.9),\"~/Musique/%Y-%m-%d-%H_%M_%S.ogg\",s)"
fi
}

function diffairtime {
	zenity --info --title="Lancement de la diffusion" --text="Le flux radio est désormais envoyé vers le serveur Airtime.
Pour diffuser ce flux sur internet, ouvrez Airtime et basculez la source de flux sur 'Source Maître'" 
liquidsoap "output.icecast(%vorbis(quality=0.9), mount=\"webradio.ogg\",host=\"localhost\",port=8001,user=\"source\",password=\"webradio\",input.alsa(device=\"hw:$nombre,$nombre1\"))"
}

function diffairtimerec {
	zenity --info --title="Lancement de la diffusion et de l'enregistrement" --text="Le flux radio est désormais envoyé vers le serveur Airtime.
Pour diffuser ce flux sur internet, ouvrez Airtime et basculez la source de flux sur 'Source Maître' 
Vous retrouverez l'enregistrement de votre émission dans le répertoire 'Musique' (fichier .ogg horodaté)" 
liquidsoap "s=output.icecast(%vorbis(quality=0.9), mount=\"webradio.ogg\",host=\"localhost\",port=8001,user=\"source\",password=\"webradio\",input.alsa(device=\"hw:$nombre,$nombre1\")) output.file(%vorbis(quality=0.9),\"~/Musique/%Y-%m-%d-%H_%M_%S.ogg\",s)"
}

if [ "$1" = configureCS ]; then
	configCS
elif [ "$1" = configurePM ]; then
	configPM
elif [ "$1" = local ] && [ -z "$2" ]; then
	verifIP
	verifCS
	difflocal
elif [ "$1" = local ] && [ "$2" = rec ]; then
	verifIP
	verifCS
	difflocalrec
elif [ "$1" = rec ]; then
	verifCS
	localrec
elif [ "$1" = internet ] && [ -z "$2" ]; then
	verifINT
	verifPM
	verifCS
	diffinternet
elif [ "$1" = internet ] && [ "$2" = rec ]; then
	verifINT
	verifPM
	verifCS
	diffinternetrec
elif [ "$1" = airtime ] && [ -z "$2" ]; then
	verifINT
	verifCS
	diffairtime
elif [ "$1" = airtime ] && [ "$2" = rec ]; then
	verifINT
	verifCS
	diffairtimerec
else
	echo "Ce script nécessite des arguments pour fonctionner!"
fi 
