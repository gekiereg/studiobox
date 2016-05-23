#!/bin/bash

echo "Ce script a pour objectif de configurer le proxy."
echo "À la fin du script, un test de connexion est lancé"
echo "afin de vérifier le bon fonctionnement du réseau."
echo "Si le test échoue, la configuration est annulée"
echo "et il vous sera proposé de relancer la configuration"
echo "ou d'abandonner."

sleep 3

function saveoldproxy {
if [ -e /etc/profile.d/proxy.sh ]; then
	sudo mv /etc/profile.d/proxy.sh /etc/profile.d/proxy.sh.old
fi
if [ -e /etc/apt/apt.conf.d/99HttpProxy ]; then
	sudo mv /etc/apt/apt.conf.d/99HttpProxy /etc/apt/apt.conf.d/99HttpProxy.old
fi
if [ -e $HOME/.wgetrc ]; then
	mv $HOME/.wgetrc $HOME/.wgetrc.old
fi
}

function restoreoldproxy {
if [ -e /etc/profile.d/proxy.sh.old ]; then
	sudo mv /etc/profile.d/proxy.sh.old /etc/profile.d/proxy.sh
fi
if [ -e /etc/apt/apt.conf.d/99HttpProxy.old ]; then
	sudo mv /etc/apt/apt.conf.d/99HttpProxy.old /etc/apt/apt.conf.d/99HttpProxy
fi
if [ -e $HOME/.wgetrc.old ]; then
	mv $HOME/.wgetrc.old $HOME/.wgetrc
fi
}

function supprimerproxy {
sudo rm /etc/profile.d/proxy.sh
sudo rm /etc/apt/apt.conf/d/99HttpProxy
rm $HOME/.wgetrc
}

function confproxyauth {
sudo echo "export http_proxy=http://$idproxy:$passproxy@$urlproxy:$portproxy" > /etc/profile.d/proxy.sh
sudo echo "Acquire::http::Proxy "http://$idproxy:$passproxy@$urlproxy:$portproxy";" > /etc/apt/apt.conf.d/99HttpProxy
sudo echo "http_proxy = http://$idproxy:$passproxy@$urlproxy:$portproxy" > $HOME/.wgetrc
}

function confproxynonauth {
sudo echo "export http_proxy=http://$urlproxy:$portproxy" > /etc/profile.d/proxy.sh
sudo echo "Acquire::http::Proxy "http://$urlproxy:$portproxy";" > /etc/apt/apt.conf.d/99HttpProxy
sudo echo "http_proxy = http://$urlproxy:$portproxy" > $HOME/.wgetrc
}

function proxyconf {
#attente de l'adresse du proxy
echo "Note: pour supprimer tout réglage de proxy, laisser vide en appuyant directement sur la touche entrée."
sleep 2
read -p "Veuillez saisir l'adresse du proxy (ex: '172.20.0.246' ou 'proxy.serveur.com'): " urlproxy

if [ -z "$urlproxy" ]
	echo "Suppression du proxy sur le système"
	supprimerproxy
	exit
fi

#attente du port du proxy
echo ""
read -p "Veuillez saisir le port du proxy (ex: '80', '3128'): " portproxy


#attente de l'identifiant
echo ""
echo "Note: si le proxy n'est pas authentifié, laisser vide en appuyant directement sur la touche entrée."
sleep 2
read -p "Si le proxy est authentifié, veuillez saisir le compte utilisé: " idproxy


if [ -n "$idproxy" ]; then
	#si le proxy est authentifié, attente du mot de passe associé
	read -p "Si le proxy est authentifié, veuillez saisir le mot de passe: " passproxy
fi
}

function verifconnect {
echo "Vérification de la connectivité"
wget -q --tries=20 --timeout=10 http://www.google.com -O /tmp/google.idx &> /dev/null
if [ ! -s /tmp/google.idx ]; then
	CONNECT='echec'	
else
	CONNECT='reussite'
	rm /tmp/google.idx
fi
}

function verifconnectapt {
TESTERREURAPT=$(sudo aptitude update | grep ^Err)
if [ -n "$TESTERREURAPT" ]; then
	CONNECTAPT='echec'
else
	CONNECTAPT='reussite'
fi
}

saveoldproxy
proxyconf
if [ -n "$idproxy" ]; then
	confproxyauth
else
	confproxynonauth
fi
verifconnect
verifconnectapt
if [ "$CONNECT" = 'reussite' ] && [ "$CONNECTAPT" = 'reussite' ]; then
	echo "La nouvelle configuration du proxy fonctionne."
	sleep 5
	exit
else
	#attente d'une réponse qui soit "a" ou "r"
	until [[ ${finscript} =~ ^[ar]$ ]]; do
		echo "La configuration ne semble pas correcte."
		echo "Vous avez le choix entre retenter une configuration (r)"
		echo "ou abandonner et restaurer l'ancienne version du proxy (a)"
		read -p "Abandon avec restauration de l'ancienne version (a) ou nouvelle tentative (r)?: " finscript
	done
	if [ "$finscript" = "a" ]; then
		restoreoldproxy
		echo "Ancienne configuration restaurée"
		echo "Fin du script"
		sleep 5
		exit
	else
		restoreoldproxy
		bash proxyconf.sh
fi
