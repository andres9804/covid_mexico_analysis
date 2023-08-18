/*
Script usado para explorar y visualizar datos relacionados a los casos de covid, defunciones y vacunas en Mexico,
desde sus inicios en 2020 hasta la ultima actualizacion consultada (08/08/2023).

Datos obtenidos de: https://www.gob.mx/salud/documentos/datos-abiertos-152127
Datos de vacunas obtenidos de: https://ourworldindata.org/covid-vaccinations
*/

--CIFRAS TOTALES------------------------------------------------------------------------------------------------

--CASOS CONFIRMADOS TOTALES
SELECT
	DESCRIPCION,
	COUNT(ID_REGISTRO) AS CASOS_CONFIRMADOS
FROM
	CovidMexico..all_years cov JOIN CovidMexico..sexo sex
	ON cov.SEXO = sex.CLAVE
WHERE
	CLASIFICACION_FINAL IN ('1','2','3')
GROUP BY DESCRIPCION;


--DEFUNCIONES TOTALES
SELECT
	sex.DESCRIPCION,
	COUNT(ID_REGISTRO) AS DEFUNCIONES_TOTAL
FROM
	CovidMexico..all_years cov JOIN CovidMexico..sexo sex
	ON cov.SEXO = sex.CLAVE
WHERE
	FECHA_DEF != '9999-99-99' AND
	CLASIFICACION_FINAL IN ('1','2','3')
GROUP BY sex.DESCRIPCION;


--CIFRAS DIARIAS------------------------------------------------------------------------------------------------

--CASOS CONFIRMADOS DIARIOS
--Casos confirmados con columna de acumulado
DROP TABLE IF EXISTS #Casos_totales_diarios
CREATE TABLE #Casos_totales_diarios
(
FECHA_INGRESO VARCHAR(50),
DESCRIPCION NVARCHAR(50),
CASOS_DIARIOS INT
)
INSERT INTO #Casos_totales_diarios

SELECT
	FECHA_INGRESO,
	sex.DESCRIPCION,
	COUNT(FECHA_INGRESO) AS CASOS_DIARIOS
FROM
	CovidMexico..all_years cov JOIN CovidMexico..sexo sex
	ON cov.SEXO = sex.CLAVE
WHERE
	CLASIFICACION_FINAL IN ('1','2','3')
GROUP BY FECHA_INGRESO, DESCRIPCION
ORDER BY FECHA_INGRESO, DESCRIPCION

SELECT *,
	SUM(SUM(CASOS_DIARIOS)) OVER (ORDER BY FECHA_INGRESO, DESCRIPCION) AS ACUMULADO
FROM
	#Casos_totales_diarios
GROUP BY FECHA_INGRESO, DESCRIPCION, CASOS_DIARIOS
order by FECHA_INGRESO, DESCRIPCION;


--DEFUNCIONES DIARIAS TOTALES
--Defunciones diarias con acumulado
DROP TABLE IF EXISTS #Defunciones_totales_diarias
CREATE TABLE #Defunciones_totales_diarias
(
FECHA_DEF VARCHAR(50),
DESCRIPCION NVARCHAR(50),
DEFUNCIONES_DIARIAS INT
)
INSERT INTO #Defunciones_totales_diarias

SELECT
	FECHA_DEF,
	sex.DESCRIPCION,
	COUNT(FECHA_DEF) AS DEFUNCIONES_DIARIAS
FROM
	CovidMexico..all_years cov JOIN CovidMexico..sexo sex
	ON cov.SEXO = sex.CLAVE
WHERE
	CLASIFICACION_FINAL IN ('1','2','3') AND FECHA_DEF != '9999-99-99'
GROUP BY FECHA_DEF, DESCRIPCION
ORDER BY FECHA_DEF, DESCRIPCION

SELECT *,
	SUM(SUM(DEFUNCIONES_DIARIAS)) OVER (ORDER BY FECHA_DEF, DESCRIPCION) AS ACUMULADO
FROM
	#Defunciones_totales_diarias
GROUP BY FECHA_DEF, DESCRIPCION, DEFUNCIONES_DIARIAS
order by FECHA_DEF, DESCRIPCION;


--CIFRAS TOTALES POR ENTIDAD------------------------------------------------------------------------------------------------

--CASOS TOTALES CONFIRMADOS POR ENTIDAD
SELECT
	ENTIDAD_FEDERATIVA,
	COUNT(FECHA_INGRESO) AS CASOS_CONFIRMADOS
