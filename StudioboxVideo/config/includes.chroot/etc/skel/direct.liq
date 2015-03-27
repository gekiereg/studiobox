#
# En lançant ce script, tout ce qui entre sur la carte son gérée
# par ALSA est envoyé sur le serveur Icecast défini dans le script
#

liquidsoap 'output.icecast(%vorbis, mount="pointmontage.ogg",host="webradio.ac-versailles.fr", port=80 ,user="identifiant", password="motdepasse",input.alsa())'

