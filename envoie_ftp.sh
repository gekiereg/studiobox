#!/bin/bash
# Script d'envoie ftp du site web

Site="ftp-mutualise.ac-versailles.fr"
Dossier="auto"

User=$1
Pass=$2
Version=$3
Iso=$4
Home=$5
DossierDL=$6
DossierImages=$7

Ici=`pwd`

#if [ $Version = "studioboxAudio" ]
#	then
#			cd $DossierPreseed
#			echo "user $User $Pass" > commands.txt
#			echo "cd $Dossier" >> commands.txt
#			echo "put script_post_install" >> commands.txt
#			echo "put desktop.list.binary" >> commands.txt
#			echo "quit" >> commands.txt
#			echo "*** Transfert de des fichiers pour auto par FTP"
#			ftp -n $Site < commands.txt
#			read r
#			rm commands.txt
#fi

####################
# À décommenter pour vérifier la transmission de paramètres
####################
echo -e " Home : \t$MONHOME\n  Rep DebianLive (DossierDL) : \t$DossieDL\n \
Rep images (DossierImages) : \t$DossierImages\n  \
Version : \t$Version\n Iso :  \t$Iso\n"
#exit


cd $DossierImages
echo "user $User $Pass" > commands.txt
echo "put $Iso" >> commands.txt
echo "quit" >> commands.txt
echo "*** Transfert de $Iso par FTP"
ftp -n $Site < commands.txt
rm commands.txt


cd $Ici
