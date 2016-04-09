#!/bin/bash

IP=$(sudo ifconfig  | grep 'inet adr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')

if [ "$1" = "diff" ] ; then
	zenity --info --title="Pour vous écouter..." --text="Le direct se lancera quand vous fermerez cette fenêtre.
	Pour vous écouter sur le réseau de l'établissement, ouvrir un navigateur web et y indiquer l'url suivante:
	http://$IP:8000/webradio.ogg" 
	exec ~/Scripts/diff-locale/direct_local.liq
else
	zenity --info --title="Pour vous écouter..." --text="Le direct se lancera quand vous fermerez cette fenêtre.
	Pour vous écouter sur le réseau de l'établissement, ouvrir un navigateur web et y indiquer l'url suivante:
	http://$IP:8000/webradio.ogg
	Vous retrouverez l'enregistrement de votre émission dans
	le répertoire 'Musique' (fichier .ogg horodaté)" 
	exec ~/Scripts/diff-locale/direct-rec_local.liq
fi

