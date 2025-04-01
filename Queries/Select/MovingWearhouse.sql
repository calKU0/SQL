------------Ustaw parametry analizy ABC dla rotacji towaru-----------
declare @AnalizaA int = 60
declare @AnalizaB int = 80
declare @AnalizaC int = 95;


WITH PodstawoweDane AS (
    SELECT 
        Twr_Kod AS [Kod],
        Twr_Nazwa AS [Nazwa],
		mga_kod AS [Lokalizacja],
        CONVERT(int,twa_ilosc) AS [Stan na lokalizacji],
		CONVERT(decimal(15,2), TSM_Rotacja) AS [Rotacja],
		ISNULL(przenosnik.Atr_Wartosc, '') AS [Przenosnik],
        ISNULL(typTowaru.Atr_Wartosc, '') AS [Typ Towaru],
        CONVERT(decimal(15,3), twa_ilosc * Twr_Waga) AS [Waga na lok w kg],
        CONVERT(decimal(15,3), TSM_Stan * Twr_Waga) AS [Waga maks w kg],
		CONVERT(decimal(15,3), Twr_Waga) AS [Waga w kg],
        convert(int,SUM(TwZ_IlMag)) AS [Suma stanu],
        CONVERT(int, TSM_Stan) AS [Stan maksymalny],
		TSM_Stan * Twr_Waga / 600 AS [MiejscePWaga],
		TSM_KumulacjaRotacji as [Kumulacja Rotacji],
		
				CASE 
			WHEN [TSM_KumulacjaRotacji] <= @AnalizaA THEN 'A'
			WHEN [TSM_KumulacjaRotacji] > @AnalizaA AND [TSM_KumulacjaRotacji] <= @AnalizaB THEN 'B'
			WHEN [TSM_KumulacjaRotacji] > @AnalizaB AND [TSM_KumulacjaRotacji] <= @AnalizaC THEN 'C'
		ELSE 'D' END  AS [Analiza],

		TSM_Stan * CASE 
            WHEN Twr_WymJm = 'cm' THEN Twr_ObjetoscL / 1000000 
            WHEN Twr_WymJm = 'mm' THEN Twr_ObjetoscL / 1000000000 
            WHEN Twr_WymJm = 'dm' THEN Twr_ObjetoscL / 1000 
            ELSE Twr_ObjetoscL 
        END / 0.84 AS [MiejscePObjetosc],

        CONVERT(decimal(15,2), ROUND(
            CASE WHEN Twr_WymJm = 'm' THEN Twr_ObjetoscL * 1000000 
                WHEN Twr_WymJm = 'mm' THEN Twr_ObjetoscL / 1000000000 
                WHEN Twr_WymJm = 'dm' THEN Twr_ObjetoscL / 1000 
                ELSE Twr_ObjetoscL 
            END, 2)) AS [Objetosc w cm3],

        CONVERT(decimal(15,2), ROUND(twa_ilosc * CASE 
            WHEN Twr_WymJm = 'm' THEN Twr_ObjetoscL * 1000000 
            WHEN Twr_WymJm = 'mm' THEN Twr_ObjetoscL / 1000000000 
            WHEN Twr_WymJm = 'dm' THEN Twr_ObjetoscL / 1000 
            ELSE Twr_ObjetoscL 
        END, 2)) AS [Objetosc na lok w cm3],

        CONVERT(decimal(15,2), ROUND(TSM_Stan * CASE 
            WHEN Twr_WymJm = 'm' THEN Twr_ObjetoscL * 1000000 
            WHEN Twr_WymJm = 'mm' THEN Twr_ObjetoscL / 1000000000 
            WHEN Twr_WymJm = 'dm' THEN Twr_ObjetoscL / 1000 
            ELSE Twr_ObjetoscL 
        END, 2)) AS [Objetosc max w cm3]

    FROM [ExpertWMS_Gaska_Produkcja].[dbo].[wms_twrzasobymag] WITH (NOLOCK)
    INNER JOIN [ExpertWMS_Gaska_Produkcja].[dbo].[wms_exp_towaryp] WITH (NOLOCK) ON twa_twrid = etp_twrid
    INNER JOIN CDNXL_GASKA.cdn.TwrKarty WITH (NOLOCK) ON Twr_GIDNumer = etp_sysid
    INNER JOIN [ExpertWMS_Gaska_Produkcja].[dbo].[wms_magadresy] WITH (NOLOCK) ON twa_mgaid = mga_id
    JOIN cdn.TwrZasoby WITH (NOLOCK) ON Twr_GIDNumer = TwZ_TwrNumer
    JOIN dbo.TwrStanyMaksymalne WITH (NOLOCK) ON Twr_GIDNumer = TSM_TwrNumer
    LEFT JOIN cdn.Atrybuty typTowaru WITH (NOLOCK) ON Twr_GIDNumer = typTowaru.Atr_ObiNumer AND Twr_GIDTyp = typTowaru.Atr_ObiTyp AND typTowaru.Atr_AtkId = 148
    LEFT JOIN cdn.Atrybuty przenosnik WITH (NOLOCK) ON Twr_GIDNumer = przenosnik.Atr_ObiNumer AND Twr_GIDTyp = przenosnik.Atr_ObiTyp AND przenosnik.Atr_AtkId = 255
    
	WHERE
-- typTowaru.Atr_Wartosc NOT IN ('Niestandardowy', 'd³ugi do 2mb', 'd³ugi do 3mb') 
--and 
mga_segment2 between 3831 and 4485
	GROUP BY Twr_Kod, Twr_Nazwa, Twr_Waga, mga_kod, twa_ilosc, TSM_Stan, Twr_WymJm, Twr_ObjetoscL, przenosnik.Atr_Wartosc, typTowaru.Atr_Wartosc, TSM_Rotacja, TSM_KumulacjaRotacji

)

