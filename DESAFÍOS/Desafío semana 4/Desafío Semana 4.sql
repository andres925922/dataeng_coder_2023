show databases;

use oltp_coder;

-- 2. crear tabla clima futuro global
CREATE TABLE d4_clima
(año INT NOT NULL PRIMARY KEY,
Temperatura FLOAT NOT NULL,
Oxigeno FLOAT NOT NULL);

-- Insertar valores manualmente
INSERT INTO d4_clima VALUES (2023, 22.5,230);
INSERT INTO d4_clima VALUES (2024, 22.7,228.6);
INSERT INTO d4_clima VALUES (2025, 22.9,227.5);
INSERT INTO d4_clima VALUES (2026, 23.1,226.7);
INSERT INTO d4_clima VALUES (2027, 23.2,226.4);
INSERT INTO d4_clima VALUES (2028, 23.4,226.2);
INSERT INTO d4_clima VALUES (2029, 23.6,226.1);
INSERT INTO d4_clima VALUES (2030, 23.8,225.1);

-- 3. crear tabla desastres proyectados globales
CREATE TABLE d4_desastres
(año INT NOT NULL PRIMARY KEY,
Tsunamis INT NOT NULL,
Olas_Calor INT NOT NULL,
Terremotos INT NOT NULL,
Erupciones INT NOT NULL,
Incendios INT NOT NULL);

-- Insertar valores manualmente
INSERT INTO d4_desastres VALUES (2023, 2,15, 6,7,50);
INSERT INTO d4_desastres VALUES (2024, 1,12, 8,9,46);
INSERT INTO d4_desastres VALUES (2025, 3,16, 5,6,47);
INSERT INTO d4_desastres VALUES (2026, 4,12, 10,13,52);
INSERT INTO d4_desastres VALUES (2027, 5,12, 6,5,41);
INSERT INTO d4_desastres VALUES (2028, 4,18, 3,2,39);
INSERT INTO d4_desastres VALUES (2029, 2,19, 5,6,49);
INSERT INTO d4_desastres VALUES (2030, 4,20, 6,7,50);

-- 4. crear tabla muertes proyectadas por rangos de edad
CREATE TABLE d4_muertes
(año INT NOT NULL PRIMARY KEY,
R_Menor15 INT NOT NULL,
R_15_a_30 INT NOT NULL,
R_30_a_45 INT NOT NULL,
R_45_a_60 INT NOT NULL,
R_M_a_60 INT NOT NULL);

-- Insertar valores manualmente
INSERT INTO d4_muertes VALUES (2023, 1000,1300, 1200,1150,1500);
INSERT INTO d4_muertes VALUES (2024, 1200,1250, 1260,1678,1940);
INSERT INTO d4_muertes VALUES (2025, 987,1130, 1160,1245,1200);
INSERT INTO d4_muertes VALUES (2026, 1560,1578, 1856,1988,1245);
INSERT INTO d4_muertes VALUES (2027, 1002,943, 1345,1232,986);
INSERT INTO d4_muertes VALUES (2028, 957,987, 1856,1567,1756);
INSERT INTO d4_muertes VALUES (2029, 1285,1376, 1465,1432,1236);
INSERT INTO d4_muertes VALUES (2030, 1145,1456, 1345,1654,1877);

drop tables clima, desastres, muertes;

show tables;

select* from d4_clima;


use olap_coder;

show tables;

show procedure status;

CREATE TABLE d4_DESASTRES_FINAL
(Cuatrenio varchar(20) NOT NULL PRIMARY KEY,
Temp_AVG FLOAT NOT NULL, Oxi_AVG FLOAT NOT NULL,
T_Tsunamis INT NOT NULL, T_OlasCalor INT NOT NULL,
T_Terremotos INT NOT NULL, T_Erupciones INT NOT NULL, 
T_Incendios INT NOT NULL,M_Jovenes_AVG FLOAT NOT NULL,
M_Adutos_AVG FLOAT NOT NULL,M_Ancianos_AVG FLOAT NOT NULL);


SELECT 

