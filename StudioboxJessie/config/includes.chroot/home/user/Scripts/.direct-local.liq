#
# En lançant ce script, tout ce qui entre sur la carte son gérée
# par ALSA est envoyé sur le serveur Icecast défini dans le script
#

IP=$(sudo ifconfig  | grep 'inet adr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')

zenity --info --title="Pour vous écouter..." --text="Le direct se lancera quand vous fermerez cette fenêtre.
Pour vous écouter sur le réseau de l'établissement, ouvrir un navigateur web et y indiquer l'url suivante:
http://$IP:8000/webradio.ogg"
liquidsoap 'output.icecast(%vorbis, mount="webradio.ogg",host="localhost", port=8000 , password="webradio",input.alsa(id="0"))' 
