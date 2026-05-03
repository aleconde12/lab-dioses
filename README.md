# lab-dioses
Cibercafe para laboratorio de servidores y redes 1

## Instrucciones
Se necesita tener docker y docker compose instalado en la pc.

1. Clonarse el repo `git clone git@github.com:aleconde12/lab-dioses.git`, o descargarlo.
2. Ejecutar `docker compose up -d` para levantar los tres contenedores (db, web, pc-ciber)
3. Aguardar aproximadamente 5 minutos
4. Ingresar desde el navegador a http://localhost:8080 para acceder directo al webserver del ciber
5. Ingresar desde el navegador a http://localhost:6901 para acceder a una pc del ciber. El password es 123456. Dentro de la misma, se puede ingresar al webserver del ciber, usando http://web-server en algun navegador.

En este momento, en el webserver del ciber se puede
- Crear clientes 
- Crear sesiones
- Finalizar sesiones y ver su costo