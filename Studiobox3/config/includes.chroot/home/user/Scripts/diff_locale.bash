#!/bin/bash

IP=$(sudo ifconfig  | grep 'inet adr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')

zenity --info --title="Pour vous écouter..." --text="Le direct se lancera quand vous fermerez cette fenêtre.
Pour vous écouter sur le réseau de l'établissement, ouvrir un navigateur web et y indiquer l'url suivante:
http://$IP:8000/webradio.ogg" 

exec ~/Scripts/direct_local.liq
