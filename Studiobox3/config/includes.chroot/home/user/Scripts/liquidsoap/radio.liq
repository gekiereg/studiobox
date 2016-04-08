#!/usr/bin/liquidsoap

set("log.file",false)
set("log.stdout",true)
set("log.level",3)

%include "library.liq"

set("server.telnet",true)

# The file source
songs = playlist("/home/fx/Musique/Rocks 70/")

# The jingle source
jingles = playlist("/home/fx/Musique/salsa/")

# We combine the sources and play 
# one single every 3 songs:
s = rotate(weights=[1,3], [jingles, songs])

# We output the stream to an icecast
# server, in ogg/vorbis format.
# Stream it out
output.icecast.vorbis(host = "radio.crdp.ac-versailles.fr",port = 80,password = "radio-2012",user= "fx",mount = "fx.ogg",mksafe(s))
