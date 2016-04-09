#!/bin/bash

if [ "$1" = "diff" ] ; then
	exec ~/Scripts/diff-internet/direct_dist.liq
else
	zenity --info --title="Diffusion et enregistrement" --text="Le direct se lancera quand vous fermerez cette fenêtre.
	Vous retrouverez l'enregistrement de votre émission dans
	le répertoire 'Musique' (fichier .ogg horodaté)" 
	exec ~/Scripts/diff-internet/direct-rec_dist.liq
fi

