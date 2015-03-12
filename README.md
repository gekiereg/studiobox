How to build a Studiobox USB key step by step
=============================================

Take a fresh installation of a simple **Debian Wheezy**.
Firstly, you must install the building environment. We
assume that you use a Unix account with a "sudo" access (it
could be `root` but, in this case, the `sudo` command is not
necessary). Normally, you must launch these commands below
just once:

```sh
# Use a svn account that can access to the repository below.
SVN_ACCOUNT="lafont"
SVN_URL="https://svn.crdp.ac-versailles.fr/svn/formation/trunk/Education_aux_media/WebRadio/Documentation/Diaporamas"
GIT_URL="http://gitlab.crdp.ac-versailles.fr:80/francois.lafont/studiobox.git"
DOC_SVN_DIR="$HOME/Diaporamas"
STDBOX_GIT_DIR="$HOME/studiobox"
BUILD_DIR="$HOME/build_dir"

# Some packages are needed (ssl is needed for the svn repository).
sudo apt-get update
# TODO: list of packages probably incomplete.
sudo apt-get install openssl ca-certificates git subversion rsync live-build

# Get the git and svn repositories.
cd "$HOME" && git clone "$GIT_URL"
cd "$HOME" && svn checkout "$SVN_URL" --username="$SVN_ACCOUNT"

# Create the building directory.
mkdir "$BUILD_DIR"
mkdir "$BUILD_DIR/DebianLive"
mkdir "$BUILD_DIR/DebianImg"
mkdir "$BUILD_DIR/DebianConfig"
ln -s "$STDBOX_GIT_DIR/creation_cle.sh" "$BUILD_DIR/creation_cle.sh"
ln -s "$STDBOX_GIT_DIR/Debian_Live.sh" "$BUILD_DIR/Debian_Live.sh"
ln -s "$STDBOX_GIT_DIR/envoie_ftp.sh" "$BUILD_DIR/envoie_ftp.sh"
cp -a "$STDBOX_GIT_DIR/Debian_Live_perso.sh" "$BUILD_DIR/Debian_Live_perso_me.sh"


# Modify Debian_Live_perso_me.sh to match with your directories.
sed -r -i -e "s|^MONHOME=.*$|MONHOME=\"$HOME\"|"                         \
          -e "s|^REP_DEPOT_PEDA=.*$|REP_DEPOT_PEDA=\"$STDBOX_GIT_DIR\StudioboxAudio\"|" \
          -e "s|^REP_WORK=.*$|REP_WORK=\"$BUILD_DIR\"|"                  \
          -e "s|^REP_LIVE=.*$|REP_LIVE=\"$BUILD_DIR/DebianLive\"|"       \
          -e "s|^REP_IMG=.*$|REP_IMG=\"$BUILD_DIR/DebianImg\"|"          \
          -e "s|^REP_CONFIG=.*$|REP_CONFIG=\"$BUILD_DIR/DebianConfig\"|" \
          -e "s|^REP_DOC=.*$|REP_DOC=\"$DOC_SVN_DIR\"|"                  \
    "$BUILD_DIR/Debian_Live_perso_me.sh"

# Create the key building directory.
cd "$BUILD_DIR/DebianConfig" && lb config
```

Now you can build the StudioBox USB key with:

```sh
# Use the BUILD_DIR variable defined above.
cd "$BUILD_DIR" && bash Debian_Live_perso_me.sh version arch [device_key]
```

where:
* `version` can have several values. For studioboxAudio it's `studioboxAudio`.
This option is mandatory.
* `arch` can have two values, `i386` or `amd64`. This option is mandatory
* If an USB key has to be created, the name of the device has to be specified.
For instance, `sdb` or `sdc` etc.

For instance, a typical launch could be:

```sh
cd "$BUILD_DIR" && bash Debian_Live_perso_me.sh studioboxAudio amd64
```