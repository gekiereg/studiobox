#!/bin/bash

DIRECT="$HOME/.Scripts/diff-airtime/direct_airtime.liq"
RECORD="$HOME/.Scripts/diff-airtime/record_airtime.liq"
CONFIGAIRTIME=$(cat /etc/airtime/liquidsoap.cfg | grep airtime.ogg)

if [ -z "$CONFIGAIRTIME" ]; then
	echo "Airtime n'est pas configuré pour être utilisé avec cette méthode de diffusion."
	echo "La rubrique 'Configurer Airtime' du document 'memento_airtime.pdf'"
	echo "(dans le répertoire 'Documents') vous explique la marche à suivre"
	echo "pour réaliser cette configuration"
	sleep 7
	exit
fi

echo "Les cartes sons suivantes sont installées sur votre système :"

aplay -l
#Jusqu'a ce que la reponse soit composée par un nombre, j'attends la saisie
until [[ ${nombre} =~ ^[0-9]+$ ]]; do
read -p "Quel est l'identifiant du périphérique à utiliser (0, 1, etc.): " nombre
done

rm $DIRECT
rm $RECORD

sleep 1

echo "liquidsoap 's=output.icecast(%vorbis(quality=0.9), mount=\"webradio.ogg\",host=\"localhost\",port=8001,user=\"source\",password=\"webradio\",input.alsa(device=\"hw:$nombre,0\"))' 'output.file(%vorbis(quality=0.9),\"~/Musique/%Y-%m-%d-%H_%M_%S.ogg\",s)'" > $RECORD

echo "liquidsoap 'output.icecast(%vorbis(quality=0.9), mount=\"webradio.ogg\",host=\"localhost\",port=8001,user=\"source\",password=\"webradio\",input.alsa(device=\"hw:$nombre,0\"))'" > $DIRECT

chmod ugoa+x $DIRECT
chmod ugoa+x $RECORD

zenity --info --title="Fin de la configuration" --text="La configuration est maintenant terminée. Vous pouvez lancer une diffusion (et un 
enregistrement simultané) en sélectionnant l'entrée 
adéquate dans le menu 'Outils Webradio' > 'Airtime'"
