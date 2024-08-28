create database iot_db;

-- Crear la base de datos
CREATE DATABASE iot_db;

-- Seleccionar la base de datos
USE iot_db;

-- Crear la tabla para los sensores
CREATE TABLE tbl_sensor (
    cveSensor INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL
);

-- Crear la tabla para los detalles de los sensores (datos de temperatura)
CREATE TABLE tbl_detalle_sensor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    valor FLOAT NOT NULL,
    fechaRegistro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cveSensor INT,
    FOREIGN KEY (cveSensor) REFERENCES tbl_sensor(cveSensor)
);

-- Insertar un sensor de ejemplo
INSERT INTO tbl_sensor (descripcion) VALUES ('Sensor de Temperatura');
INSERT INTO tbl_sensor (descripcion) VALUES ('Sensor de Pulso');
select * from  tbl_sensor;

select * from tbl_detalle_sensor where cveSensor =2;