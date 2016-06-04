#
# En lançant ce script, tout ce qui entre sur la carte son gérée
# par ALSA est envoyé sur le serveur Icecast défini dans le script
#


liquidsoap 'output.icecast(%vorbis(quality=0.9), mount="webradio.ogg",host="localhost",port=8001,user="source",password="webradio",input.alsa(device="hw:0,0"))'
