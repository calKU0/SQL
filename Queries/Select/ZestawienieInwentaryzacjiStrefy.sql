WITH Inwentaryzacja AS (
    SELECT 
		twr_id,
        twr_kod,
		twr_jm,
        ire_ilosc, -- Zak³adana przed inw
        ipe_ilosczrealiz, -- Odczytana z inwentaryzacji
		ire_mgaid,
        ipe_mgaid,
        ipe_tstamp,
        MAX(ipe_tstamp) OVER (PARTITION BY ipe_mgaid) AS max_tstamp -- Bierzemy maksymalny tstamp gdy wiêcej odczytów na jednej lokalizacji
    FROM dbo.wms_inwnag
    JOIN dbo.wms_inwrnag WITH(NOLOCK) ON irn_inwid = inw_id
    JOIN dbo.wms_inwrelem WITH(NOLOCK) ON irn_id = ire_id AND ire_parid NOT IN (0,1)
    JOIN dbo.wms_inwpnag WITH(NOLOCK) ON ipn_inwid = inw_id
    LEFT JOIN dbo.wms_inwpelem WITH(NOLOCK) ON ipe_id = ipn_id AND ire_twrid = ipe_twrid AND ipe_mgaid = ire_mgaid
    JOIN dbo.wms_towary WITH(NOLOCK) ON twr_id = ire_twrid
    WHERE inw_id = 362
),

DokumentINW AS (
    SELECT distinct
		pre_typ,
        pre_twrid,
        pre_mgaid,
		prn_typ,
        CASE 
            WHEN ZRD.MaN_CechaOpis IS NULL THEN [CDNXL_GASKA].CDN.NumerDokumentuTRN(ZRDTRN.TrN_GIDTyp, ZRDTRN.TrN_SpiTyp, ZRDTRN.TrN_TrNTyp, ZRDTRN.TrN_TrNNumer, ZRDTRN.TrN_TrNRok, ZRDTRN.TrN_TrNSeria)
            ELSE ZRD.MaN_CechaOpis 
        END AS DokumentINW,
        trn_data2,
        trn_godzinawystawienia,
        ROW_NUMBER() OVER (PARTITION BY pre_twrid
                           ORDER BY trn_data2 asc, trn_godzinawystawienia asc) AS rn
    FROM dbo.wms_polecrelem WITH(NOLOCK)
    JOIN dbo.wms_polecrnag WITH(NOLOCK) ON pre_id = prn_id
    JOIN dbo.wms_magadresy WITH(NOLOCK) ON pre_mgaid = mga_id AND mga_segment2 IN (12939, 13300) -- DW, DX
    JOIN dbo.wms_towary WITH(NOLOCK) ON pre_twrid = twr_id
    JOIN CDNXL_GASKA.CDN.MagNag MMP WITH(NOLOCK) ON prn_nrdok = MaN_CechaOpis
    LEFT JOIN CDNXL_GASKA.CDN.MagNag ZRD WITH(NOLOCK) ON MMP.MaN_ZrdNumer = ZRD.MaN_GIDNumer AND MMP.MaN_ZrdTyp = ZRD.MaN_GIDTyp
    LEFT JOIN CDNXL_GASKA.CDN.TraNag ZRDTRN WITH(NOLOCK) ON MMP.MaN_ZrdNumer = ZRDTRN.TrN_GIDNumer AND MMP.MaN_ZrdTyp = ZRDTRN.TrN_GIDTyp
    WHERE pre_tstamp >= 1070582400 
     AND prn_typ in (1110990, 1120990)
	 --and twr_kod = '008550.01'
),

Rotacja AS (
    SELECT 
        pre_twrid,
        SUM(
            CASE 
                WHEN pre_typ IN (1110001, 1110011, 1110019) THEN ISNULL(pre_ilosc, 0) -- PM
				WHEN pre_typ = 1130001 then case when pre_przychrozch = 1 then ISNULL(pre_ilosc, 0) else ISNULL(-pre_ilosc, 0) end -- Zmiana po³o¿enia
                WHEN pre_typ IN (1120001, 1120005) THEN ISNULL(-pre_ilosc, 0) --WM
				ELSE 0 
            END
        ) AS rotacja
    FROM dbo.wms_polecrelem WITH(NOLOCK)
	JOIN dbo.wms_magadresy WITH(NOLOCK) on pre_mgaid = mga_id and mga_segment2 in (12939,13300) -- DW, DX
    WHERE pre_tstamp BETWEEN 1070582400 AND 1072828800 -- 05.12.2023r - 31.12.2023r
	and pre_typ in (1120001, 1120005, 1130001, 1110001, 1110011, 1110019) -- PM, WM, Zmiana po³o¿enia
    GROUP BY pre_twrid
),

