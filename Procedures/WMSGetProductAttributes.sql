USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [kkur].[WMSPobierzAtrybutyTowaru]    Script Date: 2025-04-01 14:55:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [kkur].[WMSPobierzAtrybutyTowaru]
@GidNumer int,
@GidTyp int
AS
BEGIN
	SET NOCOUNT ON;
	select
	case when AtK_Nazwa = 'Przenośnik taśmowy' then 'Sorter' else AtK_Nazwa end as [Klasa]
	,case when substring(AtK_Format, 2, 1) = 's' then 'TEXT'
		when substring(AtK_Format, 2, 1) = 'n' then 'DECIMAL'
		when substring(AtK_Format, 2, 1) = 'd' then 'DATE'
	end as [Typ]
	,Atr_Wartosc as [Wartosc]

	from cdn.TwrKarty with(nolock)
	join cdn.Atrybuty with(nolock) on Atr_ObiNumer = Twr_GIDNumer and Atr_ObiTyp = Twr_GIDTyp
	join cdn.AtrybutyKlasy with(nolock) on Atr_AtkId = AtK_ID

	where Twr_GIDNumer = @GidNumer and Twr_GIDTyp = @GidTyp and AtK_ID in (255, 148)
	----------------------------------------------------------------------------------------------------
	UNION ALL

	select 'Klasa rotacji'
	,'TEXT'
	,TSM_Analiza

	from ExpertWMS_Gaska_Produkcja.dbo.wms_exp_towaryp with(nolock)
	join ExpertWMS_Gaska_Produkcja.dbo.twrstanymaksymalne with(nolock) on etp_twrid = TSM_TwrNumer

	where etp_sysid = @GidNumer
	----------------------------------------------------------------------------------------------------
	UNION ALL

	select 'Max stan SKU'
	,'INTEGER'
	,convert(varchar(20),convert(int,TSM_Stan))

	from ExpertWMS_Gaska_Produkcja.dbo.wms_exp_towaryp with(nolock)
	join ExpertWMS_Gaska_Produkcja.dbo.twrstanymaksymalne with(nolock) on etp_twrid = TSM_TwrNumer
	
	where etp_sysid = @GidNumer
	----------------------------------------------------------------------------------------------------
	UNION ALL

	select 'Picking min'
	,'INTEGER'
	,convert(varchar(20),convert(int,PickingMin))

	from dbo.WMSDodatkoweSynchro
	
	where ErpTwrId = @GidNumer
	----------------------------------------------------------------------------------------------------
	UNION ALL

	select 'Picking max'
	,'INTEGER'
	,convert(varchar(20),convert(int,PickingMax))

	from dbo.WMSDodatkoweSynchro
	
	where ErpTwrId = @GidNumer
	----------------------------------------------------------------------------------------------------
	UNION ALL

	select 'Cena katalogowa'
	,'DECIMAL'
	,convert(varchar(20),isnull(CenaKatalogowa,0))

	from dbo.WMSDodatkoweSynchro
	
	where ErpTwrId = @GidNumer
	----------------------------------------------------------------------------------------------------
	UNION ALL

	SELECT 
		'Objętość',
		'DECIMAL',
			CONVERT(varchar(20), isnull(CONVERT(DECIMAL(15,2), 
				CASE 
					WHEN Twr_wymjm = 'mm' THEN (Twr_ObjetoscL/Twr_ObjetoscM) / 1000
					WHEN Twr_wymjm = 'dm' THEN (Twr_ObjetoscL/Twr_ObjetoscM) * 1000
					WHEN Twr_wymjm = 'm' THEN (Twr_ObjetoscL/Twr_ObjetoscM) * 1000000 
					WHEN Twr_WymJm = 'cm' THEN Twr_ObjetoscL/Twr_ObjetoscM
					ELSE NULL 
				END
			),0)) AS ConvertedVolume
	FROM cdn.TwrKarty
	where Twr_GIDNumer = @GidNumer and Twr_GIDTyp = @GidTyp
	----------------------------------------------------------------------------------------------------
	UNION ALL

	select 'Wymagana KJ',
	'TEXT',
	isnull(nullif(atr_wartosc,'<Brak>'),'NIE')
	
	from cdn.ProdWzorceKJ
	left join cdn.ProdWzorceKJTowary on WKJ_Id=PWT_WKJId
	left join cdn.atrybuty on WKJ_Id=Atr_ObiNumer and Atr_OBITyp=14381 and Atr_OBILp = 0 and Atr_AtkId = 447

	where PWT_TwrGIDNumer = @GidNumer and PWT_TwrGIDTyp = @GidTyp

	----------------------------------------------------------------------------------------------------
	-- Czy wymaga Numer partii, data ważności, numery seryjne - na stałe NIE do testów
	UNION ALL

	select 'Wymagana partia dostawcy',
	'TEXT',
	'NIE'

	UNION ALL

	select 'Wymagana data ważności',
	'TEXT',
	'NIE'

	UNION ALL

	select 'Wymagany kraj pochodzenia',
	'TEXT',
	'NIE'

	UNION ALL

	select 'Wymaga etykietowania',
	'TEXT',
	'NIE'

END



