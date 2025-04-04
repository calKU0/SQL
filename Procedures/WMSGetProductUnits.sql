USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [kkur].[WMSPobierzJMTowaru]    Script Date: 2025-04-01 14:56:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [kkur].[WMSPobierzJMTowaru]
@GidNumer int,
@GidTyp int
AS
BEGIN
	SET NOCOUNT ON;

	select 
		1 as [Glowna]
		,Twr_Jm as [Kod]
		,Twr_Ean as [EAN]
		,1 as [KonwersjaDoGlownej]
		,0 as [Wysokosc]
		,0 as [Dlugosc]
		,0 as [Szerokosc]
		,Twr_Waga as [Waga]
		from cdn.TwrKarty with(nolock)
		where Twr_GIDNumer = @GidNumer and Twr_GIDTyp = @GidTyp

		UNION ALL 

		select 
		0 as [Glowna]
		,TwJ_JmZ as [Kod]
		,TwK_Kod as [EAN]
		,convert(int,TwJ_PrzeliczL/TwJ_PrzeliczM) as [KonwersjaDoGlownej]
		,0 as [Wysokosc]
		,0 as [Dlugosc]
		,0 as [Szerokosc]
		,TwJ_Waga as [Waga]

		from cdn.TwrJm with(nolock)
		join cdn.TwrKody with(nolock) on TwJ_JmZ = TwK_Jm and TwJ_TwrNumer = TwK_TwrNumer
		where TwJ_TwrNumer = @GidNumer and TwJ_TwrTyp = @GidTyp 
END
