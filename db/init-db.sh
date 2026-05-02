#!/bin/bash

set -e

DB_NAME="laboratorio_db"
DB_USER="webapp_user"
DB_PASS="WebAppPass123!"

echo "Actualizando paquetes..."
apt update

echo "Instalando MariaDB/MySQL..."
apt install -y mariadb-server mariadb-client

echo "Habilitando escucha en todas las interfaces..."
sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf || true

echo "Iniciando servicio MariaDB..."
service mariadb start

echo "Creando base de datos, tablas y usuario..."

mysql <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};

CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';

USE ${DB_NAME};

-- Usuarios del ciber
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Máquinas disponibles
CREATE TABLE IF NOT EXISTS maquinas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    estado ENUM('libre', 'ocupada') DEFAULT 'libre'
);

-- Sesiones de uso
CREATE TABLE IF NOT EXISTS sesiones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    maquina_id INT,
    inicio DATETIME NOT NULL,
    fin DATETIME,
    duracion_minutos INT,
    costo DECIMAL(10,2),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (maquina_id) REFERENCES maquinas(id)
);

-- Datos iniciales
INSERT INTO maquinas (nombre) VALUES 
('PC-01'), ('PC-02'), ('PC-03');

INSERT INTO usuarios (nombre) VALUES 
('Cliente Generico');

FLUSH PRIVILEGES;
EOF

service mariadb start

echo "MariaDB iniciado, dejando contenedor activo..."

tail -f /dev/null