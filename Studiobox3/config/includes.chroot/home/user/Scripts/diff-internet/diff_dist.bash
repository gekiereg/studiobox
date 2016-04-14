#!/bin/bash

RECONFIG='/home/user/Scripts/diff-internet/reconfig_dist.bash'
DIRECT='/home/user/Scripts/diff-internet/direct_dist.liq'
RECORD='/home/user/Scripts/diff-internet/record_dist.liq'
IP=$(sudo ifconfig  | grep 'inet adr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
CONFIGURE=$(cat $DIRECT)

if [ "$CONFIGURE" = "configure" ]; then
	zenity --info --title="Configurer le flux" --text="Il semblerait que vous n'ayez pas configuré votre flux de diffusion.
Pas de panique! Il vous suffit de valider cette fenêtre pour procéder à la configuration"
	bash $RECONFIG
fi

CARTE=$(cat $DIRECT | grep ^liquid | cut -d":" -f2 | cut -d"," -f1)
DISPO=$(aplay -l | grep ^"carte $CARTE")

while [ -z "$DISPO" ]; do
        zenity --info --title="Carte son indisponible" --text="Il semblerait que la carte son configurée soit indisponible.
Pas de panique! Validez cette fenêtre pour procéder à la reconfiguration!"
	bash $RECONFIG
	CARTE=$(cat $DIRECT | grep ^liquid | cut -d":" -f2 | cut -d"," -f1)
	DISPO=$(aplay -l | grep ^"carte $CARTE")
done

if [ "$1" = "diff" ] ; then
	zenity --info --title="Pour vous écouter..." --text="Le direct se lancera quand vous fermerez cette fenêtre."
	bash $DIRECT
else
	zenity --info --title="Pour vous écouter..." --text="Le direct se lancera quand vous fermerez cette fenêtre.
	Vous retrouverez l'enregistrement de votre émission dans
	le répertoire 'Musique' (fichier .ogg horodaté)" 
	bash $RECORD
fi
