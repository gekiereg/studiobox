#!/bin/bash
#

#Nommer le point de montage.Tant que la variable est vide attente de la saisie.
while [ -z ${point[$i]} ]; do
echo "Veuillez saisir le nom du point de montage (sans le /) :"
read point
done

#Nommer le serveur de montage.Tant que la variable est vide attente de la saisie.
while [ -z ${hote[$i]} ]; do
echo "Veuillez saisir le nom complet (FQHN) du serveur icecast2 :"
read hote
done

#Tant que la variable est vide, j'attends la saisie
while [ -z ${port[$i]} ]; do
echo "Veuillez saisir le port :"
read port
done

#Tant que la variable est vide, j'attends la saisie
while [ -z ${pass[$i]} ]; do
echo "Veuillez saisir le mot de passe:"
read pass
done

#Tant que la variable est vide, j'attends la saisie
while [ -z ${quality[$i]} ]; do
echo "Quelle qualité video désirez-vous? Entrez un chiffre de 1(très médiocre) à 10 (excellent) :"
read quality
done

echo "Quelle taille de vidéo désirez-vous (largeur en pixel)?"
select yn in "720" "540" "480" "360" "240"; do
    case $yn in
        720 )l='720';h='576';break;;
	540 )l='540';h='432';break;;
	480 )l='480';h='384';break;;
	360 )l='360';h='288';break;;
	240 )l='240';h='192';break;;
    esac
done


while [ -z ${video[$i]} ]; do
echo "Veuillez saisir le chemin du fichier à diffuser :"
read video
done

echo "
#!/bin/bash
##
##
ffmpeg2theora $video -x $l -a $quality -v $quality -o /dev/stdout -  | oggfwd $hote $port $pass /$point" > diffusion-v.bash
chmod +x diffusion-v.bash
exec ./diffusion-v.bash
