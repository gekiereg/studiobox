#!/bin/bash

DIRECT="$HOME/.Scripts/diff-internet/direct_dist.liq"
RECORD="$HOME/.Scripts/diff-internet/record_dist.liq"

#Nommer le point de montage.Tant que la variable est vide attente de la saisie.
while [ -z ${point[$i]} ]; do
read -p "Veuillez saisir le nom du point de montage: " point
done

#Tant que la variable est vide, j'attends la saisie
while [ -z ${pass[$i]} ]; do
read -p "Veuillez saisir le mot de passe: " pass
done

echo "Les cartes sons suivantes sont installées sur votre système :"

aplay -l
#Jusqu'a ce que la reponse soit composée par un nombre, j'attends la saisie
until [[ ${nombre} =~ ^[0-9]+$ ]]; do
read -p "Quel est l'identifiant du périphérique à utiliser ? (0, 1, etc.): " nombre
done

echo "
Le point de montage est : $point
Le mot de passe est : $pass
L'identifiant de la carte son est : $nombre
"

rm $DIRECT
rm $RECORD

sleep 1

TYPE=$(echo $point | cut -d"." -f2)

if [ "$TYPE" = "ogg" ]; then
	echo "liquidsoap 'output.icecast(%vorbis(quality=0.5), mount=\"$point\",host=\"webradio.ac-versailles.fr\", port=8000 , password=\"$pass\",input.alsa(device=\"hw:$nombre,0\"))'" > $DIRECT

	echo "liquidsoap 's=output.icecast(%vorbis(quality=0.5), mount=\"$point\",host=\"webradio.ac-versailles.fr\", port=8000 , password=\"$pass\",input.alsa(device=\"hw:$nombre,0\"))' 'output.file(%vorbis(quality=0.9),\"~/Musique/%Y-%m-%d-%H_%M_%S.ogg\",s)'" > $RECORD
else
	echo "liquidsoap 'output.icecast(%mp3(bitrate=128), mount=\"$point\",host=\"webradio.ac-versailles.fr\", port=8000 , password=\"$pass\",input.alsa(device=\"hw:$nombre,0\"))'" > $DIRECT

	echo "liquidsoap 's=output.icecast(%mp3(bitrate=128), mount=\"$point\",host=\"webradio.ac-versailles.fr\", port=8000 , password=\"$pass\",input.alsa(device=\"hw:$nombre,0\"))' 'output.file(%vorbis(quality=0.9),\"~/Musique/%Y-%m-%d-%H_%M_%S.ogg\",s)'" > $RECORD
fi

chmod ugoa+x $DIRECT
chmod ugoa+x $RECORD

zenity --info --title="Fin de la configuration" --text="La configuration est maintenant terminée. Validez cette fenêtre pour relancer le processus de diffusion."
