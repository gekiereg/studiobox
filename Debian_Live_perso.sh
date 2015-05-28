#!/bin/bash
#  
# Script de création de clé USB ou d'image ISO d'utilisation de
# CESAR ou STUDIOBOXAUDIO ou STUDIOBOXVIDEO
# Louis-Maurice De Sousa
# louis.de-sousa@ac-versailles.fr
#
# Version : 0.1
#
# Usage : 
#   - préparer une image Debian_live bootable
#   - dans le cas d'une clé USB, création de la clé
#
# Utilisation :
#  - /bin/bash Debian_Live_perso_moi.sh version arch [device_de_la_clé]
#    - version peut prendre les valeurs « cesar », « studioboxAudio » 
#      ou « studioboxVideo » et est obligatoire
#    - arch peut prendre les valeurs « i386 » ou « amd64 »
#      et est obligatoire
#    - S'il faut créer la clé dans la foulée, il faut spécifier 
#      sur quel « device » créer la clé, sdb ou sdc ou...
# Améliorations prévues :
#
# Dernière modification : 	
#       4 avril 2014
#
# Ce script sert à configurer ses paramètres locaux.
# Il est sous forme d'exemple, et n'est pas à modifier, ni à remonter 
# sur le Git.
# En faire une copie qui *elle* sera modifiée.
#
####################
# Ne pas modifier
####################
VERSION=$1
ARCH=$2
CLE=$3
####################
# À modifier en fonction de l'environnement de travail
####################
MONHOME="/home/user/Documents"
# Emplacement du dépôt git de studiobox
REP_DEPOT_PEDA="$MONHOME/Dépôt_git/studiobox"
# Répertoire de travail
REP_WORK="$MONHOME/StudioBoxAudio"
# Répertoire où se trouve  l'arborescence de DebianLive
REP_LIVE="$REP_WORK/DebianLive"
# Répertoire où sauvegarder les images obtenues
REP_IMG="$REP_WORK/DebianImg"

# (Répertoire où sauvegarder la config ?)
REP_CONFIG="$REP_WORK/DebianConfig"

# Répertoires du dépôt Subversion
#REP4="$REP_DEPOT_PEDA/Scripts/Cles_DebianLive"
# Répertoire de la documentation sur le Subversion
REP_DOC="$REP_DEPOT_FORMATION/Education_aux_media/WebRadio/Documentation/Diaporamas"
#DIST="wheezy"
# Mirroir à mettre dans le système de la clé
MIROIRDISTANT="http://ftp.fr.debian.org"
# Mirroir à utiliser pour construire la clé
#MIROIRLOCAL="http://altair/depot/mirror/ftp.fr.debian.org"
MIROIRLOCAL="http://ftp.fr.debian.org"

MODE="manuel"

/bin/bash Debian_Live.sh $MONHOME $REP_DEPOT_PEDA $REP_DEPOT_FORMATION \
	  $REP_CONFIG $REP_LIVE $REP_IMG $REP_DOC $MIROIRDISTANT \
	  $MIROIRLOCAL $MODE $VERSION $ARCH $CLE 
