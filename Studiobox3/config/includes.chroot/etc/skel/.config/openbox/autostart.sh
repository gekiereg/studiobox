.$GLOBALAUTOSTART

export OOO_FORCE_DESKTOP=gnome

nitrogen --restore &
tint2 &
sleep 1 && conky &
sleep 1 && volumeicon &
xset -dpms &
xset s noblank &
xset s off &
bash $HOME/.Scripts/menupersistence.sh &