FROM
	CovidMexico..All_years cov JOIN CovidMexico..entidades ent
	ON cov.ENTIDAD_RES = ent.CLAVE_ENTIDAD
WHERE
	CLASIFICACION_FINAL IN ('1','2','3')
GROUP BY ENTIDAD_FEDERATIVA
ORDER BY CASOS_CONFIRMADOS DESC;

--DEFUNCIONES TOTALES POR ENTIDAD
SELECT
	ENTIDAD_FEDERATIVA,COUNT(FECHA_DEF) AS MUERTES_CONFIRMADAS
FROM
	CovidMexico..All_years cov JOIN CovidMexico..entidades ent
	ON cov.ENTIDAD_RES = ent.CLAVE_ENTIDAD
WHERE
	CLASIFICACION_FINAL IN ('1','2','3')
GROUP BY ENTIDAD_FEDERATIVA
ORDER BY MUERTES_CONFIRMADAS DESC;


--CIFRAS DIARIAS POR ENTIDAD------------------------------------------------------------------------------------------------

--CASOS CONFIRMADOS DIARIOS POR ENTIDAD
SELECT
	ENTIDAD_FEDERATIVA,
	FECHA_INGRESO,
	COUNT(FECHA_INGRESO) AS CASOS_DIARIOS 
FROM
	CovidMexico..All_years cov JOIN CovidMexico..entidades ent
	ON cov.ENTIDAD_RES = ent.CLAVE_ENTIDAD
WHERE
	CLASIFICACION_FINAL IN ('1','2','3')
GROUP BY ENTIDAD_FEDERATIVA, FECHA_INGRESO
ORDER BY ENTIDAD_FEDERATIVA, FECHA_INGRESO;


--DEFUNCIONES DIARIAS POR ENTIDAD
SELECT
	ENTIDAD_FEDERATIVA, FECHA_DEF,
	COUNT(FECHA_DEF) AS DEFUNCIONES_DIARIAS
FROM
	CovidMexico..All_years cov JOIN CovidMexico..entidades ent
	ON cov.ENTIDAD_RES = ent.CLAVE_ENTIDAD
WHERE
	FECHA_DEF != '9999-99-99' AND
	CLASIFICACION_FINAL IN ('1','2','3')
GROUP BY ENTIDAD_FEDERATIVA, FECHA_DEF
ORDER BY ENTIDAD_FEDERATIVA, FECHA_DEF;



--VACUNAS------------------------------------------------------------------------------------------------

--AL MENOS UNA VACUNA
--Acumulado de personas que recibieron al menos una dosis de la vacuna
SELECT
	vax.date AS FECHA,
	vax.people_vaccinated AS PERSONAS_VACUNADAS
FROM
	CovidMexico..mexico_vaccinations vax
GROUP BY vax.date, vax.people_vaccinated
ORDER BY vax.date ASC


--INMUNIDAD
--Acumulado de personas que reecibieron todas las vacunas necesarias para generar inmunidad
SELECT
	vax.date AS FECHA,
	people_fully_vaccinated AS P_TOTAL_INMUNE
FROM
	CovidMexico..mexico_vaccinations vax
GROUP BY vax.date, vax.people_fully_vaccinated
ORDER BY vax.date ASC;



--CREAR VIEWS PARA VISUALIZACIONES------------------------------------------------------------------------------------------------

--CASOS CONFIRMADOS TOTALES
USE CovidMexico
GO
CREATE VIEW total_casos AS

SELECT
	sex.DESCRIPCION,
	COUNT(ID_REGISTRO) AS CASOS_CONFIRMADOS
FROM
	CovidMexico..all_years cov JOIN CovidMexico..sexo sex
	ON cov.SEXO = sex.CLAVE
WHERE
	CLASIFICACION_FINAL IN ('1','2','3')
GROUP BY sex.DESCRIPCION;


--DEFUNCIONES TOTALES
USE CovidMexico
GO
CREATE VIEW total_defunciones AS

SELECT
	sex.DESCRIPCION,
	COUNT(ID_REGISTRO) AS DEFUNCIONES_TOTAL
FROM
	CovidMexico..all_years cov JOIN CovidMexico..sexo sex
	ON cov.SEXO = sex.CLAVE
WHERE
	FECHA_DEF != '9999-99-99' AND
	CLASIFICACION_FINAL IN ('1','2','3')
GROUP BY sex.DESCRIPCION;


