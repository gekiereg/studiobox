#!/bin/bash

RECONFIG="$HOME/.Scripts/diff-airtime/reconfig_airtime.bash"
DIRECT="$HOME/.Scripts/diff-airtime/direct_airtime.liq"
RECORD="$HOME/.Scripts/diff-airtime/record_airtime.liq"
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

if [ -z "$IP" ]; then
	zenity --info --title="Diffusion impossible" --text="Studiobox ne possède pas d'adresse sur le réseau de 
l'établissement: il est donc impossible de procéder à une diffusion. Vous pouvez par contre lancer un enregistrement."
	exit
fi

if [ "$1" = "diff" ] ; then
	zenity --info --title="Lancement de la diffusion" --text="Le flux radio est désormais envoyé vers le serveur Airtime.
Pour diffuser ce flux sur internet, ouvrez Airtime et basculez la source de flux sur 'Source Maître'" 
	bash $DIRECT
else
	zenity --info --title="Lancement de la diffusion et de l'enregistrement" --text="Le flux radio est désormais envoyé vers le serveur Airtime.
Pour diffuser ce flux sur internet, ouvrez Airtime et basculez la source de flux sur 'Source Maître' 
Vous retrouverez l'enregistrement de votre émission dans le répertoire 'Musique' (fichier .ogg horodaté)" 
	bash $RECORD
fi
