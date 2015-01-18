Studiobox
=========

Build a live USB key for webradio usage.

1 create a working directory (StudioBoxAudio)

```sh
home_dir="/home/user"
git_studiobox_dir="/home/user/git_repo/studiobox"
mkdir $home_dir/StudioBoxAudio
working_dir="$home_dir/StudioBoxAudio"
```

2 in this directory create three directories
  one for the livebuild (DebianLive)
  one to prepare the configuration (DebianConfig)
  one to store the image (DebianImg)

```sh
mkdir $working_dir/DebianLive
mkdir $working_dir/DebianConfig
mkdir $working_dir/DebianImg
```
3 create symbolic links for 
  creation_cle.sh
  Debian_Live.sh
  envoie_ftp.sh  
  in StudioBoxAudio

```sh
ln -s $git_studiobox_dir/creation_cle.sh $working_dir/creation_cle.sh
ln -s $git_studiobox_dir/Debian_Live.sh $working_dir/dir/Debian_Live.sh
ln -s $git_studiobox_dir/envoie_ftp.sh $working_dir/envoie_ftp.sh
```

4 copy Debian_Live_perso.sh as Debian_Live_perso_me.sh in
the working directory

```sh
cp $git_studiobox_dir/Debian_Live_perso.sh $working_dir/Debian_Live_perso_me.sh
```

5 make Debian_Live_perso_me.sh fit your filesystem

6 launch Debian_Live_perso_me.sh

```sh
/bin/bash Debian_Live_perso_me.sh version arch [device_key]
```

    - "version" can have several values. For studioboxAudio it's "studioboxAudio". 
    This option is mandatory
    - "arch" can have two values, "i386" or "amd64".
    This option is mandatory
    - If an USB key has to be created the name of the device has to be specified.
    "sdb" or "sdc" or...