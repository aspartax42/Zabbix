#!/bin/bash -e

if [ "$UID" -ne 0 ]; then
  echo "Merci d'exécuter en root"
  exit 1
fi

# Principaux paramètres
tput setaf 7; read -p "Entrer le mot de passe root de la base de données: " ROOT_DB_PASS
tput setaf 7; read -p "Entrer le mot de passe zabbix de la base de données: " ZABBIX_DB_PASS
tput setaf 7; read -p "Entrer l'adresse IP du serveur Zabbix: " IP

tput setaf 2; echo ""

# Ajout de la variable PATH qui peux poser problème
export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:/usr/sbin
export PATH=$PATH:/sbin

# Récupération de la dernière version de Zabbix
cd /tmp
wget https://repo.zabbix.com/zabbix/5.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.2-1+ubuntu$(cat /etc/issue | cut -c 8-12)_all.deb
dpkg -i zabbix-release_5.2-1+ubuntu$(cat /etc/issue | cut -c 8-12)_all.deb
apt update
apt -y install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent


# Installation de MariaDB
apt -y install mariadb-server

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
mysql -uroot -p'$ROOT_DB_PASS' -e "drop database if exists zabbix;"
mysql -uroot -p'$ROOT_DB_PASS' -e "drop user if exists zabbix@localhost;"
mysql -uroot -p'$ROOT_DB_PASS' -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -uroot -p'$ROOT_DB_PASS' -e "grant all on zabbix.* to 'zabbix'@'%' identified by '"$ZABBIX_DB_PASS"' with grant option;"



# Ajout de la table SQL dans notre DB zabbix_proxy

mysql -uroot -p'$ROOT_DB_PASS' -D zabbix -e "set global innodb_strict_mode='OFF';"
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz |  mysql -u zabbix --password=$ZABBIX_DB_PASS zabbix
mysql -uroot -p'$ROOT_DB_PASS' -D zabbix -e "set global innodb_strict_mode='ON';"


# Ajout du mot de passe Zabbix dans le fichier de conf
echo "StartPollers=100
StartPollersUnreachable=50
StartPingers=50
StartTrappers=10
StartDiscoverers=15
StartPreprocessors=15
StartHTTPPollers=5
StartAlerters=5
StartTimers=2
StartEscalators=2
CacheSize=128M
HistoryCacheSize=64M
HistoryIndexCacheSize=32M
TrendCacheSize=32M
ValueCacheSize=256M" >> /etc/zabbix/zabbix_server.conf
echo "DBPassword="$ZABBIX_DB_PASS"" >> /etc/zabbix/zabbix_server.conf

systemctl restart zabbix-server zabbix-agent 
systemctl enable zabbix-server zabbix-agent


# Configuration de Zabbix Frontend

echo "php_value date.timezone Europe/Paris" >> /etc/zabbix/apache.conf

systemctl restart apache2
systemctl enable apache2





# Grafana
wget https://dl.grafana.com/oss/release/grafana_7.2.1_amd64.deb
apt install -y adduser libfontconfig
dpkg -i grafana_7.2.1_amd64.deb
systemctl enable  grafana-server
systemctl start  grafana-server
grafana-cli plugins install alexanderzobnin-zabbix-app
grafana-cli plugins install simpod-json-datasource
grafana-cli plugins install grafana-simple-json-datasource
systemctl restart grafana-server


clear
echo "-------------------------------------------------"
tput bold; tput setaf 7; echo "       => Installation terminée <=       "
tput setaf 7; echo ""
tput setaf 7; echo "URL du serveur Zabbix: http://"$IP"/zabbix"
tput setaf 7; echo "Login: Admin / MDP: zabbix"
echo ""
tput setaf 7; echo "URL du serveur Grafana: http://"$IP":3000"
tput setaf 7; echo "Login: admin / MDP: admin"

tput setaf 7; echo ""


tput setaf 7; echo ""
tput setaf 7; echo ""
tput bold; tput setaf 6; echo "       By Lilian COLLARD       "
tput setaf 2; echo ""
