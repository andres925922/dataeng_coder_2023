show databases;

create schema oltp_coder;
create schema olap_coder;

use oltp_coder;

/** 

1) CREAR DOS BASES DE DATOS (UNA TRANSACCIONAL Y OTRA ANALÍTICA)
2) CREAR LAS TABLAS TITULO Y AUTORES EN LA BASE DE DATOS TRANSACCIONAL
3) CREAR LA TABLA DIMTITULOS
4) GENERAR UN PROCEDIMIENTO QUE LLENE LA TABLA DIMTITULOS EN LA BASE DE DATOS ANALÍTICA

*/

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE TITULOS;
DROP TABLE AUTORES;

CREATE TABLE TITULOS(
ID INT NOT NULL primary KEY auto_increment,
TITULO VARCHAR(100) NOT NULL,
TIPO VARCHAR(100) NOT NULL
);

CREATE TABLE AUTORES(
ID INT NOT NULL PRIMARY KEY auto_increment ,
NOMBRE VARCHAR(100) NOT NULL,
APELLIDO VARCHAR(100) NOT NULL,
TELEFONO VARCHAR(50) NOT NULL,
TITULO_ID INT NOT NULL,
foreign key (TITULO_ID) REFERENCES TITULOS(ID) ON UPDATE CASCADE
);

INSERT INTO TITULOS (TITULO, TIPO) VALUES
('Consultas SQL','bbdd'),
('Grupo recursos Azure','administracion'),
('.NET Framework 4.5','programacion'),
('Programacion C#','dev'),
('Power BI','BI'),
('Administracion Sql server','administracion');

SELECT * FROM TITULOS;
SELECT * FROM AUTORES;


INSERT INTO autores (NOMBRE, APELLIDO, TELEFONO, TITULO_ID) VALUES 
('David', 'Saenz', '99897867', 3),
('Ana', 'Ruiz', '99897466', 8),
('Julian', 'Perez', '99897174', 2),
('Andres', 'Calamaro', '99876869', 1),
('Cidys', 'Castillo', '998987453', 4),
('Pedro', 'Molina', '99891768', 5);


USE OLAP_CODER;

CREATE TABLE DimTITULOS(
TITULO_ID INT NOT NULL,
NOMBRE_TITULO VARCHAR(100),
TIPO VARCHAR(100),
NOMBRE_AUTOR VARCHAR(100)
);


DELIMITER //

CREATE PROCEDURE GetAllProducts()
BEGIN
	SET SQL_SAFE_UPDATES = 0;
	DELETE FROM olap_coder.DimTITULOS;
    
	INSERT INTO olap_coder.DimTITULOS
		SELECT 
		T.ID AS TITULO_ID,
		T.TITULO AS NOMBRE_TITULO,
		CAST(
		CASE T.TIPO
			WHEN "bbdd" THEN "Bases de datos"
			WHEN "BI" THEN "Bases de datos BI"
			WHEN "administracion" THEN "Bases de datos administración"
			when "programacion" then "Programación"
			when "dev" then "programación"
			ELSE ""
		END AS NCHAR) AS TIPO,
		concat(A.NOMBRE, " ", A.APELLIDO) AS NOMBRE_AUTOR    

		FROM oltp_coder.TITULOS T
		JOIN oltp_coder.AUTORES AS A ON T.ID = A.TITULO_ID;
        
	SET SQL_SAFE_UPDATES = 1;
    
END //

DELIMITER ;

DROP PROCEDURE GetAllProducts;

CALL GetAllProducts();

SELECT * FROM DIMTITULOS;