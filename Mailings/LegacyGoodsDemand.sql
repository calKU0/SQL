DECLARE @PrcNumer INT
DECLARE @Email NVARCHAR(255)

-- Cursor dla opiekunów (Centrum zaopatrzenie)
DECLARE Opiekun_Cursor CURSOR FOR
	SELECT distinct Prc_GIDNumer, Prc_Email
	FROM cdn.OpeKarty
	JOIN cdn.PrcKarty ON Ope_PrcNumer = Prc_GIDNumer
	WHERE Ope_Zablokowane = 0
	AND Ope_FrSId IN (SELECT FRS_ID FROM cdn.frmstruktura WHERE frs_gronumer = 119)
	AND ISNULL(Prc_Email, '') NOT IN ('')

OPEN Opiekun_Cursor
FETCH NEXT FROM Opiekun_Cursor INTO @PrcNumer, @Email

-- Pętla po opiekunach
WHILE @@FETCH_STATUS = 0
BEGIN

    -- Tworzymy tymczasową tabelę
    IF OBJECT_ID('tempdb..#TempTwr') IS NOT NULL TRUNCATE TABLE #TempTwr
    ELSE
    CREATE TABLE #TempTwr (
        Twr_ID INT,
        Knt_ID INT,
        Data DATETIME
    );

	-- Wrzucamy do tabeli dane z zapytania
	-- Zapytanie zbiera wszystkie kliknięte towary w ciagu ostatnich X dni. 
	-- Dodatkowym warunkiem jest to, aby towar miał klikniętą cenę oraz stan oraz żeby wyświetlony stan był różny od 0
    INSERT INTO #TempTwr
    SELECT DISTINCT
        r_twr_twrid AS Twr_ID,
        r_twr_kntid AS Knt_ID,
        DATEADD(MINUTE, DATEDIFF(MINUTE, 0, r_twr_data), 0) AS Data
    FROM [serwer-sql].[nowe_b2b].[ldd].[RptTowary] WITH (NOLOCK)
	join cdn.KntOpiekun WITH (NOLOCK) on KtO_PrcNumer = @PrcNumer
	join cdn.TwrKodyKnt WITH (NOLOCK) on KtO_KntNumer=TKK_KntNumer
	join cdn.TwrKody WITH (NOLOCK) on TwK_Id=TKK_TwKId
	join cdn.TwrKarty with (nolock) on r_twr_twrid = Twr_GIDNumer and TwK_TwrNumer = Twr_GIDNumer
	left join dbo.GaskaTwrWeryfikacjaSpadkow with(nolock) on Twr_GIDNumer = Wer_TwrId
    WHERE r_twr_data BETWEEN GETDATE() - 90 AND GETDATE() 
	AND (r_twr_stan IS NULL OR r_twr_stan <> 0)
	AND (Wer_Description is null or Wer_Date < GETDATE()-90)
    GROUP BY r_twr_twrid, DATEADD(MINUTE, DATEDIFF(MINUTE, 0, r_twr_data), 0), r_twr_kntid
    HAVING COUNT(r_twr_twrid) > 1; -- Użycie tego having pozwala na wyświetlenie tylko tych rekordów gdzie stan i cena zostały kliknięte.

	-- Podzapytanie które sprawdza czy klienci, którzy kliknęli dany towar, złożyli zamówienie w ciagu 2 dni
    IF OBJECT_ID('tempdb..#Zam_Twr') IS NOT NULL DROP TABLE #Zam_Twr
    SELECT DISTINCT
        T.Twr_ID AS Zam_Twr_ID,
        ZaN_GIDNumer AS Zam_Gid
    INTO #Zam_Twr
    FROM #TempTwr T
    JOIN cdn.ZamNag WITH (NOLOCK) ON ZaN_KntNumer = T.Knt_ID AND ZaN_KntTyp = 32
    JOIN cdn.ZamElem WITH (NOLOCK) ON ZaN_GIDNumer = ZaE_GIDNumer AND ZaE_TwrNumer = T.Twr_ID
    WHERE ZaN_DataWystawienia BETWEEN DATEDIFF(DD, '18001228', T.Data) AND DATEDIFF(DD, '18001228', T.Data) + 2;

	-- Podzapytanie które oblicza wartość sprzedaży z tego roku
    IF OBJECT_ID('tempdb..#SprzedazTenRok') IS NOT NULL DROP TABLE #SprzedazTenRok
    SELECT
        Twr_GIDNumer,
        Twr_GidTyp,
        Twr_Kod AS KOD,
        Twr_Nazwa AS NAZWA,
        ISNULL(CONVERT(DECIMAL(9,2), SUM(CONVERT(DECIMAL(9,4), TrE_KsiegowaNetto * 
            CONVERT(DECIMAL(9,4), TrS_Ilosc / NULLIF(CONVERT(DECIMAL(9,4), TrE_Ilosc), 0))))), 0) AS Wartosc
    INTO #SprzedazTenRok
    FROM CDN.TraNag WITH (NOLOCK)
    JOIN CDN.TraSElem WITH (NOLOCK) ON TrN_GIDTyp = TrS_GIDTyp AND TrN_GIDNumer = TrS_GIDNumer
    JOIN CDN.TraElem WITH (NOLOCK) ON TrE_GIDTyp = TrS_GIDTyp AND TrE_GIDNumer = TrS_GIDNumer AND TrE_GIDLp = TrS_GIDLp
    JOIN cdn.KntOpiekun WITH (NOLOCK) ON KtO_PrcNumer = @PrcNumer
    JOIN cdn.TwrKodyKnt WITH (NOLOCK) ON KtO_KntNumer = TKK_KntNumer
    JOIN cdn.TwrKody WITH (NOLOCK) ON TwK_Id = TKK_TwKId
    JOIN cdn.TwrKarty WITH (NOLOCK) ON Twr_GIDNumer = TrE_TwrNumer AND TwK_TwrNumer = Twr_GIDNumer
    WHERE trn_data2 BETWEEN DATEDIFF(DAY, '18001228', GETDATE() - 365) AND DATEDIFF(DAY, '18001228', GETDATE())
      AND trn_gidTyp IN (2033, 2034, 2041, 2042, 2001, 2009, 2037, 2045, 2005, 2013)
      AND TrS_Ilosc <> 0
    GROUP BY Twr_GIDNumer, Twr_GidTyp, Twr_Kod, Twr_Nazwa;

	-- Podzapytanie które oblicza wartość sprzedaży z poprzedniego roku
    IF OBJECT_ID('tempdb..#SprzedazPoprzedniRok') IS NOT NULL DROP TABLE #SprzedazPoprzedniRok
    SELECT
        Twr_GIDNumer,
        Twr_GidTyp,
        ISNULL(CONVERT(DECIMAL(9,2), SUM(CONVERT(DECIMAL(9,4), TrE_KsiegowaNetto * 
            CONVERT(DECIMAL(9,4), TrS_Ilosc / NULLIF(CONVERT(DECIMAL(9,4), TrE_Ilosc), 0))))), 0) AS Wartosc
    INTO #SprzedazPoprzedniRok
    FROM CDN.TraNag WITH (NOLOCK)
    JOIN CDN.TraSElem WITH (NOLOCK) ON TrN_GIDTyp = TrS_GIDTyp AND TrN_GIDNumer = TrS_GIDNumer
    JOIN CDN.TraElem WITH (NOLOCK) ON TrE_GIDTyp = TrS_GIDTyp AND TrE_GIDNumer = TrS_GIDNumer AND TrE_GIDLp = TrS_GIDLp
    JOIN cdn.KntOpiekun WITH (NOLOCK) ON KtO_PrcNumer = @PrcNumer
    JOIN cdn.TwrKodyKnt WITH (NOLOCK) ON KtO_KntNumer = TKK_KntNumer
    JOIN cdn.TwrKody WITH (NOLOCK) ON TwK_Id = TKK_TwKId
    JOIN cdn.TwrKarty WITH (NOLOCK) ON Twr_GIDNumer = TrE_TwrNumer AND TwK_TwrNumer = Twr_GIDNumer
    WHERE trn_data2 BETWEEN DATEDIFF(DAY, '18001228', GETDATE()-730) AND DATEDIFF(DAY, '18001228', GETDATE()-365)
      AND trn_gidTyp IN (2033, 2034, 2041, 2042, 2001, 2009, 2037, 2045, 2005, 2013)
      AND TrS_Ilosc <> 0
    GROUP BY Twr_GIDNumer, Twr_GidTyp;

	-- Finałowy select
	SELECT * INTO #FinalResult FROM (
		-- TOP 5 odrzucenia
		SELECT TOP 5
			Twr_Kod AS [Kod_Towaru],
			Twr_Nazwa AS [Nazwa],
			NULL AS [ROZNICA]
		FROM (
			SELECT 
				T.Twr_ID, 
				COUNT(*) AS Twr_Count,
				ISNULL(Z.Zam_Twr_Count, 0) AS Zam_Twr_Count
			FROM #TempTwr T
			LEFT JOIN (
				SELECT Zam_Twr_ID, COUNT(*) AS Zam_Twr_Count 
				FROM #Zam_Twr 
				GROUP BY Zam_Twr_ID
			) Z ON T.Twr_ID = Z.Zam_Twr_ID
			GROUP BY T.Twr_ID, Z.Zam_Twr_Count
		) A
		JOIN cdn.TwrKarty WITH (NOLOCK) ON A.Twr_ID = Twr_GIDNumer
		ORDER BY ROUND(CAST(A.Twr_Count AS DECIMAL(7,2)) / NULLIF(A.Zam_Twr_Count, 0), 2) DESC

		UNION ALL
		-- TOP 5 spadku sprzedaży
		SELECT TOP 5
			t.KOD,
			t.NAZWA,
			t.Wartosc - ISNULL(l.Wartosc, 0) AS ROZNICA
		FROM #SprzedazTenRok t
		LEFT JOIN #SprzedazPoprzedniRok l ON t.Twr_GIDNumer = l.Twr_GIDNumer AND t.Twr_GidTyp = l.Twr_GidTyp
		ORDER BY (t.Wartosc - ISNULL(l.Wartosc, 0)) ASC

	) AS FinalResult;

	DECLARE @tableHTML NVARCHAR(MAX) = N''
	DECLARE @Temat NVARCHAR(255) = N'Towary ze spadkowym zainteresowaniem - ' + CONVERT(NVARCHAR, GETDATE(), 104)

	SET @tableHTML = 
	N'<h2>' + @Temat + N'</h2>' +
	N'<h2>' + @Email + N'</h2>' +
	N'<table border="1" cellpadding="4" cellspacing="0">' +
	N'<tr><th>Kod</th><th>Nazwa</th></tr>' +
	CAST((
		SELECT
			td = [Kod_Towaru], '',
			td = [Nazwa], ''
		FROM #FinalResult
		FOR XML PATH('tr'), TYPE
	) AS NVARCHAR(MAX)) +
	N'</table>'

	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'Gaska',
		@recipients = 'it@gaska.com.pl;jagaska@gaska.com.pl',
		@subject = @Temat,
		@body = @tableHTML,
		@body_format = 'HTML'

	DROP TABLE #FinalResult
	FETCH NEXT FROM Opiekun_Cursor INTO @PrcNumer, @Email
END

CLOSE Opiekun_Cursor
DEALLOCATE Opiekun_Cursor