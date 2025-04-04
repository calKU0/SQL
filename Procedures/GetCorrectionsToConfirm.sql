USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [dbo].[GaskaAutomatycznePotwierdzanieKorekt]    Script Date: 2025-04-01 15:09:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[GaskaAutomatycznePotwierdzanieKorekt]
as
begin
	select distinct TrN_GIDNumer
	,TrN_GIDTyp
	,TrN_DokumentObcy
	,case when exists (select * from cdn.TraSElem with (nolock)
	join cdn.TraElem with (nolock) on TrS_GIDNumer = TrE_GIDNumer and TrS_GIDLp = TrE_GIDLp
	where TrE_GIDNumer=TrN_GIDNumer and TrS_MagNumer = 2 and TrE_Ilosc <> 0
	) then 1 else 0 end AS [Czy generowac dok. magazynowe] -- 1 jeśli istnieje pozycja z DETALU z iloscią != 0

	from cdn.tranag with (nolock)
	join cdn.TraPlat with (nolock) on TrN_GIDTyp=TrP_GIDTyp and TrN_GIDNumer=TrP_GIDNumer
	join cdn.Atrybuty with (nolock) on TrN_GIDNumer=Atr_ObiNumer AND TrN_GIDTyp=Atr_ObiTyp
	where 
	TrN_GIDTyp IN('1529','1497','2041','2044' 
	,'2009','2042','2043','2047' 
	,'2003','1624','1625')
	and exists 
	(select * from cdn.TraNag with (nolock) 
	join cdn.TraPlat with (nolock) on TrN_GIDTyp=TrP_GIDTyp and TrN_GIDNumer=TrP_GIDNumer
	where TrP_FormaNr in (10,50) and TrP_Rozliczona = 1) -- Rozliczona płatnośc kartą lub gotówką
	and exists
	(select * from cdn.TraSElem  with (nolock)
	join cdn.TraElem with (nolock) on TrS_GIDNumer = TrE_GIDNumer and TrS_GIDLp = TrE_GIDLp
	where TrE_GIDNumer=TrN_GIDNumer and TrS_MagNumer = 1) -- Istnieją pozycje z HURT
	and Atr_AtkId = 355 and Atr_Wartosc = 'zrealizowane'
	and TrN_Stan = 2
	and TrN_StanDokMag = 2

	AND Trn_Gidnumer in (

	1816015
	)
end
