#!/bin/bash

CONFIG='/home/user/Scripts/diff-internet/config_dist.bash'
RECONFIG='/home/user/Scripts/diff-internet/reconfig_dist.bash'
DIRECT='/home/user/Scripts/diff-internet/direct_dist.liq'
RECORD='/home/user/Scripts/diff-internet/record_dist.liq'
IP=$(sudo ifconfig  | grep 'inet adr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
CARTE=$(cat $DIRECT | grep ^liquid | cut -d":" -f2 | cut -d"," -f1)
DISPO=$(aplay -l | grep ^"carte $CARTE")
CONFIGURE=$(cat $DIRECT)

if [ "$CONFIGURE" = "configure" ]; then
	zenity --info --title="Configurer le flux" --text="Il semblerait que vous n'ayez pas configuré votre flux de diffusion.
Pas de panique! Il vous suffit de valider cette fenêtre pour procéder à la configuration"
	bash $CONFIG
fi

while [ -z "$DISPO" ]; do
        zenity --info --title="Carte son indisponible" --text="Il semblerait que la carte son configurée soit indisponible.
Pas de panique! Validez cette fenêtre pour procéder à la reconfiguration!"
	bash $RECONFIG
	CARTE=$(cat $DIRECT | grep ^liquid | cut -d":" -f2 | cut -d"," -f1)
	DISPO=$(aplay -l | grep ^"carte $CARTE")
done
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

