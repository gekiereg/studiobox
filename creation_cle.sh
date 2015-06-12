#!/bin/bash
# Script de création des clés studioBox
# Utilisation du script
#	/bin/bash creation_cle.sh device_de_la_clé version image_iso
#	* Spécifier sur quel « device » créer la clé, sdb, sdc ou...
#	* Indiquer le chemin et le nom de l'image iso téléchargée

# Erreur de syntaxe
function Erreur
{
  echo "Il manque un ou plusieurs paramètres"
  echo ""
  echo "*** Utilisation du script"
  echo "	/bin/bash creation_cle.sh device_de_la_clé version image_iso"
  echo ""
  echo "		* Spécifier sur quel « device » créer la clé, sdb, sdc ou..."
  echo "		* Spécifier la version, studioboxAudio, studioboxVideo ou..."
  echo "		* Spécifier l'image iso de la studiobox à utiliser..."
  
  exit
}

CLE=$1
VERSION=$2
IMAGE=$3
PART1="1"
PART2="2"

#sudo umount /dev/$CLE*

if  [ "$CLE" = "" ] || [ "$2" = "" ];
	then Erreur
fi

MONTAGE=`mount | grep $CLE | cut -d " " -f3`
echo "*** Attention, vous allez effacer tout le contenu de /dev/$CLE"
if [ "$MONTAGE" != "" ]
    then
    echo "*** qui correspond à $MONTAGE"
fi
echo "*** Voulez-vous continuer ? (oui/Non)"
read REPONSE
if [ "$REPONSE" != "oui" ]
    then exit
fi

if [ "$MONTAGE" != "" ]
    then
    echo "Démontage de $MONTAGE"
    umount $MONTAGE
fi

echo "*** Effacement des deux partitions"
sudo parted /dev/$CLE rm 1
sudo parted /dev/$CLE rm 2
echo "*** Création de la partition StudioBox"
sudo dd if=$IMAGE of=/dev/$CLE 
sync
echo "*** Création de la partiton persistante"
START=`LC_ALL=C sudo parted /dev/$CLE print free | grep Free | grep [MG]B | gawk '{print $1}'`
END=`LC_ALL=C sudo parted /dev/$CLE print free | grep Free | grep [MG]B | gawk '{print $2}'`
sudo parted /dev/$CLE mkpart primary ext2 $START $END
sudo mkfs.ext2 /dev/$CLE$PART2
echo "*** définition du label « persistence »"
sudo tune2fs -L persistence /dev/$CLE$PART2
sudo mount -t ext2 /dev/$CLE$PART2 /mnt
PERSIST='persistence.conf'
sleep 5
echo "*** Effacement du contenu de la partition persistante"
sudo rm -rf /mnt/*
if [ "$VERSION" = "studioboxAudio" ]
then
  echo "*** Copie du fichier « $PERSIST »"
  echo "/ union" >> $PERSIST
else
  echo "*** Copie du fichier « $PERSIST »"
  echo "/home union" >> $PERSIST
fi
sudo cp $PERSIST /mnt/$PERSIST
rm $PERSIST
sudo umount /dev/$CLE$PART2
echo "Votre clé est prête"
echo "Vous pouvez la retirer et démarrer un ordinateur avec"
echo "Happy hacking…"
