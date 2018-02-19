#!/bin/bash
# Script de création de la persistance de la clé studiobox

VERIFPERSIST=$(ls /lib/live/mount/persistence/sd* | grep persistence.conf)

if [ -e $VERIFPERSIST ]; then
  echo "La persistance existe déjà"
  echo "Vous n'avez pas besoin de lancer ce script"
  sleep 5
  exit
fi

CLE=$1
PART1="1"
PART2="2"

if  [ "$CLE" = "" ]
	then exit
fi

echo "*** Création de la partiton persistante"
START=`LC_ALL=C sudo parted $CLE print free | grep Free | grep [MG]B | gawk '{print $1}'`
END=`LC_ALL=C sudo parted $CLE print free | grep Free | grep [MG]B | gawk '{print $2}'`
sudo parted -a optimal -s $CLE mkpart primary ext2 $START $END
sudo mkfs.ext2 $CLE$PART2
echo "*** définition du label « persistence »"
sudo tune2fs -L persistence $CLE$PART2
sudo mount -t ext2 $CLE$PART2 /mnt
sleep 5
echo "*** Effacement du contenu de la partition persistante"
sudo rm -rf /mnt/*
PERSIST="persistence.conf"
echo "*** Copie du fichier « $PERSIST »"
echo "/ union" >> $PERSIST
sudo cp $PERSIST /mnt/$PERSIST
rm $PERSIST
sudo umount $CLE$PART2
