#!/bin/bash

set -e

echo "Actualizando paquetes..."
apt update

echo "Instalando Apache2, PHP y extensión MySQL..."
apt install -y apache2 php libapache2-mod-php php-mysql mariadb-client

echo "Habilitando Apache..."
service apache2 start

echo "Webserver inicializado correctamente."
echo "Ingresar desde el navegador a: http://localhost:8080"

tail -f /var/log/apache2/access.log