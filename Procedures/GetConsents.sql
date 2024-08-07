USE [CDNXL_TESTOWA_B2B]
GO
/****** Object:  StoredProcedure [ldd].[UzytkownicyPobierzAdresy]    Script Date: 2024.08.07 09:39:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [ldd].[PobierzZgody](@kntID int, @kntLp int, @idLang int)
as
begin
	SELECT
	SLW_ID AS [IdZgody]
	,CASE WHEN (@IdLang = 1 OR TLM_Tekst IS NULL) THEN SLW_WartoscS ELSE TLM_Tekst END AS [NazwaZgody]
	,SLW_WartoscS1 AS [LinkDoZgody]
	,Zgo_IP AS [ŻródłoUdzielenia]
	,Zgo_DataUdzielenia AS [DataUdzielenia]
	,CASE WHEN Zgo_DataUdzielenia IS NULL THEN 0 ELSE 1 END AS [Status]

	FROM cdn.Slowniki 
	LEFT JOIN cdn.Zgody ON Zgo_RodzajZgody = SLW_ID AND Zgo_DataWycofania <=0 AND Zgo_ObiNumer = @kntID AND Zgo_ObiLp = @kntLp
	LEFT JOIN cdn.Tlumaczenia ON SLW_ID=TLM_Numer AND TLM_Typ = 8225 AND TLM_Pole = 2 AND TLM_Jezyk = @idLang

	WHERE SLW_SLSId = 172
	AND SLW_Aktywny = 1
end
