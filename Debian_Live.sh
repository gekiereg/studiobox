#!/bin/bash
#  
# Script de création de clé USB ou d'image ISO d'utilisation de CESAR
# Louis-Maurice De Sousa
# louis.de.sousa@crdp.ac-versailles.fr
#
# Version : 0.2
#
# Usage : 
#   - préparer une image Debian_live bootable
#
# Utilisation :
#   - Ce script est appelé par Debian_Live_perso_moi.sh, 
#     il prend les paramètres suivants :
#           
#
# Améliorations prévues :
#
#
#
#
# Dernière modification :     
#       5 juin 2009
#       22 juin 2013 - Corrections pour debian-live Wheezy
#       23 septembre - Réorganisation et ajout StudioBox
#       4 avril 2014 - Sortie des configurations locales dans un autre script
#################################
# Déclaration des fonctions
#################################

# Erreur de syntaxe
function Erreur
{
    echo "*** Utilisation du script"
    echo "    /bin/bash Debian_Live_perso_moi.sh version arch [device_de_la_clé]"
    echo ""
    echo "        * version peut prendre les valeurs « cesar », "
    echo "          « studioboxAudio » ou « studioboxVideo » et *est obligatoire*"
    echo "        * arch peut prendre les valeurs « i386 » ou « amd64 »"
    echo "          et est *obligatoire*"
    echo "        * S'il faut créer la clé dans la foulée, il faut spécifier sur quel "
    echo "          « device » créer la clé, sdb, sdc ou..."
    exit
}

# Erreur d'oubli de clé
function Erreur_cle
{
    echo "Vous n'avez pas mis de clé USB"    
    Erreur
}

# Erreur d'oubli de version
function Erreur_version
{
    echo "Vous n'avez pas mis quelle version créer, « cesar » ou « studiobox »"    
    Erreur
}

# Erreur d'oubli d'architecture
function Erreur_arch
{
    echo "Vous n'avez pas mis quelle architecture utiliser, « i386 » ou « amd64 »"    
    Erreur
}

