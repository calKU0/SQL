USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [kkur].[WMSPobierzElementyDokumentu]    Script Date: 2025-04-07 14:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [kkur].[WMSPobierzElementyDokumentu]
@GidNumer int,
@GidTyp int
AS
BEGIN
	SET NOCOUNT ON;

IF @GidTyp in (2041,2033,2001,1616,1617,1603,2034,2037,1604)
BEGIN
	select distinct
	TrE_TwrNumer as [TwrNumer]
	,TrE_GIDLp as [Lp]
	,TrE_Ilosc as [Ilosc]
	,'OCZEKUJE' as [Status]
	,TrE_JmZ as [Jm]
	,isnull(Wytyczne.Atr_Wartosc,'') as [Opis]

	from cdn.TraNag with(nolock)
	join cdn.TraElem with(nolock) on TrN_GIDNumer = TrE_GIDNumer and TrN_GIDTyp = TrE_GIDTyp
	join cdn.TraSElem with(nolock) on TrE_GIDNumer=TrS_GIDNumer and TrE_GIDLp=TrS_GIDLp
	join cdn.TwrKarty with(nolock) on TrE_TwrNumer = Twr_GIDNumer and TrE_TwrTyp = Twr_GIDTyp
	left join cdn.TwrDost with(nolock) on Twr_GIDNumer = TWD_TwrNumer and TWD_KntNumer = TrN_GIDNumer
	left join cdn.Atrybuty Wytyczne with(nolock) on Twr_GIDNumer = Wytyczne.Atr_ObiNumer and Wytyczne.Atr_ObiTyp = 16 and TWD_TwrLp = Atr_ObiLp and Wytyczne.Atr_AtkId = 424

	where TrN_GIDNumer = @GidNumer and TrN_GIDTyp = @GidTyp 
	-- Pozycje na HURT i Typ to towar lub produkt
	and TrS_MagNumer = 1 and Twr_Typ in (1,2)
END
ELSE
BEGIN
	select distinct
	MaE_TwrNumer as [TwrNumer]
	,MaE_GIDLp as [Lp]
	,MaE_Ilosc as [Ilosc]
	,'OCZEKUJE' as [Status]
	,replace(MaE_JmZ,'.','') as [Jm]
	,isnull(Wytyczne.Atr_Wartosc,'') as [Opis]

	from cdn.MagNag with(nolock)
	join cdn.MagElem with(nolock) on MaN_GIDNumer = MaE_GIDNumer and MaN_GIDTyp = MaE_GIDTyp
	join cdn.MagSElem with(nolock) on MaE_GIDNumer=MaS_GIDNumer and MaE_GIDLp=MaS_GIDLp
	join cdn.TwrKarty with(nolock) on MaE_TwrNumer = Twr_GIDNumer and MaE_TwrTyp = Twr_GIDTyp
	left join cdn.TwrDost with(nolock) on Twr_GIDNumer = TWD_TwrNumer and TWD_KntNumer = MaN_KntNumer
	left join cdn.Atrybuty Wytyczne with(nolock) on Twr_GIDNumer = Wytyczne.Atr_ObiNumer and Wytyczne.Atr_ObiTyp = 16 and TWD_TwrLp = Atr_ObiLp and Wytyczne.Atr_AtkId = 424

	where MaN_GIDNumer = @GidNumer and MaN_GIDTyp = @GidTyp 
	-- Pozycje na HURT i Typ to towar lub produkt
	and MaS_MagNumer = 1 and Twr_Typ in (1,2)
END


END