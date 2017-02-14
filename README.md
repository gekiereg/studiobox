Studiobox3
=============================================

Studiobox3 est une distribution GNU/Linux orientée multimédia basée sur Debian Jessie. Elle est destinée aux enseignants souhaitant construire des projets multimédias (son, vidéo, radio, etc.).

# Caractéristiques principales #

Studiobox est avant tout une distribution "live", destinée à être utilisée depuis une clé USB. Dans ce cas, l'utilisateur est `studiobox` et le mot de passe est `live`.

Pour conserver des qualités de légèreté, l'environnement de bureau est composé de : 

* Openbox (gestionnaire de fenêtres);
* PcmanFM (gestionnaire de fichiers);
* LightDM (gestionnaire d'affichage);

Les entrées de menu `Install` ou `Grapical Install` au démarrage permettent d'installer Studiobox sans aucune intervention ni configuration (preseed). Dans ce cas, l'utilisateur est `studiobox` et le mot de passe est `studiobox`.

# Principaux logiciels inclus #

* Visualiseurs son et vidéo : Vlc ;
* Montage vidéo : dvgrab, Kdenlive, gnome-subtitles, Cinelerra, kino ;
* Montage audio : Audacity ;
* Utilitaires vidéo et son : Winff, Soundconverter ;
* Webradio : Icecast2, Airtime, Liquidsoap ;
* Graphisme : Gimp, Gpicview, Gcolor2 ;
* Gravure et outils divers : Xfburn, Devede, Filezilla ;
* Bureautique: Abiword, Gnumeric, Gedit, evince ;
* Système : gdebi, synaptic, gparted, arandr ;


# Graver studiobox sur une clé #

## Pour les utilisateurs de GNU/Linux ##

Prérequis:

* les paquets suivants sont installés: parted, coreutils, util-linux, e2fsprogs, gawk
* vous disposez d'une clé USB d'au moins 2 Go (attention: toutes les données présentes sur cette clé seront détruites)
* vous avez téléchargé l'[image iso de la studiobox](http://www.education-aux-medias.ac-versailles.fr/studiobox/) ainsi que le [script d'installation automatique](http://www.education-aux-medias.ac-versailles.fr/studiobox/creation_cle_sb3.sh)

Pour créer la clé, placez dans un répertoire dédié l'image iso et le script `creation_cle_sb3.sh`

* Ouvrez un terminal, et rendez ce script exécutable :

```sh
# chmod u+x creation_cle_sb3.sh
```

* Lancez le script en indiquant le fichier iso de studiobox, sur le modèle suivant:

```sh
# bash creation_cle_sb3.sh fichier.iso
```

Que fait le script ? Dans l'ordre, il vous demandera d'indiquer l'identifiant de la clé usb sur laquelle graver StudioBox, puis y supprimera tout ce qui s'y trouve, et enfin installera le système studiobox et créera une deuxième partition qui servira à stocker les données et rendre le système _persistant_ (les réglages et manipulations effectuées seront conservées au redémarrage).

## Pour les utilisateurs de Windows ##

Si vous ne possédez qu'un système Windows, vous pouvez créer la clé avec le logiciel [Rufus](https://rufus.akeo.ie/). Sélectionnez la clé USB, cocher `Créer un disque de démarrage` et choisir `Image ISO` dans le menu déroulant. Sélectionner enfin le fichier iso de studiobox précédemment téléchargé puis lancer la gravure en cliquant sur `Démarrer`. Attention: le système créé ainsi n'est pas _persistant_ (réglages et manipulations sont effacés à chaque redémarrage). Il est possible de rendre le système persistant en suivant la méthode indiquée à l'ouverture de la session studiobox.

# Utilisation dans un contexte non versaillais #

Les scripts présents sur Studiobox sont préconfigurés pour fonctionner avec certains services mis en place par l'académie de Versailles. Cependant, il sera très aisé d'adapter Studiobox a un usage dans un contexte différent.

Par exemple, il suffit de modifier la variable 

> SERVEURACAD='webradio.ac-versailles.fr'

dans le script de diffusion radio (`/home/studiobox/.Scripts/diffrec-LS.bash`) pour diffuser vers le serveur icecast de son choix.

# Construire sa propre image studiobox #

* Cloner le dépôt [studiobox](https://gitlab.crdp.ac-versailles.fr/francois.lafont/studiobox/)
* Se rendre dans le répertoire `/Studiobox3`
* Lancer la commande

```sh
# lb build
```

* Être patient...

# Contribuer à Studiobox #

Toute proposition d'amélioration, de correction de bugs, etc. est bienvenue. 

Une liste de diffusion permet aux membres du projet d'échanger: [studiobox@ac-versailles.fr](https://messagerie.ac-versailles.fr/listes/info/studiobox)
