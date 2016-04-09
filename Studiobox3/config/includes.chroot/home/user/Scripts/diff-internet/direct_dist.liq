
#
# En lançant ce script, tout ce qui entre sur la carte son gérée
# par ALSA est envoyé sur le serveur Icecast défini dans le script
#

liquidsoap 'output.icecast(%vorbis, mount="lyc-mounier-chatenay.ogg",host="webradio.ac-versailles.fr", port=8000 , password="45re32Ze",input.alsa(device="hw:0,0"))'
