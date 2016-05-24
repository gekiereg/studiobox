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
if [ -e /etc/profile.d/proxy.sh ]; then
	mv /etc/profile.d/proxy.sh /etc/profile.d/proxy.sh.old
fi
if [ -e /etc/apt/apt.conf.d/99HttpProxy ]; then
	mv /etc/apt/apt.conf.d/99HttpProxy /etc/apt/apt.conf.d/99HttpProxy.old
fi
if [ -e /etc/environment ]; then
	cp /etc/environment /etc/environment.old
fi
if [ -e $DIR1/.wgetrc ]; then
	mv $DIR1/.wgetrc $DIR1/.wgetrc.old
fi
}

function restoreoldproxy {
if [ -e /etc/profile.d/proxy.sh.old ]; then
	mv /etc/profile.d/proxy.sh.old /etc/profile.d/proxy.sh
fi
if [ -e /etc/apt/apt.conf.d/99HttpProxy.old ]; then
	mv /etc/apt/apt.conf.d/99HttpProxy.old /etc/apt/apt.conf.d/99HttpProxy
fi
if [ -e /etc/environment ]; then
	mv /etc/environment.old /etc/environment
fi
if [ -e $DIR1/.wgetrc.old ]; then
	mv $DIR1/.wgetrc.old $DIR1/.wgetrc
fi
}

function supprimerproxy {
#rm /etc/profile.d/proxy.sh
#rm /etc/apt/apt.conf/d/99HttpProxy
#rm $DIR1/.wgetrc
sed -i '/^HTTP/d' /etc/environment
sed -i '/^FTP/d' /etc/environment
}

function confproxyauth {
#echo "export http_proxy=http://$idproxy:$passproxy@$urlproxy:$portproxy" > /etc/profile.d/proxy.sh
echo "Acquire::http::Proxy \"http://$idproxy:$passproxy@$urlproxy:$portproxy\";" > /etc/apt/apt.conf.d/99HttpProxy
#echo "Acquire::ftp::Proxy "http://$idproxy:$passproxy@$urlproxy:$portproxy";;" >> /etc/apt/apt.conf.d/99HttpProxy
echo "http_proxy = http://$urlproxy:$portproxy/" > $DIR1/.wgetrc
echo "https_proxy = http://$urlproxy:$portproxy/" >> $DIR1/.wgetrc
echo "ftp = http://$urlproxy:$portproxy/" >> $DIR1/.wgetrc
echo "proxy_user = $idproxy" >> $DIR1/.wgetrc
echo "proxy_password = $passproxy" >> $DIR1/.wgetrc
echo "use_proxy = on" >> $DIR1/.wgetrc
echo "wait = 15" >> $DIR1/.wgetrc
chmod u+rw $DIR1/.wgetrc
echo "HTTP_PROXY=\"http://$idproxy:$passproxy@$urlproxy:$portproxy/\";" > /etc/environment
echo "HTTPS_PROXY=\"http://$idproxy:$passproxy@$urlproxy:$portproxy/\";" >> /etc/environment
echo "FTP_PROXY=\"http://$idproxy:$passproxy@$urlproxy:$portproxy/\";" >> /etc/environment
}

function confproxynonauth {
#echo "export http_proxy=http://$urlproxy:$portproxy" > /etc/profile.d/proxy.sh
echo "Acquire::http::Proxy \"http://$urlproxy:$portproxy\";" > /etc/apt/apt.conf.d/99HttpProxy
#echo "Acquire::ftp::Proxy \"http://$urlproxy:$portproxy\";" >> /etc/apt/apt.conf.d/99HttpProxy
echo "http_proxy = http://$urlproxy:$portproxy/" > $DIR1/.wgetrc
echo "https_proxy = http://$urlproxy:$portproxy/" >> $DIR1/.wgetrc
echo "ftp = http://$urlproxy:$portproxy/" >> $DIR1/.wgetrc
echo "proxy_user = $idproxy" >> $DIR1/.wgetrc
echo "proxy_password = $passproxy" >> $DIR1/.wgetrc
echo "use_proxy = on" >> $DIR1/.wgetrc
echo "wait = 15" >> $DIR1/.wgetrc
chmod u+rw $DIR1/.wgetrc
echo "HTTP_PROXY=i\"http://$urlproxy:$portproxy/\";" > /etc/environment
echo "HTTPS_PROXY=\"http://$urlproxy:$portproxy/\";" >> /etc/environment
echo "FTP_PROXY=\"http://$urlproxy:$portproxy/\";" >> /etc/environment
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
		sleep 5
		exit
	elif [ "$finscript" = "c" ]; then
		echo "La nouvelle configuration est en place."
		echo "Pour reconfigurer le proxy, relancer ce script."
		sleep 3
		exit
	elif [ "$finscript" = "r"]; then
		bash proxyconf.sh relance
	fi
fi
