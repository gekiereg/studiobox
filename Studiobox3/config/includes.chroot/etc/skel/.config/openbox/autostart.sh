.$GLOBALAUTOSTART

export OOO_FORCE_DESKTOP=gnome

nitrogen --restore &
tint2 &
sleep 1 && conky &
sleep 1 && volumeicon &
sleep 1 && bash $HOME/.Scripts/menupersistence.sh
