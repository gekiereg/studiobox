#!/bin/bash

CONFIGURE=$(cat ~/Scripts/diff-internet/direct_dist.liq)

if [ "$CONFIGURE" = "configure" ]; then
        zenity --info --title="Configurer le flux" --text="Il semblerait que vous n'ayez pas configuré votre flux de diffusion.
Pas de panique! Il vous suffit de fermer cette fenêtre, puis de cliquer, depuis le menu principal, sur
 'Outils WebRadio' > 'Sur internet...' >
 'Configurer le flux de diffusion radio vers internet'"
        exit
fi


if [ "$1" = "diff" ] ; then
	exec ~/Scripts/diff-internet/direct_dist.liq
else
	zenity --info --title="Diffusion et enregistrement" --text="Le direct se lancera quand vous fermerez cette fenêtre.
	Vous retrouverez l'enregistrement de votre émission dans
	le répertoire 'Musique' (fichier .ogg horodaté)" 
	exec ~/Scripts/diff-internet/direct-rec_dist.liq
fi

