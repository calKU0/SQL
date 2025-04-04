USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [kkur].[WMSPobierzKontrahentow]    Script Date: 2025-04-01 14:56:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [kkur].[WMSPobierzKontrahentow]
AS
BEGIN
	SET NOCOUNT ON;

	select
		Knt_GIDNumer as [KntNumer]
		,Knt_GIDTyp as [KntTyp]
		,Knt_Akronim as [Akronim]
		,isnull(nullif(Knt_Nazwa1,''),Knt_Akronim) + ' ' + isnull(Knt_Nazwa2,'') + ' ' + isnull(Knt_Nazwa3,'') as [Nazwa]
		,Knt_EMail as [Email]
		,Knt_Telefon1 as [Telefon]
		,case when Knt_Typ in (8,24) then 1 else 0 end as [Dostawca]
		,Knt_Nip as [NIP]
		,KnO_Opis as [Opis]
		
		,Knt_Nazwa1 as [AdresNazwa]
		,Knt_KodP as [KodPocztowy]
		,Knt_Miasto as [Miasto]
		,Knt_Ulica as [Ulica]
		,Knt_Kraj as [Kraj]
		,StatusWMS.Atr_Wartosc

		from cdn.KntKarty with(nolock)
		left join cdn.KntOpisy with(nolock) on Knt_GIDNumer = KnO_KntNumer
		left join cdn.Atrybuty StatusWMS with(nolock) on Knt_GIDNumer = StatusWMS.Atr_ObiNumer and Knt_GIDTyp = StatusWMS.Atr_ObiTyp and StatusWMS.Atr_AtkId = 355
		where isnull(nullif(StatusWMS.Atr_Wartosc,''), 'Do synchronizacji') = 'Do synchronizacji'
END
