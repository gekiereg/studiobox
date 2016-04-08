#!/bin/bash
# Script de création des clés studioBox
# Utilisation du script
#	/bin/bash creation_cle.sh device_de_la_clé image_iso
#	* Spécifier sur quel « device » créer la clé, sdb, sdc ou...
#	* Indiquer le chemin et le nom de l'image iso téléchargée

# Erreur de syntaxe
function Erreur
{
  echo "Il manque un ou plusieurs paramètres"
  echo ""
  echo "*** Utilisation du script"
  echo "	/bin/bash creation_cle.sh device_de_la_clé image_iso"
  echo ""
  echo "		* Spécifier sur quel « device » créer la clé, sdb, sdc ou..."
  exit
}

CLE=$1
PART1="1"
PART2="2"

if  [ "$CLE" = "" ] || [ "$2" = "" ];
	then Erreur
fi

echo "*** Effacement des deux partitions"
sudo parted /dev/$CLE rm 1
sudo parted /dev/$CLE rm 2
echo "*** Création de la partition StudioBox"
dd if=$2 of=/dev/$CLE 
sync
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
echo "*** Copie du fichier « persistence.conf »"
echo "/ union" >> persistence.conf
sudo cp persistence.conf /mnt/persistence.conf
rm persistence.conf
sudo umount /dev/$CLE$PART2
echo "Votre clé est prête"
echo "Vous pouvez la retirer et démarrer un ordinateur avec"
echo "Happy hacking…"
