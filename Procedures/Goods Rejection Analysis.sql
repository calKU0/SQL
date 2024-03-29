USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [dbo].[GaskaB2BWspółczynnikOdrzuceniaTowaru]    Script Date: 2023.09.01 15:33:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[GaskaB2BWspółczynnikOdrzuceniaTowaru]
(
@DataOd int,
@DataDo int,
@Top int
)
AS
BEGIN
	SET NOCOUNT ON;
	declare @LiczbaDniWstecz int = @DataDo - @DataOd

-- Tworzymy tymczasową tabelę
CREATE TABLE #TempTwr (
    Twr_ID INT,
    Knt_ID INT,
    Data DATETIME
);

-- Wrzucamy do tabeli dane z zapytania
-- Zapytanie zbiera wszystkie kliknięte towary w ciagu ostatnich X dni. 
-- Dodatkowym warunkiem jest to, aby towar miał klikniętą cenę oraz stan oraz żeby wyświetlony stan był różny od 0
INSERT INTO #TempTwr
SELECT
    r_twr_twrid AS Twr_ID,
    r_twr_kntid AS Knt_ID,
    DATEADD(MINUTE, DATEDIFF(MINUTE, 0, r_twr_data), 0) AS Data -- Zaokrąglenie do pełnych minut, aby można było zgrupować.
FROM [serwer-sql].[nowe_b2b].[ldd].[RptTowary] with(nolock)
WHERE r_twr_data > GETDATE() - @LiczbaDniWstecz
AND (r_twr_stan IS NULL OR r_twr_stan <> 0)
GROUP BY r_twr_twrid, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, r_twr_data), 0), r_twr_kntid
HAVING COUNT(r_twr_twrid) > 1; -- Użycie tego having pozwala na wyświetlenie tylko tych rekordów gdzie stan i cena zostały kliknięte.

-- Podzapytanie które sprawdza czy klienci, którzy kliknęli dany towar, złożyli zamówienie w ciagu 2 dni
WITH Zam_Twr AS (
    SELECT distinct
        T.Twr_ID AS Zam_Twr_ID,
		ZaN_GIDNumer AS Zam_Gid
    FROM #TempTwr T
    JOIN cdn.ZamNag with(nolock) ON ZaN_KntNumer = T.Knt_ID AND ZaN_KntTyp = 32
    JOIN cdn.ZamElem with(nolock) ON ZaN_GIDNumer = ZaE_GIDNumer AND ZaE_TwrNumer = T.Twr_ID
    WHERE ZaN_DataWystawienia BETWEEN DATEDIFF(DD, '18001228', T.Data) AND DATEDIFF(DD, '18001228', T.Data) + 2
    GROUP BY T.Twr_ID, Data, ZaN_GIDNumer
)

-- Zliczenie i wyświetlenie wyników
SELECT TOP (@Top)
    1 AS ID,
    Twr_Kod AS [Kod Towaru],
    T.Twr_Count AS [Ilość Kliknięć B2B],
    Z.Zam_Twr_Count AS [Ilość Zamówień],
	ROUND(CAST(CAST(T.Twr_Count AS DECIMAL(7,2)) / Z.Zam_Twr_Count AS DECIMAL(7,2)),2) AS [Współczynnik odrzucenia %]

FROM (SELECT Twr_ID, COUNT(*) AS Twr_Count FROM #TempTwr GROUP BY Twr_ID) AS T
LEFT JOIN (SELECT Zam_Twr_ID, COUNT(*) AS Zam_Twr_Count FROM Zam_Twr GROUP BY Zam_Twr_ID) AS Z ON T.Twr_ID = Z.Zam_Twr_ID
join cdn.TwrKarty on T.Twr_ID = Twr_GIDNumer

ORDER BY 5 DESC;

-- Usunięcie tymczasowej tabeli
DROP TABLE #TempTwr;

END
