USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [kkur].[WMSPobierzElementyDokumentu]    Script Date: 2025-04-01 14:56:29 ******/
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

IF @GidTyp in (1602,1089,1601)
BEGIN
	select distinct
	TrE_TwrNumer as [TwrNumer]
	,TrE_GIDLp as [Lp]
	,TrE_Ilosc as [Ilosc]
	,'OCZEKUJE' as [Status]
	,TrE_JmZ as [Jm]

	from cdn.TraNag with(nolock)
	join cdn.TraElem with(nolock) on TrN_GIDNumer = TrE_GIDNumer and TrN_GIDTyp = TrE_GIDTyp
	join cdn.TraSElem with(nolock) on TrE_GIDNumer=TrS_GIDNumer and TrE_GIDLp=TrS_GIDLp
	join cdn.TwrKarty with(nolock) on TrE_TwrNumer = Twr_GIDNumer and TrE_TwrTyp = Twr_GIDTyp

	where TrN_GIDNumer = @GidNumer and TrN_GIDTyp = @GidTyp and TrS_MagNumer = 1 and Twr_Typ in (1,2)
END
ELSE
BEGIN
	select distinct
	MaE_TwrNumer as [TwrNumer]
	,MaE_GIDLp as [Lp]
	,MaE_Ilosc as [Ilosc]
	,'OCZEKUJE' as [Status]
	,replace(MaE_JmZ,'.','') as [Jm]

	from cdn.MagNag with(nolock)
	join cdn.MagElem with(nolock) on MaN_GIDNumer = MaE_GIDNumer and MaN_GIDTyp = MaE_GIDTyp
	join cdn.MagSElem with(nolock) on MaE_GIDNumer=MaS_GIDNumer and MaE_GIDLp=MaS_GIDLp
	join cdn.TwrKarty with(nolock) on MaE_TwrNumer = Twr_GIDNumer and MaE_TwrTyp = Twr_GIDTyp

	where MaN_GIDNumer = @GidNumer and MaN_GIDTyp = @GidTyp and MaS_MagNumer = 1 and Twr_Typ in (1,2)
END


END