# Préparation pour la création de Cesar
function PreparationCesar
{
    # Copie des configurations des démons
    rsync -av --exclude=".*" $REP3/$VERSION/config/includes.chroot/* \
            $REP1/config/includes.chroot/
    # Copie de la liste des logiciels à installer
    rsync -av --exclude=".*" $REP3/$VERSION/config/package-lists/* \
            $REP1/config/package-lists/
    # Copie des configurations des logiciels
    rsync -av --exclude=".*" $REP3/$VERSION/config/preseed/* $REP1/config/preseed/
}

# Préparation pour la création de StudioBoxAudio
function PreparationStudioBoxAudio
{
    # Mise à jour de la doc
    REP6=`pwd`
    cd $REP5
    svn update
    rm -rf $REP3/$VERSION/config/includes.chroot/etc/skel/Documents/*
    cp *.pdf $REP3/$VERSION/config/includes.chroot/etc/skel/Documents
    cd $REP6
    #read Z
    # Copie des dépôts supplémentaires
    echo "*** Copie des dépôts supplémentaires"
    rsync -av --exclude=".*" $REP3/$VERSION/config/archives/* \
            $REP1/config/archives/
    # Copie des fichiers de réponse pour l'installation
    echo "*** Copie des dépôts supplémentaires"
    rsync -av --exclude=".*" $REP3/$VERSION/config/debian-installer/* \
            $REP1/config/debian-installer/
    # Copie des configurations des logiciels
    echo "*** Copie des configurations des logiciels"
    rsync -av --exclude=".*" $REP3/$VERSION/config/hooks/* \
            $REP1/config/hooks/
    # Copie des configurations des logiciels
    echo "*** Copie des configurations des logiciels"
    rsync -av --exclude=".*" $REP3/$VERSION/config/includes.binary/* \
            $REP1/config/includes.binary/
    # Copie des configurations des démons
    echo "*** Copie des configurations des démons"
    rsync -av  $REP3/$VERSION/config/includes.chroot/* \
            $REP1/config/includes.chroot/
    # Copie de la liste des logiciels à installer
    echo "*** Copie de la liste des logiciels à installer"
    rsync -av --exclude=".*" $REP3/$VERSION/config/package-lists/* \
            $REP1/config/package-lists/
    # Copie des configurations des logiciels
    echo "*** Copie des configurations des logiciels"
    rsync -av --exclude=".*" $REP3/$VERSION/config/preseed/* \
            $REP1/config/preseed/
}

# Préparation pour la création de StudioBoxVideo
function PreparationStudioBoxVideo
{
    # Copie des configurations des démons
    echo "*** Copie des configurations des démons"
    rsync -av --exclude=".*" $REP3/$VERSION/config/includes.chroot/* \
            $REP1/config/includes.chroot/
    # Copie de la liste des logiciels à installer
    echo "*** Copie de la liste des logiciels à installer"
    rsync -av --exclude=".*" $REP3/$VERSION/config/package-lists/* \
            $REP1/config/package-lists/
    # Copie des configurations des logiciels
    echo "*** Copie des configurations des logiciels"
    rsync -av --exclude=".*" $REP3/$VERSION/config/preseed/* $REP1/config/preseed/
    # Copie des configurations des logiciels
    echo "*** Copie des configurations des logiciels"
    rsync -av --exclude=".*" $REP3/$VERSION/config/hooks/* $REP1/config/hooks/
    # Copie des configurations des logiciels
    echo "*** Copie des configurations des logiciels"
    rsync -av --exclude=".*" $REP3/$VERSION/config/includes.binary/* \
            $REP1/config/includes.binary/
    # Copie des dépôts supplémentaires
    echo "*** Copie des dépôts supplémentaires"
    rsync -av --exclude=".*" $REP3/$VERSION/config/archives/* $REP1/config/archives/
}

# Configuration de l'image de la clé
function Preparation
{
    echo "*** Création de l'arbre de configuration pour clé USB"
    lb config  
    if [ "$VERSION" = "cesar" ];
        then PreparationCesar
        elif [ "$VERSION" = "studioboxAudio" ];
            then PreparationStudioBoxAudio
            elif [ "$VERSION" = "studioboxVideo" ];
                then PreparationStudioBoxVideo
    fi

    echo ""
    echo "*** Si les fichiers se sont copiés correctement appuyer sur « Entrée »"
    read Z
    LISTE=`ls $REP3/$VERSION/config/packages.chroot/* | grep _all`
    if [ "$LISTE" != "" ];
        then
            cp $LISTE $REP1/config/packages.chroot
            if [ "$ARCH" = "amd64" ];
                then 
                    LISTE=`ls $REP3/$VERSION/config/packages.chroot/* | grep _amd64`
                else
                    LISTE=`ls $REP3/$VERSION/config/packages.root/* | grep _i386`
            fi
            cp $LISTE $REP1/config/packages.chroot
    fi
    echo "*** Création de l'image pour clé USB"
    sudo lb build 
    #2>&1 | tee build.log
    echo "*** Copie de l'image $VERSION-$ARCH-binary.hybrid.iso dans $REP2"
    cp binary.hybrid.iso $REP2/$VERSION-$ARCH-v$NVERSION-binary.hybrid.iso
}

function EnvoieFtp
{
    read -p "Souhaitez-vous transférer les images sur le site ? (oui/Non) " REPONSE
    if [ "$REPONSE" = "oui" ];
        then
            read -p "Identifiant de connexion : " ID
            read -s -p "Mot de passe de connexion : " PASS
            echo ""
	    ISO="$VERSION-$ARCH-v$NVERSION-binary.hybrid.iso"
            bash envoie_ftp.sh $ID $PASS $VERSION $ISO $MONHOME $REP1 $REP2
    fi
}

function MaJsvn
{
    read -p "Souhaitez-vous mettre à jour le SVN ? (oui/Non) " REPONSE
    if [ "$REPONSE" = "oui" ];
        then
            cd $VERSION
            tar -cjvf $REP4/$VERSION.tar.bz2 config/
            cd $REP4
            svn commit $VERSION.tar.bz2 
            cd $REP3
    fi
}
#################################
# Déclaration des variables
#################################

####################
# Ne pas modifier
####################

MONHOME=$1
REP_DEPOT_PEDA=$2                   # Répertoires du dépôt Subversion
REP_DEPOT_FORMATION=$3
REP1=$4                             # Répertoire où se trouve 
                                    #   l'arborescence de Debian_live
REP2=$5                             # Répertoire où sauvegarder 
                                    #   les images obtenues

REP4=$6
REP5=$7
DIST=$8
MIROIRDISTANT=$9                    # Mirroir à mettre dans le système
                                    #   de la clé
shift 9                             # Décalage dans les variables passées pour
                                    #   récupérer au-delà de $10
MIROIRLOCAL=$1                      # Mirroir à utiliser pour 
                                    #   construire la clé

VERSION=$2
NOM=$VERSION
ARCH=$3
CLE=$4
PROG="$VERSION/desktop.list.chroot" # Nom du fichier dans config/package-lists/ 
                                    #   qui contient la liste des programmes 
                                    #   à installer
REP3=`pwd`                          # Sauvegarde du répertoire courant

####################
# À modifier en fonction de la version à générer
####################
NVERSION="2.00"

####################
# À décommenter pour vérifier la transmission de paramètres
####################
#echo -e " Home : \t$MONHOME\n Svn péda (REP_DEPOT_PEDA) : \t$REP_DEPOT_PEDA\n \
#Svn formation (REP_DEPOT FORMATION) : \t$REP_DEPOT_FORMATION\n \
#Rep DebianLive (REP1) : \t$REP1\n Rep images (REP2) : \t$REP2\n  \
#Rep svn (REP4): \t$REP4\n Rep svn (REP5) : \t$REP5\n Distribution : \t$DIST\n \
#MiroirD : \t$MIROIRDISTANT\n MiroirL : \t$MIROIRLOCAL\n \
#Version : \t$VERSION\n Archi :  \t$ARCH\n Clé :  \t$CLE\n"
#exit

####################
# Vérifications des paramètres passés
####################
if  [ "$VERSION" != "cesar" ] && [ "$VERSION" != "studioboxAudio" ] \
        && [ "$VERSION" != "studioboxVideo" ];
    then Erreur_version
fi

if  [ "$ARCH" != "i386" ] && [ "$ARCH" != "amd64" ];
    then Erreur_arch
fi 

if [ "$VERSION" = "cesar" ];sftp://lmds@aptenodytes/home/lmds/Documents/Scripts/ip_publique.sh
    then 
        DBI="false" 
        DBIGUI="false" 
        USER="jules"
    elif [ "$VERSION" = "studioboxAudio" ] || [ "$VERSION" = "studioboxVideo" ];
        then 
            DBI="live"
            DBIGUI="true"
            if [ "$VERSION" = "studioboxAudio" ];
                then
                    USER="webradio"
                else
                    USER="video"
            fi
fi

# Définitions des paramètres de construction et des paramètres à passer au noyau
AUTOCONFIG='#!/bin/sh
lb config noauto \
     --architectures '$ARCH' \
     --bootappend-live "boot=live config locales=fr_FR.UTF-8 keyboard-layouts=fr \
          username='$USER' persistence timezone=Europe/Paris"\
     --mirror-binary '$MIROIRDISTANT/debian' \
     --mirror-bootstrap '$MIROIRLOCAL/debian' \
     --mirror-chroot-security '$MIROIRDISTANT/debian-security/' \
     --mirror-chroot-backports '$MIROIRLOCAL/debian/'\
     --archive-areas "main contrib non-free" \
     --chroot-filesystem squashfs \
     --debian-installer '$DBI' \
     --debian-installer-gui '$DBIGUI' \
     --source false \
     --updates false \
     --backports true \
     --memtest none \
     --verbose \
     "${@}"' 
#     --apt-recommends false \
#     --apt-indices false \
#     --firmware-binary true \
#     --firmware-chroot true \     

echo "****** Création de $VERSION en $ARCH ******"
#echo "*** Téléchargement des firmwares privateurs"
# Allez dans le répertoire de l'arborescence Debian-live
cd $REP1
echo "$AUTOCONFIG" > auto/config
chmod u+x auto/config
rm -rf config
sudo lb clean --purge

if  [ "$CLE" != "" ]
  then
    DISQUE=(`sudo fdisk -l | grep ^/dev/$CLE`)
      if [ "$DISQUE" = "" ]
        then
          Erreur_cle
        else
          MONTE=(`mount | grep ^/dev/$CLE | cut -b 1-9`)
          if [ "$MONTE" != "" ]
            then
              NBPART=${#MONTE[@]}
              let NBPART-=1
              while  [ "$NBPART" -ge 0 ]; do
               PART=${MONTE[$NBPART]}
               sudo umount $PART
               let NBPART-=1
             done
          fi
          Preparation
          bash ../Cles_DebianLive/creation_cle.sh $CLE $REP2/$VERSION-$ARCH-v$NVERSION-binary.hybrid.iso
      fi    
  else
    Preparation
fi

cd $REP3
MaJsvn
EnvoieFtp