OstDokumentPrzedINW AS (
    SELECT distinct
        pre_twrid,
        pre_mgaid,
        CASE 
            WHEN ZRD.MaN_CechaOpis IS NULL THEN [CDNXL_GASKA].CDN.NumerDokumentuTRN(ZRDTRN.TrN_GIDTyp, ZRDTRN.TrN_SpiTyp, ZRDTRN.TrN_TrNTyp, ZRDTRN.TrN_TrNNumer, ZRDTRN.TrN_TrNRok, ZRDTRN.TrN_TrNSeria)
            ELSE ZRD.MaN_CechaOpis 
        END AS Dokument,
        trn_data2,
        trn_godzinawystawienia,
        ROW_NUMBER() OVER (PARTITION BY pre_twrid
                           ORDER BY trn_data2 DESC, trn_godzinawystawienia DESC) AS rn
    FROM dbo.wms_polecrelem WITH(NOLOCK)
    JOIN dbo.wms_polecrnag WITH(NOLOCK) ON pre_id = prn_id
    JOIN dbo.wms_magadresy WITH(NOLOCK) ON pre_mgaid = mga_id AND mga_segment2 IN (12939, 13300) -- DW, DX
    JOIN dbo.wms_towary WITH(NOLOCK) ON pre_twrid = twr_id
    JOIN CDNXL_GASKA.CDN.MagNag MMP WITH(NOLOCK) ON prn_nrdok = MaN_CechaOpis
    LEFT JOIN CDNXL_GASKA.CDN.MagNag ZRD WITH(NOLOCK) ON MMP.MaN_ZrdNumer = ZRD.MaN_GIDNumer AND MMP.MaN_ZrdTyp = ZRD.MaN_GIDTyp
    LEFT JOIN CDNXL_GASKA.CDN.TraNag ZRDTRN WITH(NOLOCK) ON MMP.MaN_ZrdNumer = ZRDTRN.TrN_GIDNumer AND MMP.MaN_ZrdTyp = ZRDTRN.TrN_GIDTyp
    WHERE pre_tstamp <= 1070582400 -- 05.12.2023
     -- AND pre_typ IN (1120001, 1120005, 1130001, 1110001, 1110011, 1110019) -- PM, WM, Zmiana po³o¿enia
)

SELECT
    twr_kod AS [Kod]

	,OstDokumentPrzedINW.Dokument as [Ostatni dokument przed INW]

    ,CONVERT(DECIMAL(15,2), SUM(DISTINCT ire_ilosc)) AS [Ilosc na dzien 04.12.2023r]

	,CONVERT(DECIMAL(15,2), SUM(DISTINCT ire_ilosc) * dbo.Gaska_Stany_Magazynowe_Na_Dzien(twr_kod,81425)) as [Wartosc na dzien 04.12.2023r]

    ,CONVERT(DECIMAL(15,2), isnull(SUM(CASE WHEN ipe_tstamp = max_tstamp THEN ipe_ilosczrealiz ELSE null END), SUM(DISTINCT ire_ilosc))) AS [Ilosc na dzien 05.12.2023r]

	,CONVERT(DECIMAL(15,2), isnull(SUM(CASE WHEN ipe_tstamp = max_tstamp THEN ipe_ilosczrealiz ELSE null END), SUM(DISTINCT ire_ilosc)) * dbo.Gaska_Stany_Magazynowe_Na_Dzien(twr_kod,81426)) as [Wartosc na dzien 05.12.2023r]

	,CONVERT(DECIMAL(15,2), SUM(DISTINCT ire_ilosc) - isnull(SUM(CASE WHEN ipe_tstamp = max_tstamp THEN ipe_ilosczrealiz ELSE null END), SUM(DISTINCT ire_ilosc))) as [Roznica Ilosci]

	,CONVERT(DECIMAL(15,2), (SUM(DISTINCT ire_ilosc) - isnull(SUM(CASE WHEN ipe_tstamp = max_tstamp THEN ipe_ilosczrealiz ELSE null END), SUM(DISTINCT ire_ilosc))) * dbo.Gaska_Stany_Magazynowe_Na_Dzien(twr_kod,81426)) as [Roznica Wartosci]

	,isnull(DokumentINW,'') as [Dokument po INW]
	    
	,CONVERT(DECIMAL(15,2), ISNULL(rot.rotacja, 0)) AS [Rotacja pomiêdzy 05.12.23r a 31.12.23r]
    
	,CONVERT(DECIMAL(15,2), isnull(SUM(CASE WHEN ipe_tstamp = max_tstamp THEN ipe_ilosczrealiz ELSE null END), SUM(DISTINCT ire_ilosc)) + ISNULL(rot.rotacja, 0)) as [Stany na dzieñ 31.12.23r]

	,CONVERT(DECIMAL(15,2), isnull((isnull(SUM(CASE WHEN ipe_tstamp = max_tstamp THEN ipe_ilosczrealiz ELSE null END), SUM(DISTINCT ire_ilosc)) + ISNULL(rot.rotacja, 0)) * dbo.Gaska_Stany_Magazynowe_Na_Dzien(twr_kod,81452),0)) as [Wartosc na dzieñ 31.12.23r]

	,twr_jm as [Jm]
	
FROM Inwentaryzacja
LEFT JOIN Rotacja rot ON rot.pre_twrid = Inwentaryzacja.twr_id
LEFT JOIN DokumentINW ON DokumentINW.pre_twrid = Inwentaryzacja.twr_id and DokumentINW.rn=1
LEFT JOIN OstDokumentPrzedINW ON OstDokumentPrzedINW.pre_twrid = Inwentaryzacja.twr_id and OstDokumentPrzedINW.rn=1
--where twr_kod = '676235.09'
GROUP BY twr_kod, twr_jm, DokumentINW,DokumentINW.pre_typ, rot.rotacja, OstDokumentPrzedINW.Dokument
order by 1
