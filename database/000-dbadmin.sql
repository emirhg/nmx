-- Usuarios
CREATE USER admin_catalogonoms WITH PASSWORD 'password.complicada';
CREATE USER usuario_catalogonom WITH PASSWORD 'password';

-- Creación de la Base de datos
CREATE DATABASE catalogonoms OWNER admin_catalogonoms;

-- Permisos de usuario
GRANT SELECT ON ALL TABLES IN SCHEMA public TO usuario_catalogonom;

-- Extensiones requeridas
CREATE EXTENSION plpython3u;
CREATE EXTENSION fuzzystrmatch;
