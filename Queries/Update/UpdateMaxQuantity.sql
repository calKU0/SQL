UPDATE dbo.twrStanyMaksymalne 
SET 
    TSM_Stan = CASE 
                   WHEN TSM_STAN > podzapytanie.Iloœæ THEN TSM_STAN 
                   ELSE podzapytanie.Iloœæ 
               END,
    TSM_StanData = CASE 
                       WHEN TSM_STAN > podzapytanie.Iloœæ THEN TSM_StanData 
                       ELSE CONVERT(date, GETDATE()) 
                   END,
    TSM_Rotacja = podzapytanie.Rotacja,
    TSM_KumulacjaRotacji = podzapytanie.KumulacjaRotacji
FROM (
    SELECT DISTINCT
        a.Twr_GIDNumer,
        ISNULL(SUM(twz.TwZ_IlMag), 0) AS [Iloœæ],
        ISNULL(rotacja.RotacjaHurt, 0) AS [Rotacja],
        ISNULL(
            SUM(CONVERT(decimal(15, 2), rotacja.RotacjaHurt)) OVER (
                ORDER BY 
                    CONVERT(decimal(15, 2), rotacja.RotacjaHurt) DESC,
                    twr_waga + CASE 
                                   WHEN Twr_WymJm = 'cm' THEN Twr_ObjetoscL / 1000000 
                                   WHEN Twr_WymJm = 'mm' THEN Twr_ObjetoscL / 1000000000 
                                   WHEN Twr_WymJm = 'dm' THEN Twr_ObjetoscL / 1000 
                                   ELSE Twr_ObjetoscL 
                               END DESC
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) * 100 / SUM(rotacja.RotacjaHurt) OVER (), 
        0) AS [KumulacjaRotacji]
    FROM cdn.TwrKarty a
    JOIN cdn.TwrZasoby twz ON a.Twr_GIDNumer = twz.TwZ_TwrNumer
    LEFT JOIN (
        SELECT
            twr.Twr_GIDNumer AS gidNumer,
            COUNT(DISTINCT CASE 
                               WHEN TrN_FrsID NOT IN (7, 8, 9, 70, 173, 887, 949) 
                               THEN trn.TrN_GIDNumer 
                           END) AS [RotacjaHurt]
        FROM CDN.TraNag trn WITH (NOLOCK)
        JOIN CDN.TraElem tre WITH (NOLOCK) ON trn.TrN_GIDTyp = tre.TrE_GIDTyp AND trn.TrN_GIDNumer = tre.TrE_GIDNumer
        JOIN CDN.TraSElem trs WITH (NOLOCK) ON tre.TrE_GIDTyp = trs.TrS_GIDTyp AND tre.TrE_GIDNumer = trs.TrS_GIDNumer AND tre.TrE_GIDLp = trs.TrS_GIDLp
        JOIN CDN.TwrKarty twr WITH (NOLOCK) ON twr.Twr_GIDNumer = tre.TrE_TwrNumer
        WHERE 
            trn.TrN_GIDTyp IN (2033, 2034, 2041, 2042, 2001, 2009, 2037, 2045, 2005, 2013)
            AND trs.TrS_Ilosc <> 0
            AND trn.TrN_Data3 > (CONVERT(INT, DATEDIFF(DAY, '1800-12-28', GETDATE())) - 366)
            AND trs.TrS_MagNumer = 1
        GROUP BY 
            twr.Twr_GIDNumer
    ) AS rotacja ON rotacja.gidNumer = a.Twr_GIDNumer
    WHERE 
        a.Twr_Typ IN (1, 2)
    GROUP BY a.Twr_GIDNumer, rotacja.RotacjaHurt, Twr_Waga, Twr_ObjetoscL, Twr_WymJm
) AS podzapytanie
WHERE 
    dbo.twrStanyMaksymalne.TSM_TwrNumer = podzapytanie.Twr_GIDNumer;