SELECT DISTINCT
1 as ID,
PodstawoweDane.Kod as [Kod],
[Nazwa],
[Objetosc w cm3],
[Waga w kg],
[PodstawoweDane].Lokalizacja,
[Stan na lokalizacji],
[Suma stanu],
[Stan maksymalny],
[Objetosc na lok w cm3],
[Objetosc max w cm3],
[Waga na lok w kg],
[Waga maks w kg],
CONVERT(INT, ROUND(IIF(MiejscePWaga > MiejscePObjetosc, MiejscePWaga, MiejscePObjetosc), 0)) AS [Ile max miejsc palet.],
[Typ Towaru],
[Przenosnik],
CONVERT(INT,ISNULL([Rotacja], 0)) AS [Rotacja],
[Kumulacja Rotacji],
[Analiza],

(SELECT TOP 1 mgp_kod
    FROM [ExpertWMS_Gaska_Produkcja].[dbo].[wms_magadresypar] WITH (NOLOCK)
    WHERE mgp_nosnosc > case when CONVERT(INT, ROUND(IIF(MiejscePWaga > MiejscePObjetosc, MiejscePWaga, MiejscePObjetosc), 0)) > 0 then [Waga maks w kg]/CONVERT(INT, ROUND(IIF(MiejscePWaga > MiejscePObjetosc, MiejscePWaga, MiejscePObjetosc), 0)) else [Waga maks w kg] end
    AND mgp_objetosc * 1000000 > case when CONVERT(INT, ROUND(IIF(MiejscePWaga > MiejscePObjetosc, MiejscePWaga, MiejscePObjetosc), 0)) > 0 then [Objetosc max w cm3]/CONVERT(INT, ROUND(IIF(MiejscePWaga > MiejscePObjetosc, MiejscePWaga, MiejscePObjetosc), 0)) else [Objetosc max w cm3] end
	AND mgp_kod like case when CONVERT(INT, ROUND(IIF(MiejscePWaga > MiejscePObjetosc, MiejscePWaga, MiejscePObjetosc), 0)) > 0 then 'PAL%' else '%POL%' end
    ORDER BY mgp_nosnosc, mgp_objetosc) AS [Sugerowany typ lokalizacji]

FROM PodstawoweDane
where Analiza in ('A','B','C') and  [Typ Towaru] NOT IN ('Niestandardowy', 'D³ugi do 2 mb', 'D³ugi do 3 mb', 'Gabarytowy')
order by Lokalizacja