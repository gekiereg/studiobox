#!/bin/bash

DIR1='/home/studiobox'

echo "Ce script a pour objectif de configurer le proxy."
echo "À la fin du script, un test de connexion est lancé"
echo "afin de vérifier le bon fonctionnement du réseau."
echo "Si le test échoue, la configuration est annulée"
echo "et il vous sera proposé de relancer la configuration"
echo "ou d'abandonner."

sleep 3

function saveoldproxy {
sudo cp /etc/profile /etc/profile.old
if [ -e /etc/environment ]; then
	sudo cp /etc/environment /etc/environment.old
fi
if [ -e $DIR1/.wgetrc ]; then
	mv $DIR1/.wgetrc $DIR1/.wgetrc.old
fi
}

function restoreoldproxy {
sudo cp /etc/profile.old /etc/profile
if [ -e /etc/environment ]; then
	sudo mv /etc/environment.old /etc/environment
fi
if [ -e $DIR1/.wgetrc.old ]; then
	mv $DIR1/.wgetrc.old $DIR1/.wgetrc
fi
}

function supprimerproxy {
rm $DIR1/.wgetrc
sudo sed -i '/^HTTP/d' /etc/environment
sudo sed -i '/^FTP/d' /etc/environment
sudo sed -i '/MY_PROXY_URL/d' /etc/profile
}

function confproxyauth {
sudo echo "HTTP_PROXY=\"http://$idproxy:$passproxy@$urlproxy:$portproxy/\"
HTTPS_PROXY=\"http://$idproxy:$passproxy@$urlproxy:$portproxy/\"
FTP_PROXY=\"http://$idproxy:$passproxy@$urlproxy:$portproxy/\"
http_proxy=\"http://$idproxy:$passproxy@$urlproxy:$portproxy/\"
https_proxy=\"http://$idproxy:$passproxy@$urlproxy:$portproxy/\"
ftp_proxy=\"http://$idproxy:$passproxy@$urlproxy:$portproxy/\"
export HTTP_PROXY HTTPS_PROXY FTP_PROXY http_proxy https_proxy ftp_proxy" >> /etc/profile 
echo "http_proxy = http://$urlproxy:$portproxy/
https_proxy = http://$urlproxy:$portproxy/
ftp_proxy = http://$urlproxy:$portproxy/
proxy_user = $idproxy
proxy_password = $passproxy
use_proxy = on" > $DIR1/.wgetrc
sudo echo "HTTP_PROXY=\"http://$idproxy:$passproxy@$urlproxy:$portproxy/\";" > /etc/environment
sudo echo "HTTPS_PROXY=\"http://$idproxy:$passproxy@$urlproxy:$portproxy/\";" >> /etc/environment
sudo echo "FTP_PROXY=\"http://$idproxy:$passproxy@$urlproxy:$portproxy/\";" >> /etc/environment
}

function confproxynonauth {
sudo echo "HTTP_PROXY=\"http://$urlproxy:$portproxy/\"
HTTPS_PROXY=\"http://$urlproxy:$portproxy/\"
FTP_PROXY=\"http://$urlproxy:$portproxy/\"
http_proxy=\"http://$urlproxy:$portproxy/\"
https_proxy=\"http://$urlproxy:$portproxy/\"
ftp_proxy=\"http://$urlproxy:$portproxy/\"
export HTTP_PROXY HTTPS_PROXY FTP_PROXY http_proxy https_proxy ftp_proxy" >> /etc/profile 
echo "http_proxy = http://$urlproxy:$portproxy/
https_proxy = http://$urlproxy:$portproxy/
ftp_proxy = http://$urlproxy:$portproxy/
proxy_user = $idproxy
proxy_password = $passproxy
use_proxy = on" > $DIR1/.wgetrc
sudo echo "HTTP_PROXY=\"http://$urlproxy:$portproxy/\";" > /etc/environment
sudo echo "HTTPS_PROXY=\"http://$urlproxy:$portproxy/\";" >> /etc/environment
sudo echo "FTP_PROXY=\"http://$urlproxy:$portproxy/\";" >> /etc/environment
}

function proxyconf {
#attente de l'adresse du proxy
echo "Note: pour supprimer tout réglage de proxy, laisser vide en appuyant directement sur la touche entrée."
read -p "Veuillez saisir l'adresse du proxy (ex: '172.20.0.246' ou 'proxy.serveur.com'): " urlproxy

if [ -z "$urlproxy" ]; then
	echo "Suppression du proxy sur le système"
	supprimerproxy
	sleep 3
	exit
fi

#attente du port du proxy
echo ""
read -p "Veuillez saisir le port du proxy (ex: '80', '3128'): " portproxy


#attente de l'identifiant
echo ""
echo "Note: si le proxy n'est pas authentifié, laisser vide en appuyant directement sur la touche entrée."
read -p "Si le proxy est authentifié, veuillez saisir le compte utilisé: " idproxy


if [ -n "$idproxy" ]; then
	#si le proxy est authentifié, attente du mot de passe associé
	read -p "Si le proxy est authentifié, veuillez saisir le mot de passe: " passproxy
fi
}

function verifconnect {
wget -q --tries=20 --timeout=10 http://www.google.com -O /tmp/google.idx &> /dev/null
if [ ! -s /tmp/google.idx ]; then
	CONNECT='echec'	
else
	CONNECT='reussite'
	rm /tmp/google.idx
fi
}

function verifconnectapt {
TESTERREURAPT=$(aptitude update | grep ^Err)
if [ -n "$TESTERREURAPT" ]; then
	CONNECTAPT='echec'
else
	CONNECTAPT='reussite'
fi
}

if [ "$1" = 'relance' ]; then 
	supprimerproxy	
else
	saveoldproxy
fi
proxyconf
if [ -n "$idproxy" ]; then
	confproxyauth
else
	confproxynonauth
fi
echo "Vérification de la connectivité. Soyez patient!"
verifconnect
verifconnectapt
if [ "$CONNECT" = 'reussite' ] && [ "$CONNECTAPT" = 'reussite' ]; then
#if [ "$CONNECT" = 'reussite' ]; then
	echo "La nouvelle configuration du proxy fonctionne."
	echo "Pour reconfigurer le proxy, relancer ce script."
	sleep 5
	exit
else
	#attente d'une réponse qui soit "c", "a" ou "r"
	until [[ ${finscript} =~ ^[car]$ ]]; do
		echo "La configuration ne semble pas correcte."
		echo "Vous avez le choix entre:"
		echo "1) retenter une configuration (r)"
		echo "2) abandonner et restaurer l'ancienne version du proxy (a)"
		echo "3) confirmer malgré tout cette configuration (c)"
		read -p "Retenter (r), abandonner (a) ou confirmer (c)? :" finscript
	done
	if [ "$finscript" = "a" ]; then
		restoreoldproxy
		echo "Ancienne configuration restaurée"
		echo "Pour reconfigurer le proxy, relancer ce script."
		echo "Fin du script"
		sleep 2
		exit
	elif [ "$finscript" = "c" ]; then
		echo "La nouvelle configuration est en place."
		echo "Pour reconfigurer le proxy, relancer ce script."
		sleep 2
		exit
	elif [ "$finscript" = "r"]; then
		bash proxyconf.sh relance
	fi
fi
