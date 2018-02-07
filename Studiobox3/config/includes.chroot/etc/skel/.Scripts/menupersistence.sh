#!/bin/bash

if [ -e /persistence.conf ] && [ -e "$HOME/.config/openbox/menupersistence.xml" ]; then
	mv $HOME/.config/openbox/menupersistence.xml $HOME/.config/openbox/menu.xml
	mv $HOME/.config/openbox/menupersistence2.xml $HOME/.config/openbox/menu2.xml
	sed -i '/menupersistence/d' .config/openbox/autostart.sh
	openbox --restart
elif [ ! -e /persistence.conf ] && [ ! -e "$HOME/.config/openbox/menupersistence.xml" ]; then
	zenity --info --title="Bienvenue sur Studiobox3" --text="Bienvenue sur le système d'exploitation Studiobox3.
Pour mémoire:
- votre nom d'utilisateur est 'studiobox'
- votre mot de passe est 'studiobox'"
	sed -i '/menupersistence/d' .config/openbox/autostart.sh
else
	zenity --question --title="Bienvenue sur Studiobox3" --text="Studiobox fonctionne actuellement en mode 'non-persistent'.
Cela signifie que tous les réglages que vous effectuez et fichiers que vous créez seront effacés à chaque redémarrage.
Souhaitez-vous lancer l'outil de création de la persistance maintenant?"
	if [ $? = 0 ]; then
		USB_DISK_ID=$(ls /dev/disk/by-id/ | grep ^usb | grep ':0'$)
		USBDISKSLIST='.config/usbdiskslist'
		touch $USBDISKSLIST
		rm $USBDSIKSLIST
		echo $USB_DISK_ID > $USBDISKSLIST
	else
		exit
	fi
	NOMBREDISQUES=$(cat $USBDISKSLIST | wc -l)
	if [ $NOMBREDISQUES -eq 1 ]; then
		USB_DISK_DEV=$(readlink -e /dev/disk/by-id/$USB_DISK_ID)
		SIZE=$(sudo parted -l | grep $USB_DISK_DEV | cut -d":" -f2)
		USBNAME=$(echo $USB_DISK_DEV | cut -d'/' -f3)
		zenity --question --title="Mise en place de la persistence" --text="La clé $USB_DISK_DEV (taille:$SIZE) a été repérée comme clé usb Studiobox.
Mettre en place la persistance sur cette clé?" 2>/dev/null
		if [ $? = 0 ]; then
		lxterminal -e "sudo bash /home/studiobox/.Scripts/persistence.sh $USB_DISK_DEV" | tee >(zenity --no-cancel --progress --pulsate --autoclose --title="Mise en place de la persistance" --text="Cela peut prendre plusieurs minutes, selon la taille de la clé USB... merci de patienter" 2>/dev/null)
		else
			exit
		fi
	else
		CHOIXDISQUE=$(zenity --entry --title="Choisir la clé USB sur laquelle studiobox est installé" --text="Choisir la clé USB dans le menu déroulant" $USB_DISK_ID 2>/dev/null)
		USB_DISK_DEV=$(readlink -e /dev/disk/by-id/$CHOIXDISQUE)
		lxterminal -e "sudo bash /home/studiobox/.Scripts/persistence.sh $USB_DISK_DEV" | tee >(zenity --no-cancel --progress --pulsate --autoclose --title="Mise en place de la persistance" --text="Studiobox met en place la persistance, merci de patienter" 2>/dev/null)
	fi
	zenity --question --title="Persistance mise place" --text="La persistance sera activée au prochain redémarrage.
Souhaitez-vous redémarrer dès maintenant?" 2>/dev/null
	if [ $? = 0 ]; then
		reboot
	else
		exit
	fi
fi
