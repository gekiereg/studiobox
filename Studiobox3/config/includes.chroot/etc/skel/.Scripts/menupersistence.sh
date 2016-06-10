#!/bin/bash

if [ -e /persistence.conf ] && [ -e "$HOME/.config/openbox/menupersistence.xml" ]; then
	mv $HOME/.config/openbox/menupersistence.xml $HOME/.config/openbox/menu.xml
	mv $HOME/.config/openbox/menupersistence2.xml $HOME/.config/openbox/menu2.xml
	sed -i '/menupersistence/d' .config/openbox/autostart.sh
	openbox --restart
elif [ ! -e /persistence.conf ] && [ ! -e "$HOME/.config/openbox/menupersistence.xml" ]; then
	sed -i '/menupersistence/d' .config/openbox/autostart.sh
else
	zenity --info --title="Bienvenue sur Studiobox3" --text="Studiobox fonctionne actuellement en mode 'non-persistent'.
Cela signifie que tous les réglages que vous effectuez et fichiers que vous créez sont effacés à chaque redémarrage.
Si vous souhaitez utiliser Studiobox en mode 'persistent', et conserver réglages et fichiers au redémarrage,
utilisez l'outil de création de la persistance, dans le menu principal > 'Administration' > 'Rendre la clé persistante'

Pour mémoire:
- votre nom d'utilisateur est 'studiobox'
- Votre mot de passe est 'live'"
fi
