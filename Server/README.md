# Zabbix-Server

Ce script bash permet l'automatisation de l'installation et de la configuration d'un Serveur Zabbix.

Plusieurs informations sont alors demandées:

Le mot de passe root de la base de données
Le mot de passe de l'utilisateur zabbix de la base de données
Adresse IP de votre serveur Zabbix


Pour récupérer le script, il suffit de faire les commandes suivantes:

git clone https://github.com/aspartax42/Zabbix.git
cd Zabbix/Server/
Choisissez la version que vous souhaitez installer
Dans notre exemple cd 5.5/Debian
chmod +x zabbix_server.sh
./zabbix_server.sh
