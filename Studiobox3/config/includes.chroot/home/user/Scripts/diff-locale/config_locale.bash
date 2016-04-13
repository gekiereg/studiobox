#!/bin/bash

DIRECT='/home/user/Scripts/diff-locale/direct_local.liq'
RECORD='/home/user/Scripts/diff-locale/record_local.liq'

#Nommer le point de montage.Tant que la variable est vide attente de la saisie.
#while [ -z ${point[$i]} ]; do
#echo "Veuillez saisir le nom du point de montage :"
#read point
#done

#Nommer le serveur de montage.Tant que la variable est vide attente de la saisie.
#while [ -z ${hote[$i]} ]; do
#echo "Veuillez saisir le nom complet (FQHN) du serveur icecast :"
#read hote
#done

#Tant que la variable est vide, j'attends la saisie
#while [ -z ${port[$i]} ]; do
#echo "Veuillez saisir le port :"
#read port
#done

#Tant que la variable est vide, j'attends la saisie
#while [ -z ${pass[$i]} ]; do
#echo "Veuillez saisir le mot de passe:"
#read pass
#done

echo "Les cartes son suivantes sont installées sur votre système :"

aplay -l
#Jusqu'a ce que la reponse soit composée par un nombre, j'attends la saisie
until [[ ${nombre} =~ ^[0-9]+$ ]]; do
echo "

Quel est l'identifiant du périphérique à utiliser ? (0, 1, etc.)"
read nombre
done

echo "
L'identifiant de la carte son est : $nombre
"

rm $DIRECT
rm $RECORD

sleep 1

echo "#
# En lançant ce script, tout ce qui entre sur la carte son gérée
# par ALSA est envoyé sur le serveur Icecast défini dans le script
#


liquidsoap 's=output.icecast(%vorbis(quality=0.6), mount=\"webradio.ogg\",host=\"localhost\", port=8000 , password=\"webradio\",input.alsa(device=\"hw:$nombre,0\"))' 'output.file(%vorbis(quality=0.9),\"~/Musique/%Y-%m-%d-%H_%M_%S.ogg\",s)'" > $RECORD

echo "#
# En lançant ce script, tout ce qui entre sur la carte son gérée
# par ALSA est envoyé sur le serveur Icecast défini dans le script
#


liquidsoap 'output.icecast(%vorbis(quality=0.6), mount=\"webradio.ogg\",host=\"localhost\", port=8000 , password=\"webradio\",input.alsa(device=\"hw:$nombre,0\"))'" > $DIRECT

chmod ugoa+x ~/Scripts/diff-locale/direct*

zenity --info --title="Fin de la configuration" --text="La configuration est maintenant terminée. Vous pouvez lancer une diffusion (et un 
enregistrement simultané) en sélectionnant l'entrée 
adéquate dans le menu 'Outils Webradio' > 'Dans l'établissement'"
