USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [kkur].[WMSPobierzAdresyKontrahenta]    Script Date: 2025-04-01 14:54:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [kkur].[WMSPobierzAdresyKontrahenta]
@GidNumer int,
@GidTyp int
AS
BEGIN
	SET NOCOUNT ON;

select distinct
KnA_KntNumer as [KntGidNumer]
,KnA_Akronim as [AdresAkronim]
,KnA_Nazwa1 as [AdresNazwa]
,KnA_KodP as [KodPocztowy]
,KnA_Miasto as [Miasto]
,KnA_Ulica as [Ulica]
,KnA_Kraj as [Kraj]
,KnA_Opis as [Opis]
,'2025-01-23T13:49:05.391Z' as [DataOd]
from cdn.KntKarty with(nolock)
join cdn.KntAdresy with(nolock) on Knt_GIDNumer = KnA_KntNumer and Knt_GIDTyp = KnA_KntTyp

where KnA_KntNumer = @GidNumer and KnA_KntTyp = @GidTyp and isnull(KnA_DataArc,'') = ''
END
