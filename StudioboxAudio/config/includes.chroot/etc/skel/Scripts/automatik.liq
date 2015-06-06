#!/usr/bin/liquidsoap

#
#Script destiné à jouer un jingle tous les 3 morceaux de musique
#

set("log.file",false)
set("log.stdout",true)
set("log.level",3)

%include "library.liq"

set("server.telnet",true)

# Source de musiques
songs = playlist("/dossier_local_contenant_la_musique/")

# Source de Jingles
jingles = playlist("/dossier_local_contenant_les_jingles/")

# We combine the sources and play 
# one jingle every 3 songs:
s = rotate(weights=[1,3], [jingles, songs])

# We output the stream to an icecast
# server, in ogg/vorbis format.
# Stream it out
output.icecast.vorbis(host = "webradio.ac-versailles.fr",port = 8000,password = "motdepasse",user= "utilisateur",mount = "pointdemontage.ogg",mksafe(s))
