#!/bin/bash
# Script de création des clés studioBox
# Utilisation du script
#	/bin/bash creation_cle.sh image_iso
#	* Indiquer le chemin et le nom de l'image iso téléchargée

# Erreur de syntaxe
function Erreur
{
  echo ""
  echo "*** Utilisation du script:"
  echo "	/bin/bash creation_cle_sb3.sh image_iso"
  echo "Merci d'indiquer l'emplacement de l'image iso de StudioBox en paramètre."
  echo ""
  exit
}

function DisqueUSB
{
USB_DISK_ID=$(ls /dev/disk/by-id/ | grep ^usb | grep ':0'$)

if [ -z $USB_DISK_ID ]; then
	echo "Studiobox est conçue pour être installée sur une clé USB."
	echo "Veuillez connecter une clé USB à l'ordinateur pour utiliser ce script."
	exit
else
	echo ""
	echo "Voici les disques USB disponibles, ainsi que leur taille:"

	for i in $USB_DISK_ID
	do
		USB_DISK_DEV=$(readlink -e /dev/disk/by-id/$i)
		SIZE=$(sudo parted -l | grep $USB_DISK_DEV | cut -d":" -f2)
		USBNAME=$(echo $USB_DISK_DEV | cut -d'/' -f3)
		echo "Disque $USBNAME, taille:$SIZE"
	done

	#Jusqu'à ce que la réponse soit composée par sd puis une lettre, j'attends la saisie
	until [[ ${sd} =~ ^sd[a-z]$ ]]; do
	read -p  "Identifiant de la clé USB qui sera utilisée pour studiobox (sdb? sdc? etc.): " sd
	done
	CLE=$sd
fi
}

if [ "$1" = "" ];
	then Erreur
fi

DisqueUSB

PART1="1"
PART2="2"

DISQUE=(`sudo fdisk -l | grep ^/dev/$CLE`)
if [ "$DISQUE" = "" ]; then
    Erreur
else
    MONTE=(`mount | grep ^/dev/$CLE | cut -b 1-9`)
    if [ "$MONTE" != "" ]; then
        NBPART=${#MONTE[@]}
        let NBPART-=1
        while  [ "$NBPART" -ge 0 ]; do
	PART=${MONTE[$NBPART]}
	sudo umount $PART
	let NBPART-=1
        done
    fi
fi

echo "*** Effacement des deux partitions"
sudo parted /dev/$CLE rm 1
sudo parted /dev/$CLE rm 2
echo "*** Création de la partition StudioBox"
dd if=$1 of=/dev/$CLE bs=4M; sync
echo "*** Création de la partiton persistante"
START=`sudo parted /dev/$CLE print free | grep Free | grep [MG]B | gawk '{print $1}'`
END=`sudo parted /dev/$CLE print free | grep Free | grep [MG]B | gawk '{print $2}'`
sudo parted -a optimal /dev/$CLE mkpart primary ext2 $START $END
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
