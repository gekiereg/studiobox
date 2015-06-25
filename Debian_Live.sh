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
    echo "** Utilisation du script"
    echo "   /bin/bash Debian_Live_perso_moi.sh version arch type [device_de_la_clé]"
    echo ""
    echo "    * version peut prendre les valeurs « cesar », "
    echo "      « studioboxAudio » ou « studioboxVideo » et "
    echo "      *est obligatoire*"
    echo "    * arch peut prendre les valeurs « i386 » ou « amd64 »"
    echo "      et est *obligatoire*"
    echo "    * type peut prendre les valeurs « img » ou « iso »"
    echo "      et est *obligatoire*"
    echo "    * s'il faut créer la clé dans la foulée, il faut "
    echo "      spécifier sur quel « device » créer la clé, "
    echo "      sdb, sdc ou..."
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
    echo "Vous n'avez pas mis quelle version créer, « cesar », « studioboxAudio » ou « studioboxVideo »"    
    Erreur
}

# Erreur d'oubli de type
function Erreur_type
{
    echo "Vous n'avez pas mis quel type d'image créer, « iso », ou « img »"    
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
            $REP_LIVE/config/includes.chroot/
    # Copie de la liste des logiciels à installer
    rsync -av --exclude=".*" $REP3/$VERSION/config/package-lists/* \
            $REP_LIVE/config/package-lists/
    # Copie des configurations des logiciels
    rsync -av --exclude=".*" $REP3/$VERSION/config/preseed/* $REP_LIVE/config/preseed/
}

# Préparation pour la création de StudioBoxAudio
function PreparationStudioBoxAudio
{
    REP6=`pwd`
    # Mise à jour arborescence git
    echo "Récupération de la configuration sur git"
    echo "$REP_DEPOT_PEDA"
    cd $REP_DEPOT_PEDA
    git pull
    rm -r $REP_CONFIG
    echo "cp -ar * $REP_CONFIG"
    cp -ar $REP_DEPOT_PEDA  $REP_CONFIG
    #cd $REP6
    # Mise à jour de la doc
    echo "Mise à jour de la documentation"
    cd $REP_DOC
    svn update
    rm -rf $REP_CONFIG/config/includes.chroot/etc/skel/Documents/*
    cp *.pdf $REP_CONFIG/config/includes.chroot/etc/skel/Documents
    cd $REP6
    #read Z
    # Copie des dépôts supplémentaires
    echo "*** Copie des dépôts supplémentaires"
    rsync -av --exclude=".*" $REP_CONFIG/config/archives/* \
            $REP_LIVE/config/archives/
    # Copie des fichiers de réponse pour l'installation
    echo "*** Copie des dépôts supplémentaires"
    rsync -av --exclude=".*" $REP_CONFIG/config/debian-installer/* \
            $REP_LIVE/config/debian-installer/
    # Copie des configurations des logiciels
    echo "*** Copie des configurations des logiciels"
    rsync -av --exclude=".*" $REP_CONFIG/config/hooks/* \
            $REP_LIVE/config/hooks/
    # Copie des configurations des logiciels
    echo "*** Copie des configurations des logiciels"
    rsync -av --exclude=".*" $REP_CONFIG/config/includes.binary/* \
            $REP_LIVE/config/includes.binary/
    # Copie des configurations des démons
    echo "*** Copie des configurations des démons"
    rsync -av  $REP_CONFIG/config/includes.chroot/* \
            $REP_LIVE/config/includes.chroot/
    # Copie de la liste des logiciels à installer
    echo "*** Copie de la liste des logiciels à installer"
    rsync -av --exclude=".*" $REP_CONFIG/config/package-lists/* \
            $REP_LIVE/config/package-lists/
    # Copie des configurations des logiciels
    echo "*** Copie des configurations des logiciels"
    rsync -av --exclude=".*" $REP_CONFIG/config/preseed/* \
            $REP_LIVE/config/preseed/
    echo "*** Préparation de la version de butt"
    if [ "$ARCH" = "amd64" ]; then
        rm $REP_LIVE/config/includes.chroot/usr/local/bin/butt-i386
        mv $REP_LIVE/config/includes.chroot/usr/local/bin/butt-amd64 \
	$REP_LIVE/config/includes.chroot/usr/local/bin/butt
    else
        rm $REP_LIVE/config/includes.chroot/usr/local/bin/butt-amd64
        mv $REP_LIVE/config/includes.chroot/usr/local/bin/butt-i386 \
	$REP_LIVE/config/includes.chroot/usr/local/bin/butt
    fi
}

# Préparation pour la création de StudioBoxVideo
function PreparationStudioBoxVideo
{
    REP6=`pwd`
    # Mise à jour arborescence git
    echo "Récupération de la configuration sur git"
    cd $REP_DEPOT_PEDA 
    git pull
    rm -r $REP_CONFIG
    cp -ar $REP_DEPOT_PEDA/ $REP_CONFIG
    #cd $REP6
    # Mise à jour de la doc
    #echo "Mise à jour de la documentation"
    #cd $REP_DOC
    #svn update
    #rm -rf $REP_CONFIG/config/includes.chroot/etc/skel/Documents/*
    #cp *.pdf $REP_CONFIG/config/includes.chroot/etc/skel/Documents
    cd $REP6
    #read Z
    # Copie des dépôts supplémentaires
    echo "*** Copie des dépôts supplémentaires"
    rsync -av --exclude=".*" $REP_CONFIG/config/archives/* \
            $REP_LIVE/config/archives/
    # Copie des fichiers de réponse pour l'installation
    echo "*** Copie des dépôts supplémentaires"
    rsync -av --exclude=".*" $REP_CONFIG/config/debian-installer/* \
            $REP_LIVE/config/debian-installer/
    # Copie des configurations des logiciels
    echo "*** Copie des configurations des logiciels"
    rsync -av --exclude=".*" $REP_CONFIG/config/hooks/* \
            $REP_LIVE/config/hooks/
    # Copie des configurations des logiciels
    echo "*** Copie des configurations des logiciels"
    rsync -av --exclude=".*" $REP_CONFIG/config/includes.binary/* \
            $REP_LIVE/config/includes.binary/
    # Copie des configurations des démons
    echo "*** Copie des configurations des démons"
    rsync -av  $REP_CONFIG/config/includes.chroot/* \
            $REP_LIVE/config/includes.chroot/
    # Copie de la liste des logiciels à installer
    echo "*** Copie de la liste des logiciels à installer"
    rsync -av --exclude=".*" $REP_CONFIG/config/package-lists/* \
            $REP_LIVE/config/package-lists/
    # Copie des configurations des logiciels
    echo "*** Copie des configurations des logiciels"
    rsync -av --exclude=".*" $REP_CONFIG/config/preseed/* \
            $REP_LIVE/config/preseed/
}

# Configuration de l'image de la clé
function Preparation
{
    echo "*** Création de l'arbre de configuration pour clé USB"
    lb config  
    if [ "$VERSION" = "cesar" ];  then
	PreparationCesar
    elif [ "$VERSION" = "studioboxAudio" ]; then
	PreparationStudioBoxAudio
    elif [ "$VERSION" = "studioboxVideo" ]; then
	PreparationStudioBoxVideo
    fi

    echo ""
    if [ $MODE = "manuel" ]; then
	echo "*** Si les fichiers se sont copiés correctement appuyer sur « Entrée »"
	read Z
    fi
    LISTE=`ls $REP_CONFIG/config/packages.chroot/* | grep _all`
    if [ "$LISTE" != "" ]; then
        cp $LISTE $REP_LIVE/config/packages.chroot
        if [ "$ARCH" = "amd64" ]; then 
            LISTE=`ls $REP_CONFIG/config/packages.chroot/* | grep _amd64`
        else
            LISTE=`ls $REP_CONFIG/config/packages.root/* | grep _i386`
        fi
        cp $LISTE $REP_LIVE/config/packages.chroot
    fi
    echo "*** Création de l'image pour clé USB"
    sudo lb build 
    #2>&1 | tee build.log
    IMAGEISO="$REP_IMG/$VERSION-$DIST-$ARCH-v$NVERSION-live.$TYPE"
    echo "*** Copie de l'image $IMAGEISO dans $REP_IMG"
    cp *.$TYPE $IMAGEISO
}

function EnvoieFtp
{
    read -p "Souhaitez-vous transférer les images sur le site ? (oui/Non) " REPONSE
    if [ "$REPONSE" = "oui" ]; then
        read -p "Identifiant de connexion : " ID
        read -s -p "Mot de passe de connexion : " PASS
        echo ""
	ISO="$VERSION-$DIST-$ARCH-v$NVERSION-live.img"
        bash envoie_ftp.sh $ID $PASS $VERSION $ISO $MONHOME $REP_LIVE $REP_IMG
    fi
}

function MaJsvn
{
    read -p "Souhaitez-vous mettre à jour le SVN ? (oui/Non) " REPONSE
    if [ "$REPONSE" = "oui" ]; then
        cd $VERSION
        tar -cjvf $REP4/$VERSION.tar.bz2 config/
        cd $REP4
        svn commit $VERSION.tar.bz2 
        cd $REP_CONFIG
    fi
}
#################################
# Déclaration des variables
#################################

####################
# Ne pas modifier
####################

MONHOME=$1
REP_DEPOT_PEDA=$2                   # Répertoires du dépôt Git
REP_CONFIG=$3
REP_LIVE=$4                         # Répertoire où se trouve 
                                    #   l'arborescence de Debian_live
REP_IMG=$5                          # Répertoire où sauvegarder 
                                    #   les images obtenues
#REP4=$6
REP_DOC=$6
#DIST=$8
MIROIRDISTANT=$7                    # Mirroir à mettre dans le système
                                    #   de la clé
MIROIRLOCAL=$8                      # Mirroir à utiliser pour 
                                    #   construire la clé
MODE=$9
shift 9                             # Décalage dans les variables passées pour
                                    #   récupérer au-delà de $10
VERSION=$1
NOM=$VERSION
ARCH=$2
TYPE=$3
CLE=$4
PROG="$VERSION/desktop.list.chroot" # Nom du fichier dans
                                    #   config/package-lists/ qui 
                                    #   contient la liste des  
                                    #   programmes à installer
REP3=`pwd`                          # Sauvegarde du répertoire courant
####################
# À modifier en fonction de la version à générer
####################
DIST="wheezy"
NVERSION="2.20"


####################
# Vérifications des paramètres passés
####################
if  [ "$VERSION" != "cesar" ] && [ "$VERSION" != "studioboxAudio" ] \
        && [ "$VERSION" != "studioboxVideo" ]; then
    Erreur_version
fi

if  [ "$ARCH" != "i386" ] && [ "$ARCH" != "amd64" ]; then
    Erreur_arch
fi 

if [ "$TYPE" != "img" ] && [ "$TYPE" != "iso" ]; then
    Erreur_type
fi

if [ "$VERSION" = "cesar" ];  then 
    DBI="false" 
    DBIGUI="false" 
    USER="jules"
    REP_CONFIG="${REP_CONFIG}/cesar"
    REP_DEPOT_PEDA="${REP_DEPOT_PEDA}/cesar"
elif [ "$VERSION" = "studioboxAudio" ] || [ "$VERSION" = "studioboxVideo" ]; then 
    DBI="live"
    DBIGUI="true"
    if [ "$VERSION" = "studioboxAudio" ]; then
        USER="webradio"
	REP_CONFIG="${REP_CONFIG}/StudioboxAudio"
	REP_DEPOT_PEDA="${REP_DEPOT_PEDA}/StudioboxAudio"
    else
        USER="sbvideo"
	REP_CONFIG="${REP_CONFIG}/StudioboxVideo"
	REP_DEPOT_PEDA="${REP_DEPOT_PEDA}/StudioboxVideo"
    fi
fi

# Définitions des paramètres de construction et des paramètres à
#   passer au noyau
if [ "$TYPE" = "img" ]; then
	AUTOCONFIG='#!/bin/sh
	lb config noauto \
	     --architectures '$ARCH' \
	     --binary-images hdd \
	     --distribution '$DIST' \
	     --bootappend-live "boot=live config locales=fr_FR.UTF-8 keyboard-layouts=fr \
		  username='$USER' persistence timezone=Europe/Paris"\
	     --mirror-bootstrap '$MIROIRLOCAL/debian/' \
	     --mirror-chroot-security '$MIROIRLOCAL/debian-security/' \
	     --mirror-binary '$MIROIRDISTANT/debian/' \
	     --mirror-binary-security '$MIROIRDISTANT/debian-security/' \
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
	#     --mirror-chroot-backports '$MIROIRLOCAL/debian-backports/' \
#     --mirror-binary-backports '$MIROIRDISTANT/debian-backports/' \
else
	AUTOCONFIG='#!/bin/sh
	lb config noauto \
	     --architectures '$ARCH' \
	     --distribution '$DIST' \
	     --bootappend-live "boot=live config locales=fr_FR.UTF-8 keyboard-layouts=fr \
		  username='$USER' persistence timezone=Europe/Paris"\
	     --mirror-bootstrap '$MIROIRLOCAL/debian/' \
	     --mirror-chroot-security '$MIROIRLOCAL/debian-security/' \
	     --mirror-binary '$MIROIRDISTANT/debian/' \
	     --mirror-binary-security '$MIROIRDISTANT/debian-security/' \
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
	#     --mirror-chroot-backports '$MIROIRLOCAL/debian-backports/' \
fi

####################
# À décommenter pour vérifier la transmission de paramètres
####################
if [ $MODE = "manuel" ]; then
    echo -e " Home : \t$MONHOME\n Git péda (REP_DEPOT_PEDA) : \t$REP_DEPOT_PEDA\n \
Svn formation (REP_DEPOT FORMATION) : \t$REP_DEPOT_FORMATION\n \
Rep DebianLive (REP_LIVE) : \t$REP_LIVE\n Rep images (REP_IMG) : \t$REP_IMG\n  \
Rep Config (REP_CONFIG) : \t$REP_CONFIG\n \
Rep Doc (REP_DOC) : \t$REP_DOC\n Distribution : \t$DIST\n \
MiroirD : \t$MIROIRDISTANT\n MiroirL : \t$MIROIRLOCAL\n \
Version : \t$VERSION\n Archi :  \t$ARCH\n Clé :  \t$CLE\n"
    #exit
    echo $AUTOCONFIG
    read -p "Vérification des paramètres. Appuyer sur « Entrée » pour continuer ou \
« Ctrl-C » pour interrompre le script" Z
fi

echo "****** Création d'une image $TYPE de $VERSION en $ARCH ******"
#echo "*** Téléchargement des firmwares privateurs"
# Allez dans le répertoire de l'arborescence Debian-live
cd $REP_LIVE
echo "$AUTOCONFIG" > auto/config
chmod u+x auto/config
rm -rf config
sudo lb clean --purge

if  [ "$CLE" != "" ]; then
    DISQUE=(`sudo fdisk -l | grep ^/dev/$CLE`)
    if [ "$DISQUE" = "" ]; then
        Erreur_cle
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
        Preparation
        bash $REP3/creation_cle.sh $CLE $VERSION $IMAGEISO
    fi    
else
    Preparation
fi

cd $REP3
#MaJsvn
if [ $MODE = "manuel" ]; then
    EnvoieFtp
fi

