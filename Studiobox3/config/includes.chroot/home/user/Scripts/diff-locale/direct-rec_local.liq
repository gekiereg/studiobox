
#
# En lançant ce script, tout ce qui entre sur la carte son gérée
# par ALSA est envoyé sur le serveur Icecast défini dans le script
#


liquidsoap 's=output.icecast(%vorbis, mount="webradio.ogg",host="localhost", port=8000 , password="webradio",input.alsa(device="hw:0,0"))' 'output.file(%vorbis,"~/Musique/%Y-%m-%d-%H_%M_%S.ogg",s)'
