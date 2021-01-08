# Zabbix-agent-Windows
Il faut tout d'abord pocéder un serveur Zabbix principal. 
Il est aussi possible d'avoir un proxy Zabbix afin de sécuriser la communication entre le serveur principal Zabbix et les hôtes d'un client.

Il faut tout d'abord télécharger l'agent Zabbix pour Windows à cette adresse https://www.zabbix.com/downloads/4.4.10/zabbix_agent-4.4.10-windows-amd64-openssl.msi puis l'exécuter. Faire suivant tout le long.

Une fois installé, copier ce fichier de conf avec comme paramètres ```ServerActive=``` et ```Server=```le nom de votre proxy ou le nom de votre serveur principal.
