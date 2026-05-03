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

echo "Iniciando MariaDB..."
service mariadb start

# Esperar un poco a que levante
sleep 5

echo "Inicializando base..."

mysql <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};

CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';

USE ${DB_NAME};

-- Empleados del ciber
CREATE TABLE IF NOT EXISTS empleados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    rol ENUM('admin', 'empleado') NOT NULL DEFAULT 'empleado',
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Clientes del ciber
CREATE TABLE IF NOT EXISTS clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    documento VARCHAR(30),
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
    cliente_id INT NOT NULL,
    maquina_id INT NOT NULL,
    empleado_id INT NOT NULL,
    inicio DATETIME NOT NULL,
    fin DATETIME,
    duracion_minutos INT,
    costo DECIMAL(10,2),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (maquina_id) REFERENCES maquinas(id),
    FOREIGN KEY (empleado_id) REFERENCES empleados(id)
);

-- Datos iniciales
INSERT IGNORE INTO maquinas (nombre) VALUES 
('PC-01'), ('PC-02'), ('PC-03');

INSERT INTO empleados (usuario, password, nombre, rol)
SELECT 'admin', 'admin123', 'Administrador', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM empleados WHERE usuario = 'admin');

INSERT INTO empleados (usuario, password, nombre, rol)
SELECT 'empleado', 'empleado123', 'Empleado Demo', 'empleado'
WHERE NOT EXISTS (SELECT 1 FROM empleados WHERE usuario = 'empleado');

FLUSH PRIVILEGES;
EOF

echo "MariaDB listo. Manteniendo contenedor activo..."
tail -f /dev/null