USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [kkur].[WMSPobierzDokumenty]    Script Date: 2025-04-07 14:17:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [kkur].[WMSPobierzDokumenty]
AS
BEGIN
	SET NOCOUNT ON;

select top 0
TrN_GIDNumer as [TrnNumer]
,TrN_GIDTyp as [TrnTyp]
,TypWms as [DokumentTyp]
,cdn.NumerDokumentuTRN(TrN_GIDTyp, TrN_SpiTyp, TrN_TrNTyp, TrN_TrNNumer, TrN_TrNRok, TrN_TrNSeria) as [PelnaNazwa]
,cdn.NumerDokumentuTRN(TrN_GIDTyp, TrN_SpiTyp, TrN_TrNTyp, TrN_TrNNumer, TrN_TrNRok, TrN_TrNSeria) as [Kod]
,'NOWY' as [Status]
,FORMAT(DATEADD(Day, TrN_Data2, '18001228'), 'yyyy-MM-ddTHH:mm:ss.fffZ') as [Data]
,isnull(Wytyczne.Atr_Wartosc,'') as [Opis]
,TrN_SposobDostawy as [SposobDostawy]
,isnull(Priorytet.Atr_Wartosc,100) as [Priorytet]
,'HURT' as [Magazyn]
,TrN_AdWNumer as [KntNumerOdbiorcy]
,TrN_KntNumer as [KntNumer]

-- Adres
,KnA_Akronim as [AdresAkronim]
,KnA_Nazwa1 as [AdresNazwa]
,KnA_KodP as [KodPocztowy]
,KnA_Miasto as [Miasto]
,KnA_Ulica as [Ulica]
,KnA_Kraj as [Kraj]
,KnA_Opis as [Opis]
,FORMAT(GETUTCDATE(), 'yyyy-MM-ddTHH:mm:ss.fffZ') as [DataOd]

from cdn.TraNag with(nolock)
join cdn.KntKarty with(nolock) on TrN_KntNumer = Knt_GIDNumer
join cdn.KntAdresy with(nolock) on KnA_GIDTyp=TrN_AdWTyp AND KnA_GIDNumer=TrN_AdWNumer
join cdn.Atrybuty StatusWMS with(nolock) on TrN_GIDNumer = StatusWMS.Atr_ObiNumer and TrN_GIDTyp = StatusWMS.Atr_ObiTyp and StatusWMS.Atr_AtkId = 355
left join cdn.Atrybuty Wytyczne with(nolock) on TrN_KntNumer = Wytyczne.Atr_ObiNumer and Wytyczne.Atr_ObiTyp = 32 and Wytyczne.Atr_AtkId = 424
left join cdn.Atrybuty Priorytet with(nolock) on TrN_GIDNumer = Priorytet.Atr_ObiNumer and TrN_GIDTyp = Priorytet.Atr_ObiTyp and Priorytet.Atr_AtkId = 351
join kkur.WMSTypyDok with(nolock) on TypErp = TrN_GIDTyp

where StatusWMS.Atr_Wartosc in ('Do synchronizacji', 'Do realizacji') and TrN_Stan in (1,2,3)
-- Co najmniej jedna pozycja jest na HURT
and (select top 1 TrS_GIDLp from cdn.TraSElem with(nolock)
where TrS_GIDNumer = TrN_GIDNumer and TrS_MagNumer = 1) is not null

UNION ALL

select
MaN_GIDNumer as [TrnNumer]
,MaN_GIDTyp as [TrnTyp]
,TypWms as [DokumentTyp]
,cdn.NumerDokumentuTRN(MaN_GIDTyp, 0, MaN_TrNTyp, MaN_TrNNumer, MaN_TrNRok, MaN_TrNSeria) as [PelnaNazwa]
,cdn.NumerDokumentuTRN(MaN_GIDTyp, 0, MaN_TrNTyp, MaN_TrNNumer, MaN_TrNRok, MaN_TrNSeria) as [Kod]
,'NOWY' as [Status]
,FORMAT(DATEADD(Day, MaN_Data3, '18001228'), 'yyyy-MM-ddTHH:mm:ss.fffZ') as [Data]
,isnull(Wytyczne.Atr_Wartosc,'') as [Opis]
,MaN_SposobDostawy as [SposobDostawy]
,isnull(Priorytet.Atr_Wartosc,100) as [Priorytet]
,'HURT' as [Magazyn]
,MaN_KnANumer as [KntNumerOdbiorcy]
,MaN_KntNumer as [KntNumer]

-- Adres
,KnA_Akronim as [AdresAkronim]
,KnA_Nazwa1 as [AdresNazwa]
,KnA_KodP as [KodPocztowy]
,KnA_Miasto as [Miasto]
,KnA_Ulica as [Ulica]
,KnA_Kraj as [Kraj]
,KnA_Opis as [Opis]
,FORMAT(GETUTCDATE(), 'yyyy-MM-ddTHH:mm:ss.fffZ') as [DataOd]

from cdn.MagNag with(nolock)
join cdn.KntKarty with(nolock) on MaN_KntNumer = Knt_GIDNumer
join cdn.KntAdresy with(nolock) on KnA_GIDTyp=MaN_KnATyp AND KnA_GIDNumer=MaN_KnANumer
left join cdn.MaNOpisy with(nolock) on MaN_GIDNumer = MnO_MaNNumer and MaN_GIDTyp = MnO_MaNTyp
join cdn.Atrybuty StatusWMS with(nolock) on MaN_GIDNumer = StatusWMS.Atr_ObiNumer and MaN_GIDTyp = StatusWMS.Atr_ObiTyp and StatusWMS.Atr_AtkId = 355
left join cdn.Atrybuty Wytyczne with(nolock) on MaN_KntNumer = Wytyczne.Atr_ObiNumer and Wytyczne.Atr_ObiTyp = 32 and Wytyczne.Atr_AtkId = 424
left join cdn.Atrybuty Priorytet with(nolock) on MaN_GIDNumer = Priorytet.Atr_ObiNumer and MaN_GIDTyp = Priorytet.Atr_ObiTyp and Priorytet.Atr_AtkId = 351
join kkur.WMSTypyDok with(nolock) on TypErp = MaN_GIDTyp

where StatusWMS.Atr_Wartosc in ('Do synchronizacji', 'Do realizacji') and MaN_Status in (0,1)
-- Co najmniej jedna pozycja jest na HURT
and (select top 1 MaS_GIDLp from cdn.MagSElem with(nolock)
where MaS_GIDNumer = MaN_GIDNumer and MaS_MagNumer = 1) is not null

END
