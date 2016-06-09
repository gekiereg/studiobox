#!/bin/bash

if [ -e /persistence.conf ] && [ -e "$HOME/.config/openbox/menupersistence.xml" ]; then
	mv $HOME/.config/openbox/menupersistence.xml $HOME/.config/openbox/menu.xml
	mv $HOME/.config/openbox/menupersistence2.xml $HOME/.config/openbox/menu2.xml
	openbox --restart
fi
