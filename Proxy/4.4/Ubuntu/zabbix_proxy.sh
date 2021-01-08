#!/bin/bash -e

if [ "$UID" -ne 0 ]; then
  echo "Merci d'exécuter en root"
  exit 1
fi

# Principaux paramètres
tput setaf 7; read -p "Entrer le mot de passe root de la base de données: " ROOT_DB_PASS
tput setaf 7; read -p "Entrer le mot de passe zabbix de la base de données: " ZABBIX_DB_PASS
tput setaf 7; read -p "Entrer le nom du serveur principal Zabbix: " ZABBIX_SERVER
tput setaf 7; read -p "Entrer le nom du proxy: " ZABBIX_PROXY_HOSTNAME
tput setaf 7; read -p "Entrer le nom de l'indentité PSK: " PSK_ID

tput setaf 2; echo ""

# Récupération du paquet Zabbix 4.4
cd /tmp

wget https://repo.zabbix.com/zabbix/4.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.4-1+$(lsb_release -sc)_all.deb

# Ajout de la variable PATH qui peux poser problème
export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:/usr/sbin
export PATH=$PATH:/sbin

# Décompression du paquet
dpkg -i zabbix-release_4.4-1+$(lsb_release -sc)_all.deb

# Mise à jour suite à l'ajout de Zabbix Release dans les sources.list
apt update

# Installation de zabbix-proxy-mysql
apt -y install zabbix-proxy-mysql

# Changement du mdp de la base de données MySQL
mysql_secure_installation <<EOF
y
ROOT_DB_PASS
ROOT_DB_PASS
y
y
y
y
EOF




# Configuration de la base de données
mysql -uroot -p'$ROOT_DB_PASS' -e "drop database if exists zabbix_proxy;"

mysql -uroot -p'$ROOT_DB_PASS' -e "drop user if exists zabbix@localhost;"

mysql -uroot -p'$ROOT_DB_PASS' -e "create database zabbix_proxy character set utf8 collate utf8_bin;"

mysql -uroot -p'$ROOT_DB_PASS' -e "grant all on zabbix_proxy.* to 'zabbix'@'%' identified by '"$ZABBIX_DB_PASS"' with grant option;"


# Ajout de la table SQL dans notre DB zabbix_proxy


mysql -uroot -p'$ROOT_DB_PASS' -D zabbix_proxy -e "set global innodb_strict_mode='OFF';"

zcat /usr/share/doc/zabbix-proxy-mysql*/schema.sql.gz |  mysql -u zabbix --password=$ZABBIX_DB_PASS zabbix_proxy

mysql -uroot -p'$ROOT_DB_PASS' -D zabbix_proxy -e "set global innodb_strict_mode='ON';"


# Génération de la clé PSK
openssl rand -hex 32 > /etc/zabbix/zabbix_proxy.psk
chown zabbix:zabbix /etc/zabbix/zabbix_proxy.psk
chmod 644 /etc/zabbix/zabbix_proxy.psk

# Execution du script de modification du fichier /etc/zabbix/zabbix_proxy.conf
echo "LogFile=/var/log/zabbix/zabbix_proxy.log
LogFileSize=1024

PidFile=/var/run/zabbix/zabbix_proxy.pid

SocketDir=/var/run/zabbix

DBName=zabbix_proxy
DBUser=zabbix



ConfigFrequency=60


StartPollers=10
StartPollersUnreachable=2
StartPingers=5
StartDiscoverers=5
CacheSize=128M
HistoryIndexCacheSize=100M
Timeout=30
ExternalScripts=/usr/lib/zabbix/externalscripts
FpingLocation=/usr/bin/fping
Fping6Location=/usr/bin/fping6
LogSlowQueries=3000

StartVMwareCollectors=5
VMwareFrequency=60
VMwareCacheSize=8M
VMwareTimeout=10

TLSConnect=psk
TLSPSKFile=/etc/zabbix/zabbix_proxy.psk" > /etc/zabbix/zabbix_proxy.conf

echo "Server="$ZABBIX_SERVER"" >> /etc/zabbix/zabbix_proxy.conf
echo "TLSPSKIdentity="$PSK_ID"" >> /etc/zabbix/zabbix_proxy.conf
echo "Hostname="$ZABBIX_PROXY_HOSTNAME"" >> /etc/zabbix/zabbix_proxy.conf
echo "DBPassword="$ZABBIX_DB_PASS >> /etc/zabbix/zabbix_proxy.conf


systemctl restart zabbix-proxy
systemctl enable zabbix-proxy

cd /tmp/
rm zabbix-release_*

clear
echo "-------------------------------------------------"
tput bold; tput setaf 7; echo "       => Installation terminée <=       "
tput setaf 7; echo ""
tput setaf 7; echo "Nom du proxy: "$ZABBIX_PROXY_HOSTNAME""
tput setaf 7; echo ""
tput setaf 7; echo "Nom du serveur principal Zabbix: "$ZABBIX_SERVER""
tput setaf 7; echo ""
tput setaf 7; echo "Nom de l'indentité PSK: "$PSK_ID""
tput setaf 7; echo ""
tput setaf 7; echo "Voici la clé PSK généré automatiquement: "
tput setaf 7; cat /etc/zabbix/zabbix_proxy.psk

tput setaf 7; echo ""
tput setaf 7; echo ""
tput bold; tput setaf 6; echo "       By Lilian COLLARD       "
tput setaf 2; echo ""
