#!/bin/bash

#Nommer le point de montage.Tant que la variable est vide attente de la saisie.
while [ -z ${point[$i]} ]; do
echo "Veuillez saisir le nom du point de montage :"
read point
done

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
while [ -z ${pass[$i]} ]; do
echo "Veuillez saisir le mot de passe:"
read pass
done

echo "Les cartes son suivantes sont installées sur votre système :"

aplay -l
#Jusqu'a ce que la reponse soit composée par un nombre, j'attends la saisie
until [[ ${nombre} =~ ^[0-9]+$ ]]; do
echo "

Quel est l'identifiant du périphérique à utiliser ? (0, 1, etc.)"
read nombre
done

echo "
Le point de montage est : $point
Le mot de passe est : $pass
L'identifiant de la carte son est : $nombre
"

rm ~/Scripts/diff-internet/direct_dist.liq
rm ~/Scripts/diff-internet/direct-rec_dist.liq
	
sleep 1

echo "#
# En lançant ce script, tout ce qui entre sur la carte son gérée
# par ALSA est envoyé sur le serveur Icecast défini dans le script
#

liquidsoap 'output.icecast(%vorbis(quality=0.5), mount=\"$point\",host=\"webradio.ac-versailles.fr\", port=8000 , password=\"$pass\",input.alsa(device=\"hw:$nombre,0\"))'" > ~/Scripts/diff-internet/direct_dist.liq

echo "#
# En lançant ce script, tout ce qui entre sur la carte son gérée
# par ALSA est envoyé sur le serveur Icecast défini dans le script
#

liquidsoap 's=output.icecast(%vorbis(quality=0.5), mount=\"$point\",host=\"webradio.ac-versailles.fr\", port=8000 , password=\"$pass\",input.alsa(device=\"hw:$nombre,0\"))' 'output.file(%vorbis(quality=0.9),\"~/Musique/%Y-%m-%d-%H_%M_%S.ogg\",s)'" > ~/Scripts/diff-internet/direct-rec_dist.liq

chmod ugoa+x ~/Scripts/diff-internet/direct*

echo 	"La configuration est maintenant terminée.
	Vous pouvez lancer une diffusion et/ou un
	enregistrement en sélectionnant l'entrée 
	adéquante dans le menu 'Outils Webradio-WebTV'"

sleep 5