--CASOS CONFIRMADOS DIARIOS
USE CovidMexico
GO
CREATE VIEW casos_diarios_confirmados AS

	WITH casos_diarios_con (FECHA_INGRESO, DESCRIPCION, CASOS_DIARIOS)
	AS
	(
	SELECT
		FECHA_INGRESO,
		sex.DESCRIPCION,
		COUNT(FECHA_INGRESO) AS CASOS_DIARIOS
	FROM
		CovidMexico..all_years cov JOIN CovidMexico..sexo sex
		ON cov.SEXO = sex.CLAVE
	WHERE
		CLASIFICACION_FINAL IN ('1','2','3')
	GROUP BY FECHA_INGRESO, DESCRIPCION
	)
SELECT *,
	SUM(SUM(CASOS_DIARIOS)) OVER (ORDER BY FECHA_INGRESO, DESCRIPCION) AS ACUMULADO
FROM
	casos_diarios_con
GROUP BY FECHA_INGRESO, DESCRIPCION, CASOS_DIARIOS;



--DEFUNCIONES DIARIAS TOTALES
USE CovidMexico
GO
CREATE VIEW defunciones_diarias_confirmados AS

	WITH defunciones_diarias_con (FECHA_DEF, DESCRIPCION, DEFUNCIONES_DIARIAS)
	AS
	(
	SELECT
		FECHA_DEF,
		sex.DESCRIPCION,
		COUNT(FECHA_DEF) AS DEFUNCIONES_DIARIAS
	FROM
		CovidMexico..all_years cov JOIN CovidMexico..sexo sex
		ON cov.SEXO = sex.CLAVE
	WHERE
		CLASIFICACION_FINAL IN ('1','2','3') AND
		FECHA_DEF != '9999-99-99'
	GROUP BY FECHA_DEF, DESCRIPCION
	)

SELECT *,
	SUM(SUM(DEFUNCIONES_DIARIAS)) OVER (ORDER BY FECHA_DEF, DESCRIPCION) AS ACUMULADO
FROM
	defunciones_diarias_con
GROUP BY FECHA_DEF, DESCRIPCION, DEFUNCIONES_DIARIAS;


--CASOS TOTALES POR ESTADO
USE CovidMexico
GO
CREATE VIEW casos_conf_por_estado AS

SELECT
	CLAVE_ENTIDAD,
	ENTIDAD_FEDERATIVA,
	COUNT(FECHA_INGRESO) AS CASOS_CONFIRMADOS
FROM
	CovidMexico..All_years cov JOIN CovidMexico..entidades ent
	ON cov.ENTIDAD_RES = ent.CLAVE_ENTIDAD
WHERE
	CLASIFICACION_FINAL IN ('1','2','3')
GROUP BY ENTIDAD_FEDERATIVA, CLAVE_ENTIDAD;


--DEFUNCIONES TOTALES POR ESTADO
USE CovidMexico
GO
CREATE VIEW defunciones_por_estado AS

SELECT
	CLAVE_ENTIDAD, ENTIDAD_FEDERATIVA,
	COUNT(FECHA_DEF) AS MUERTES_CONFIRMADAS
FROM
	CovidMexico..All_years cov JOIN CovidMexico..entidades ent
	ON cov.ENTIDAD_RES = ent.CLAVE_ENTIDAD
WHERE
	CLASIFICACION_FINAL IN ('1','2','3') AND
	FECHA_DEF != '9999-99-99'
GROUP BY ENTIDAD_FEDERATIVA, CLAVE_ENTIDAD;


--ACUMULADO VACUNAS DIARIAS
USE CovidMexico
GO
CREATE VIEW vacunas AS 

SELECT
	vax.date AS FECHA,
	people_vaccinated AS PERSONAS_VACUNADAS,
	people_fully_vaccinated AS P_TOTAL_INMUNE,
	new_vaccinations AS Vacunas_diarias,
	total_vaccinations AS VACUNAS_TOTALES
FROM
	CovidMexico..mexico_vaccinations vax
GROUP BY vax.date, vax.people_vaccinated,vax.people_fully_vaccinated, vax.new_vaccinations, total_vaccinations;

--CONSULTANDO VIEWS PARA EXPORTARLAS------------------------------------------------------------------------------------------------
SELECT * FROM [dbo].[casos_diarios_confirmados];
SELECT * FROM casos_conf_por_estado;
SELECT * FROM defunciones_diarias_confirmados;
SELECT * FROM [dbo].[defunciones_por_estado];
SELECT * FROM [dbo].[total_casos];
SELECT * FROM [dbo].[total_defunciones];
SELECT * FROM [dbo].[vacunas];