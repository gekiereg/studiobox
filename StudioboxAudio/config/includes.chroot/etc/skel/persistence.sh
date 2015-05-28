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

CLE=$1
PART1="1"
PART2="2"

if  [ "$CLE" = "" ]
	then Erreur
fi

echo "*** Création de la partiton persistante"
START=`sudo parted /dev/$CLE print free | grep Free | grep [MG]B | gawk '{print $1}'`
END=`sudo parted /dev/$CLE print free | grep Free | grep [MG]B | gawk '{print $2}'`
sudo parted /dev/$CLE mkpart primary ext2 $START $END
sudo mkfs.ext2 /dev/$CLE$PART2
echo "*** définition du label « persistence »"
sudo tune2fs -L persistence /dev/$CLE$PART2
sudo mount -t ext2 /dev/$CLE$PART2 /mnt
sleep 5
echo "*** Effacement du contenu de la partition persistante"
sudo rm -rf /mnt/*
echo "*** Copie du fichier « live-persistence.conf »"
echo "/ union" >> live-persistence.conf
sudo cp live-persistence.conf /mnt/live-persistence.conf
rm live-persistence.conf
sudo umount /dev/$CLE$PART2
echo "Votre clé est désormais persistante"
echo "Cela signifie que les modifications et réglages que vous effectuerez"
echo "à partir de maintenant ne seront pas effacés au reboot"
