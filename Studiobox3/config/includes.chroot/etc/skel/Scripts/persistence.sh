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
  exit
fi

echo "Voici les disques disponibles, ainsi que leur taille:"

sudo parted -l | grep ^'Disk /dev'
#Jusqu'a ce que la reponse soit composée par sd puis une lettre, j'attends la saisie
until [[ ${sd} =~ ^sd[a-z]$ ]]; do
echo "

Quel est l'identifiant de la clé USB utilisée pour StrabOS? (sda? sdb? sdc? etc.)"
read nombre
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
sudo parted /dev/$CLE mkpart primary ext2 $START $END
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
echo "à partir de maintenant ne seront pas effacés au reboot"
