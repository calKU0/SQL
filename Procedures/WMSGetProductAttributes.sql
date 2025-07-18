USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [kkur].[WMSPobierzAtrybutyTowaru]    Script Date: 2025-04-07 14:16:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [kkur].[WMSPobierzAtrybutyTowaru]
	@GidNumer INT,
	@GidTyp INT
AS
BEGIN
	SET NOCOUNT ON;

	-- 1. Atrybuty Towaru z ERP
	WITH AtrybutyTowaru AS (
		SELECT 
			CASE WHEN AtK_Nazwa = 'Przenośnik taśmowy' THEN 'Sorter' ELSE AtK_Nazwa END AS Klasa,
			CASE 
				WHEN SUBSTRING(AtK_Format, 2, 1) = 's' THEN 'TEXT'
				WHEN SUBSTRING(AtK_Format, 2, 1) = 'n' THEN 'DECIMAL'
				WHEN SUBSTRING(AtK_Format, 2, 1) = 'd' THEN 'DATE'
			END AS Typ,
			Atr_Wartosc AS Wartosc
		FROM cdn.TwrKarty WITH (NOLOCK)
		JOIN cdn.Atrybuty WITH (NOLOCK) ON Atr_ObiNumer = Twr_GIDNumer AND Atr_ObiTyp = Twr_GIDTyp
		JOIN cdn.AtrybutyKlasy WITH (NOLOCK) ON Atr_AtkId = AtK_ID
		WHERE Twr_GIDNumer = @GidNumer AND Twr_GIDTyp = @GidTyp AND AtK_ID IN (255, 148)
	),
	-- 2. Dane Towaru z WMS
	WmsDane AS (
		SELECT 
			TSM_Analiza,
			TSM_Stan,
			TSM_PickingMin,
			TSM_PickingMax,
			ISNULL(TSM_CenaKatalogowa, 0) AS CenaKatalogowa
		FROM ExpertWMS_Gaska_Produkcja.dbo.wms_exp_towaryp WITH (NOLOCK)
		JOIN ExpertWMS_Gaska_Produkcja.dbo.twrstanymaksymalne WITH (NOLOCK) ON etp_twrid = TSM_TwrNumer
		WHERE etp_sysid = @GidNumer
	),
	-- 3. Objętość Towaru
	Objetosc AS (
		SELECT 
			CONVERT(VARCHAR(20), ISNULL(CONVERT(DECIMAL(15, 2),
				CASE 
					WHEN Twr_wymjm = 'mm' THEN (Twr_ObjetoscL / Twr_ObjetoscM) / 1000
					WHEN Twr_wymjm = 'dm' THEN (Twr_ObjetoscL / Twr_ObjetoscM) * 1000
					WHEN Twr_wymjm = 'm'  THEN (Twr_ObjetoscL / Twr_ObjetoscM) * 1000000
					WHEN Twr_wymjm = 'cm' THEN Twr_ObjetoscL / Twr_ObjetoscM
					ELSE NULL
				END
			), 0)) AS Wartosc
		FROM cdn.TwrKarty
		WHERE Twr_GIDNumer = @GidNumer AND Twr_GIDTyp = @GidTyp
	),
	-- 4. Wymagana KJ
	WymaganaKJ AS (
		SELECT 
			ISNULL(NULLIF(atr_wartosc, '<Brak>'), 'NIE') AS Wartosc
		FROM cdn.ProdWzorceKJ
		LEFT JOIN cdn.ProdWzorceKJTowary ON WKJ_Id = PWT_WKJId
		LEFT JOIN cdn.Atrybuty ON WKJ_Id = Atr_ObiNumer AND Atr_OBITyp = 14381 AND Atr_OBILp = 0 AND Atr_AtkId = 447
		WHERE PWT_TwrGIDNumer = @GidNumer AND PWT_TwrGIDTyp = @GidTyp
	)

	-- Atrybuty z powyższych zapytań 
	SELECT Klasa, Typ, Wartosc FROM AtrybutyTowaru
	UNION ALL SELECT 'Klasa rotacji', 'TEXT', TSM_Analiza FROM WmsDane
	UNION ALL SELECT 'Max stan SKU', 'INTEGER', CONVERT(VARCHAR(20), TSM_Stan) FROM WmsDane
	UNION ALL SELECT 'Picking min', 'INTEGER', CONVERT(VARCHAR(20), TSM_PickingMin) FROM WmsDane
	UNION ALL SELECT 'Picking max', 'INTEGER', CONVERT(VARCHAR(20), TSM_PickingMax) FROM WmsDane
	UNION ALL SELECT 'Cena katalogowa', 'DECIMAL', CONVERT(VARCHAR(20), CenaKatalogowa) FROM WmsDane
	UNION ALL SELECT 'Objętość', 'DECIMAL', Wartosc FROM Objetosc
	UNION ALL SELECT 'Wymagana KJ', 'TEXT', Wartosc FROM WymaganaKJ

	-- Statyczne atrybuty
	UNION ALL SELECT 'Wymagana partia dostawcy', 'TEXT', 'NIE'
	UNION ALL SELECT 'Wymagana data ważności', 'TEXT', 'NIE'
	UNION ALL SELECT 'Wymagany kraj pochodzenia', 'TEXT', 'NIE'
	UNION ALL SELECT 'Wymaga etykietowania', 'TEXT', 'NIE'
END
