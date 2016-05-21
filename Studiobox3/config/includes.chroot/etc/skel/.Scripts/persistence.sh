#!/bin/bash
# Script de création de la persistance de la clé studiobox
# Utilisation du script
#	/bin/bash persistence.sh device_de_la_clé 
#	* Spécifier sur quel « device » créer la clé, sdb, sdc ou...

# Erreur de syntaxe
function Erreur
{
  echo "Il manque un paramètre"
  echo ""
  echo "*** Utilisation du script"
  echo "	/bin/bash persistence.sh device_de_la_clé"
  echo ""
  echo "		* Spécifier sur quel « device » créer la clé, sdb, sdc ou..."
  exit
}


VERIFPERSIST=$(ls / | grep persistence)

if [ "$VERIFPERSIST" = "persistence.conf" ]; then
  echo "La persistance existe déjà"
  echo "Vous n'avez pas besoin de lancer ce script"
  sleep 5
  exit
fi

echo "Voici les disques USB disponibles, ainsi que leur taille:"

USB_DISK_ID=$(ls /dev/disk/by-id/ | grep ^usb | grep ':0'$)

for i in $USB_DISK_ID
do
	USB_DISK_DEV=$(readlink -e /dev/disk/by-id/$i)
	SIZE=$(sudo parted -l | grep $USB_DISK_DEV | cut -d":" -f2)
	USBNAME=$(echo $USB_DISK_DEV | cut -d'/' -f3)
	echo "Disque $USBNAME, taille:$SIZE"
done

#Jusqu'à ce que la réponse soit composée par sd puis une lettre, j'attends la saisie
until [[ ${sd} =~ ^sd[a-z]$ ]]; do
echo "

Quel est l'identifiant de la clé USB utilisée pour studiobox? (sda? sdb? sdc? etc.)"
read sd
done

CLE=$sd
PART1="1"
PART2="2"

if  [ "$CLE" = "" ]
	then Erreur
fi

echo "*** Création de la partiton persistante"
START=`LC_ALL=C sudo parted /dev/$CLE print free | grep Free | grep [MG]B | gawk '{print $1}'`
END=`LC_ALL=C sudo parted /dev/$CLE print free | grep Free | grep [MG]B | gawk '{print $2}'`
sudo parted -a optimal /dev/$CLE mkpart primary ext2 $START $END
sudo mkfs.ext2 /dev/$CLE$PART2
echo "*** définition du label « persistence »"
sudo tune2fs -L persistence /dev/$CLE$PART2
sudo mount -t ext2 /dev/$CLE$PART2 /mnt
sleep 5
echo "*** Effacement du contenu de la partition persistante"
sudo rm -rf /mnt/*
PERSIST="persistence.conf"
echo "*** Copie du fichier « $PERSIST »"
echo "/ union" >> $PERSIST
sudo cp $PERSIST /mnt/$PERSIST
rm $PERSIST
sudo umount /dev/$CLE$PART2
echo "Votre clé est désormais persistante"
echo "Cela signifie que les modifications et réglages que vous effectuerez"
echo "à partir du prochain redémarrage ne seront pas effacés à chaque extinction du système."
echo ""
echo "Souhaitez-vous redémarrer dès maintenant? (oui / non)"
read reboot
if [ "$reboot" = 'oui' ]; then
	sudo reboot
fi
