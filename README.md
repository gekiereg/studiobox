Studiobox
=========

Build a live USB key for webradio usage.

working_dir="/home/user"
1 create a working directory (StudioBoxAudio)

```sh
mkdir $working_dir/StudioBoxAudio
```

2 in this directory create three directories
  one for the livebuild (DebianLive)
  one to prepare the chroot (DebianChroot)
  one to store the image (DebianImg)

```sh
mkdir $working_dir/StudioBoxAudio/DebianLive
mkdir $working_dir/StudioBoxAudio/DebianChroot
mkdir $working_dir/StudioBoxAudio/DebianImg
```
3 create symbolic links for 
  creation_cle.sh
  Debian_Live.sh
  envoie_ftp.sh  
  in StudioBoxAudio
4 copy Debian_Live_perso.sh as Debian_Live_perso_me.sh in
the working directory
