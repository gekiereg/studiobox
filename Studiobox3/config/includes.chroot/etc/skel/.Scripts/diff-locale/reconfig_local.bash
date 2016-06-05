#!/bin/bash

DIRECT="$HOME/.Scripts/diff-locale/direct_local.liq"
RECORD="$HOME/.Scripts/diff-locale/record_local.liq"
REC="$HOME/.Scripts/diff-locale/rec_local.liq"

echo "Les cartes sons suivantes sont installées sur votre système :"

aplay -l
#Jusqu'a ce que la reponse soit composée par un nombre, j'attends la saisie
until [[ ${nombre} =~ ^[0-9]+$ ]]; do
read -p "Quel est l'identifiant du périphérique à utiliser (0, 1, etc.): " nombre
done

rm $DIRECT
rm $RECORD
rm $REC

sleep 1

echo "liquidsoap 'output.file(%vorbis(quality=0.9),\"~/Musique/%Y-%m-%d-%H_%M_%S.ogg\",input.alsa(device=\"hw:$nombre,0\"))'" > $REC

echo "liquidsoap 's=output.icecast(%vorbis(quality=0.6), mount=\"webradio.ogg\",host=\"localhost\", port=8000 , password=\"webradio\",input.alsa(device=\"hw:$nombre,0\"))' 'output.file(%vorbis(quality=0.9),\"~/Musique/%Y-%m-%d-%H_%M_%S.ogg\",s)'" > $RECORD

echo "liquidsoap 'output.icecast(%vorbis(quality=0.6), mount=\"webradio.ogg\",host=\"localhost\", port=8000 , password=\"webradio\",input.alsa(device=\"hw:$nombre,0\"))'" > $DIRECT

chmod ugoa+x $RECORD
chmod ugoa+x $REC
chmod ugoa+x $DIRECT

zenity --info --title="Fin de la configuration" --text="La configuration est maintenant terminée. Validez cette fenêtre pour relancer le processus de diffusion."
