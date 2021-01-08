Ce script bash permet l'automatisation de l'installation et de la configuration d'un proxy Zabbix.

Plusieurs informations sont alors demandées:
  - Le mot de passe root de la base de données
  - Le mot de passe de l'utilisateur zabbix de la base de données
  - Le nom du serveur principal Zabbix
  - Le nom du proxy Zabbix
  - Le nom de l'identité PSK

L'identité PSK servant à chiffrer la connexion entre le proxy et le serveur principal.

Pour récupérer le script, il suffit de faire les commandes suivantes:
 - ```git clone https://github.com/aspartax42/Zabbix_Proxy_Install.git```
 - ```cd Zabbix_Proxy_Install```
 - ```chmod +x zabbix_proxy_install.sh```
 - ```./zabbix_proxy_install.sh```
