#!/bin/bash

echo "Ce script a pour objectif de configurer le proxy."
echo "À la fin du script, un test de connexion est lancé"
echo "afin de vérifier le bon fonctionnement du réseau."
echo "Si le test échoue, la configuration est annulée"
echo "et il vous sera proposé de relancer la configuration"
echo "ou d'abandonner."

sleep 1

DIR='/home/studiobox'

cd .mozilla/firefox/*.default/
CHEMINJS=$(pwd)
cd ../../../

function saveoldproxy {
if [ -e /etc/environment ]; then
	 cp /etc/environment /etc/environment.old
fi
if [ -e $DIR/.wgetrc ]; then
	mv $DIR/.wgetrc $DIR/.wgetrc.old
fi
cp $CHEMINJS/prefs.js $CHEMINJS/prefs.old.js
}

function restoreoldproxy {
if [ -e /etc/environment ]; then
	 mv /etc/environment.old /etc/environment
fi
if [ -e $DIR/.wgetrc.old ]; then
	mv $DIR/.wgetrc.old $DIR/.wgetrc
fi
if [ -e $CHEMINJS/prefs.old.jd ]; then
	cp $CHEMINJS/prefs.old.js $CHEMINJS/prefs.js
fi
}

function supprimerproxy {
if [ -e $DIR/.wgetrc ]; then
	rm $DIR/.wgetrc
fi
sed -i '/^HTTP/d' /etc/environment
sed -i '/^FTP/d' /etc/environment
FIREFOX=$(pgrep firefox)
if [ -n "$FIREFOX" ]; then
	kill $FIREFOX
	sleep 1
fi
sed -i '/network./d' $CHEMINJS/prefs.js
}

function confproxyauth {
echo "http_proxy = http://$urlproxy:$portproxy/
https_proxy = http://$urlproxy:$portproxy/
ftp_proxy = http://$urlproxy:$portproxy/
proxy_user = $idproxy
proxy_password = $passproxy
use_proxy = on" > $DIR/.wgetrc
echo "HTTP_PROXY=\"http://$idproxy:$passproxy@$urlproxy:$portproxy/\";" >> /etc/environment
echo "HTTPS_PROXY=\"http://$idproxy:$passproxy@$urlproxy:$portproxy/\";" >> /etc/environment
echo "FTP_PROXY=\"http://$idproxy:$passproxy@$urlproxy:$portproxy/\";" >> /etc/environment
FIREFOX=$(pgrep firefox)
if [ -n "$FIREFOX" ]; then
	kill $FIREFOX
	sleep 1
fi
echo "user_pref(\"network.cookie.prefsMigrated\", true);
user_pref(\"network.predictor.cleaned-up\", true);
user_pref(\"network.proxy.ftp\", \"$idproxy:$passproxy@$urlproxy\");
user_pref(\"network.proxy.ftp_port\", $portproxy);
user_pref(\"network.proxy.http\", \"$idproxy:$passproxy@$urlproxy\");
user_pref(\"network.proxy.http_port\", $portproxy);
user_pref(\"network.proxy.share_proxy_settings\", true);
user_pref(\"network.proxy.socks\", \"$idproxy:$passproxy@$urlproxy\");
user_pref(\"network.proxy.socks_port\", $portproxy);
user_pref(\"network.proxy.ssl\", \"$idproxy:$passproxy@$urlproxy\");
user_pref(\"network.proxy.ssl_port\", $portproxy);
ser_pref(\"network.proxy.type\", 1);" >> $CHEMINJS/prefs.js
}


function confproxynonauth {
echo "http_proxy = http://$urlproxy:$portproxy/
https_proxy = http://$urlproxy:$portproxy/
ftp_proxy = http://$urlproxy:$portproxy/
proxy_user = $idproxy
proxy_password = $passproxy
use_proxy = on" > $DIR/.wgetrc
echo "HTTP_PROXY=\"http://$urlproxy:$portproxy/\";" >> /etc/environment
echo "HTTPS_PROXY=\"http://$urlproxy:$portproxy/\";" >> /etc/environment
echo "FTP_PROXY=\"http://$urlproxy:$portproxy/\";" >> /etc/environment
FIREFOX=$(pgrep firefox)
if [ -n "$FIREFOX" ]; then
	kill $FIREFOX
	sleep 1
fi
echo "user_pref(\"network.cookie.prefsMigrated\", true);
user_pref(\"network.predictor.cleaned-up\", true);
user_pref(\"network.proxy.ftp_port\", $portproxy);
user_pref(\"network.proxy.http\", \"$urlproxy\");
user_pref(\"network.proxy.http_port\", $portproxy);
user_pref(\"network.proxy.share_proxy_settings\", true);
user_pref(\"network.proxy.socks\", \"$urlproxy\");
user_pref(\"network.proxy.socks_port\", $portproxy);
user_pref(\"network.proxy.ssl\", \"$urlproxy\");
user_pref(\"network.proxy.ssl_port\", $portproxy);
ser_pref(\"network.proxy.type\", 1);" >> $CHEMINJS/prefs.js
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
echo "La configuration du proxy est terminée"
echo "Vous pouvez réutiliser ce script pour configurer à nouveau ou supprimer le proxy"
sleep 3
#echo "Vérification de la connectivité. Soyez patient!"
#verifconnect
#verifconnectapt
#if [ "$CONNECT" = 'reussite' ] && [ "$CONNECTAPT" = 'reussite' ]; then
##if [ "$CONNECT" = 'reussite' ]; then
#	echo "La nouvelle configuration du proxy fonctionne."
#	echo "Pour reconfigurer le proxy, relancer ce script."
#	sleep 5
#	exit
#else
#	#attente d'une réponse qui soit "c", "a" ou "r"
#	until [[ ${finscript} =~ ^[car]$ ]]; do
#		echo "La configuration ne semble pas correcte."
#		echo "Vous avez le choix entre:"
#		echo "1) retenter une configuration (r)"
#		echo "2) abandonner et restaurer l'ancienne version du proxy (a)"
#		echo "3) confirmer malgré tout cette configuration (c)"
#		read -p "Retenter (r), abandonner (a) ou confirmer (c)? :" finscript
#	done
#	if [ "$finscript" = "a" ]; then
#		restoreoldproxy
#		echo "Ancienne configuration restaurée"
#		echo "Pour reconfigurer le proxy, relancer ce script."
#		echo "Fin du script"
#		sleep 2
#		exit
#	elif [ "$finscript" = "c" ]; then
#		echo "La nouvelle configuration est en place."
#		echo "Pour reconfigurer le proxy, relancer ce script."
#		sleep 2
#		exit
#	elif [ "$finscript" = "r"]; then
#		bash proxyconf.sh relance
#	fi
#fi
