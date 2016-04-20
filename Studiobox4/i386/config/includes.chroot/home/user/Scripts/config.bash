#!/bin/bash

#Nommer le point de montage.Tant que la variable est vide attente de la saisie.
while [ -z ${point[$i]} ]; do
echo "Veuillez saisir le nom du point de montage :"
read point
done

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

Quel est l'identifiant du périphérique ALSA à utiliser ?"
read nombre
done

echo "
Le point de montage est : $point
Le mot de passe est : $pass
L'identifiant de la carte son est : $nombre
"
echo "Le direct va être lancé dans 5 secondes !

"

echo 	"Si cette configuration convient, il est inutile pour
	la prochaine diffusion de reconfigurer le service. Il 
	suffit de lancer la commande :
	 ./direct.liq 
	depuis un terminal."
	
sleep 5

echo "
#
# En lançant ce script, tout ce qui entre sur la carte son gérée
# par ALSA est envoyé sur le serveur Icecast défini dans le script
#

liquidsoap 's=output.icecast(%vorbis, mount=\"$point\",host="webradio.ac-versailles.fr", port=80 , password=\"$pass\",input.alsa(device=\"hw:$nombre\,0"))' 'output.file(%vorbis,\"%Y-%m-%H_%M_%S.ogg\",s)'" > direct.liq
chmod +x direct.liq
exec ./direct.liq


