#!/bin/bash
#  
# Script de création de clé USB ou d'image ISO d'utilisation de CESAR ou 
# STUDIOBOXAUDIO ou STUDIOBOXVIDEO
# Louis-Maurice De Sousa
# louis.de.sousa@crdp.ac-versailles.fr
#
# Version : 0.1
#
# Usage : 
#   - préparer une image Debian_live bootable
#   - dans le cas d'une clé USB, création de la clé
#
# Utilisation :
#   - /bin/bash Debian_Live_perso_moi.sh version arch [device_de_la_clé]
#           - version peut prendre les valeurs « cesar », « studioboxAudio » 
#               ou « studioboxVideo » et est obligatoire
#           - arch peut prendre les valeurs « i386 » ou « amd64 » et est obligatoire
#           - S'il faut créer la clé dans la foulée, il faut spécifier 
#                sur quel « device » créer la clé, sdb ou sdc ou...
# Améliorations prévues :
#
# Dernière modification : 	
#       4 avril 2014
#
# Ce script sert à configurer ses paramètres locaux.
# Il est sous forme d'exemple, et n'est pas à modifier, ni à remonter 
# sur le Subversion.
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
MONHOME="/home/lmds"
# Emplacement du trunk du Subversion « dev_peda »
REP_DEPOT_PEDA="$MONHOME/Documents/Depot_Subversion/dev_peda/trunk"
# Emplacement de trunk du Subversion « formation »
REP_DEPOT_FORMATION="$MONHOME/Documents/Depot_Subversion/Formation/trunk"
REP1="$MONHOME/Documents/Applis/Debian_live"    # Répertoire où se trouve 
                                                #   l'arborescence de Debian_live
REP2="$MONHOME/Documents/Applis/Debian_live_img"    # Répertoire où sauvegarder
                                                    #   les images obtenues
# Répertoires du dépôt Subversion
REP4="$REP_DEPOT_PEDA/Scripts/Cles_DebianLive"
REP5="$REP_DEPOT_FORMATION/Education_aux_media/WebRadio/Documentation/Diaporamas"
DIST="wheezy"
MIROIRDISTANT="http://ftp.fr.debian.org"    # Mirroir à mettre dans le système
                                            #   de la clé
MIROIRLOCAL="http://altair/depot/mirror/ftp.fr.debian.org"           # Mirroir à utiliser pour
                                            #   construire la clé

/bin/bash Debian_Live.sh $MONHOME $REP_DEPOT_PEDA $REP_DEPOT_FORMATION \
    $REP1 $REP2 $REP4 $REP5 $DIST $MIROIRDISTANT $MIROIRLOCAL \
    $VERSION $ARCH $CLE 
