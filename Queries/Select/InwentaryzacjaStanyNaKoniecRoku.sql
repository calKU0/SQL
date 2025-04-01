WITH Inwentaryzacja AS (
    SELECT distinct
        twr_kod,
		twr_jm,
		twr_id,
		ire_mgaid,
        ire_ilosc, -- Zak³adana przed inw
        ipe_ilosczrealiz, -- Odczytana z inwentaryzacji
        ipe_tstamp,
        MAX(ipe_tstamp) OVER (PARTITION BY ipe_mgaid) AS max_tstamp -- Bierzemy maksymalny tstamp gdy na jednej pozycji jest wiêcej ni¿ 1 odczyt
    FROM dbo.wms_inwnag
    JOIN dbo.wms_inwrnag ON irn_inwid = inw_id
    JOIN dbo.wms_inwrelem ON irn_id = ire_id AND ire_parid NOT IN (0,1)
    JOIN dbo.wms_inwpnag ON ipn_inwid = inw_id
    LEFT JOIN dbo.wms_inwpelem ON ipe_id = ipn_id AND ire_twrid = ipe_twrid AND ipe_mgaid = ire_mgaid
    JOIN dbo.wms_towary ON twr_id = ire_twrid
    WHERE inw_id = 362 --AND twr_kod = '600981.41'
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
    FROM dbo.wms_polecrelem
	JOIN dbo.wms_magadresy on pre_mgaid = mga_id and mga_segment2 in (12939,13300) -- DW, DX
    WHERE pre_tstamp BETWEEN 1070582400 AND 1072828800 -- 05.12.2023r - 31.12.2023r
	and pre_typ in (1120001, 1120005, 1130001, 1110001, 1110011, 1110019) -- PM, WM, Zmiana po³o¿enia
    GROUP BY pre_twrid
),

Dokument AS (
    SELECT distinct
        pre_twrid,
        pre_mgaid,
        CASE 
            WHEN ZRD.MaN_CechaOpis IS NULL THEN ZRDTRN.TrN_DokumentObcy 
            ELSE ZRD.MaN_CechaOpis 
        END AS Dokument,
        trn_data2,
        trn_godzinawystawienia,
        ROW_NUMBER() OVER (PARTITION BY pre_twrid, pre_mgaid 
                           ORDER BY trn_data2 DESC, trn_godzinawystawienia DESC) AS rn
    FROM dbo.wms_polecrelem
    JOIN dbo.wms_polecrnag ON pre_id = prn_id
    JOIN dbo.wms_magadresy ON pre_mgaid = mga_id AND mga_segment2 IN (12939, 13300) -- DW, DX
    JOIN dbo.wms_towary ON pre_twrid = twr_id
    JOIN CDNXL_GASKA.CDN.MagNag MMP ON prn_nrdok = MaN_CechaOpis
    LEFT JOIN CDNXL_GASKA.CDN.MagNag ZRD ON MMP.MaN_ZrdNumer = ZRD.MaN_GIDNumer AND MMP.MaN_ZrdTyp = ZRD.MaN_GIDTyp
    LEFT JOIN CDNXL_GASKA.CDN.TraNag ZRDTRN ON MMP.MaN_ZrdNumer = ZRDTRN.TrN_GIDNumer AND MMP.MaN_ZrdTyp = ZRDTRN.TrN_GIDTyp
    WHERE pre_tstamp BETWEEN 1070582400 AND 1072828800 -- 05.12.2023 - 31.12.2023
      AND pre_typ IN (1120001, 1120005, 1130001, 1110001, 1110011, 1110019) -- PM, WM, Zmiana po³o¿enia
)

SELECT
    twr_kod AS [Kod]
    
	,ISNULL(rot.rotacja, 0) AS [Rotacja pomiêdzy 05.12.23r a 31.12.23r]
    
	,isnull(SUM(CASE WHEN ipe_tstamp = max_tstamp THEN ipe_ilosczrealiz ELSE null END), SUM(DISTINCT ire_ilosc)) + ISNULL(rot.rotacja, 0) as [Stany na dzieñ 31.12.23r]
	
	,twr_jm as [Jm]
	
	,(isnull(SUM(CASE WHEN ipe_tstamp = max_tstamp THEN ipe_ilosczrealiz ELSE null END),SUM(DISTINCT ire_ilosc)) + ISNULL(rot.rotacja, 0)) * dbo.Gaska_Stany_Magazynowe_Na_Dzien(twr_kod,81452) as [Wartosc na dzieñ 31.12.23r]

	,Dokument as [Dokument]

FROM Inwentaryzacja
LEFT JOIN Rotacja rot ON rot.pre_twrid = Inwentaryzacja.twr_id
LEFT JOIN Dokument ON dokument.pre_twrid = Inwentaryzacja.twr_id and Dokument.pre_mgaid = Inwentaryzacja.ire_mgaid and Dokument.rn=1
--where twr_kod = '520.41'
GROUP BY twr_kod, twr_jm, rotacja, Dokument--,Dokument.pre_ilosc
order by 1 
