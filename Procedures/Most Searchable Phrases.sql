USE [CDNXL_TESTOWA_2014]
GO
/****** Object:  StoredProcedure [dbo].[InsertB2B_Wyszukiwania_jest_karta]    Script Date: 22.02.2023 11:53:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[InsertB2B_Wyszukiwania_jest_karta]
AS
BEGIN
  Delete from dbo.b2b_dane_wyszukiwania
  INSERT INTO dbo.b2b_dane_wyszukiwania ([dane_twrid],[dane_twrwyszuk],[dane_wyszukilosc],[dane_kntilosc])
  SELECT
  [R_twr_twrid],
  r_twr_zapytanie,
  COUNT(R_twr_zapytanie) as [ciag],
  R_twr_KntID as [kont]
  FROM [serwer-sql].[nowe_b2b].[ldd].[RptTowary] a with (nolock)
  where r_twr_stan = 0
  AND R_TWR_twrID NOT IN (SELECT tre_twrNumer FROM cdn.TraElem  WITH (NOLOCK) WHERE CONVERT(DATETIME, DATEADD(SECOND, Tre_TrnTStamp, '1990-01-01')) > GETDATE()-365) 
  AND R_TWR_twrID NOT IN (SELECT ZaE_TwrNumer FROM cdn.ZamElem  WITH (NOLOCK) JOIN cdn.ZamNag  WITH (NOLOCK) ON ZaN_GIDNumer=ZaE_GIDNumer WHERE zan_stan<>2 AND ZaN_ZamTyp=1152 AND CONVERT(DATETIME, DATEADD(DAY, ZaE_DataAktywacjiRez, '18001228')) > GETDATE()-365) 
  group by R_twr_twrID,r_twr_zapytanie,r_twr_kntid
END