i.Cuatrenio as Cuatrenio,
ROUND(AVG(i.Temperatura), 1) as Temp_AVG,
ROUND(AVG(i.oxigeno), 1) as Oxi_AVG,
SUM(i.Tsunamis) as T_Tsunamis,
SUM(i.Olas_Calor) as T_OlasCalor,
SUM(i.Terremotos) as T_Terremotors,
SUM(i.Erupciones) as T_Erupciones,
SUM(i.Incendios) as T_Incencios,
ROUND(AVG(i.M_Jovenes), 1) as M_Jovenes_AVG,
ROUND(AVG(i.M_Adultos), 1) as M_Adultos_AVG,
ROUND(AVG(i.M_Ancianos), 1) as M_Ancianos_AVG

FROM

(	/**
	* Hacemos un select de una tabla con todas las columnas que necesitaríamos nosotros con el formato de cuaternio que necesitamos
	* Sobre esta tabla realizaremos las consultas del insert
	*/
	SELECT
		CASE 
			WHEN c.año <= 2026 THEN '2023-2026' 
			ELSE '2027-2030'
		END AS Cuatrenio,
		c.año as Año,
		c.Temperatura as Temperatura,
		c.Oxigeno as Oxigeno,
		d.Tsunamis as Tsunamis,
		d.Olas_Calor as Olas_Calor,
		d.Terremotos as Terremotos,
		d.Erupciones as Erupciones,
		d.Incendios as Incendios,
		(m.R_Menor15 + m.R_15_a_30) as M_Jovenes,
		(m.R_30_a_45 + m.R_45_a_60) as M_Adultos,
		m.R_M_a_60 as M_Ancianos
	FROM
	oltp_coder.d4_clima as c
	JOIN oltp_coder.d4_desastres as d on c.año = d.año
	JOIN oltp_coder.d4_muertes as m on c.año = m.año
    
) as i

GROUP BY Cuatrenio;

DELIMITER //
CREATE procedure pETL_Desastres()
BEGIN
	SET SQL_SAFE_UPDATES = 0;
    
	DELETE FROM olap_coder.d4_DESASTRES_FINAL;
    
    INSERT INTO olap_coder.d4_DESASTRES_FINAL
		SELECT 

		i.Cuatrenio as Cuatrenio,
		ROUND(AVG(i.Temperatura), 1) as Temp_AVG,
		ROUND(AVG(i.oxigeno), 1) as Oxi_AVG,
		SUM(i.Tsunamis) as T_Tsunamis,
		SUM(i.Olas_Calor) as T_OlasCalor,
		SUM(i.Terremotos) as T_Terremotors,
		SUM(i.Erupciones) as T_Erupciones,
		SUM(i.Incendios) as T_Incencios,
		ROUND(AVG(i.M_Jovenes), 1) as M_Jovenes_AVG,
		ROUND(AVG(i.M_Adultos), 1) as M_Adultos_AVG,
		ROUND(AVG(i.M_Ancianos), 1) as M_Ancianos_AVG

		FROM

		(	/**
			* Hacemos un select de una tabla con todas las columnas que necesitaríamos nosotros con el formato de cuaternio que necesitamos
			* Sobre esta tabla realizaremos las consultas del insert
			*/
			SELECT
				CASE 
					WHEN c.año <= 2026 THEN '2023-2026' 
					ELSE '2027-2030'
				END AS Cuatrenio,
				c.año as Año,
				c.Temperatura as Temperatura,
				c.Oxigeno as Oxigeno,
				d.Tsunamis as Tsunamis,
				d.Olas_Calor as Olas_Calor,
				d.Terremotos as Terremotos,
				d.Erupciones as Erupciones,
				d.Incendios as Incendios,
				(m.R_Menor15 + m.R_15_a_30) as M_Jovenes,
				(m.R_30_a_45 + m.R_45_a_60) as M_Adultos,
				m.R_M_a_60 as M_Ancianos
			FROM
			oltp_coder.d4_clima as c
			JOIN oltp_coder.d4_desastres as d on c.año = d.año
			JOIN oltp_coder.d4_muertes as m on c.año = m.año
			
		) as i

		GROUP BY Cuatrenio;
	
    SET SQL_SAFE_UPDATES = 1;
    
END //

DELIMITER ;

CALL pETL_Desastres();

SELECT * FROM olap_coder.d4_DESASTRES_FINAL;
