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
		case 
			when (pon_nrdokobcy is null and prn_nrdokerp is null) then prn_nrdok
			when pon_nrdokobcy is null then prn_nrdokerp 
			else pon_nrdokobcy 
		end as DokumentERP,
		pre_tstamp,
        CASE 
            WHEN pre_typ IN (1110001, 1110011, 1110019) THEN ISNULL(pre_ilosc, 0) -- PM
			WHEN pre_typ = 1130001 then case when pre_przychrozch = 1 then ISNULL(pre_ilosc, 0) else ISNULL(-pre_ilosc, 0) end -- Zmiana po³o¿enia
            WHEN pre_typ IN (1120001, 1120005) THEN ISNULL(-pre_ilosc, 0) --WM
			ELSE 0 
        END AS Ilosc
    FROM dbo.wms_polecrelem
	JOIN dbo.wms_polecrnag on prn_id = pre_id
	left JOIN dbo.wms_polecnag on pon_zrdid = prn_id
	JOIN dbo.wms_magadresy on pre_mgaid = mga_id and mga_segment2 in (12939,13300) -- DW, DX
    WHERE pre_tstamp BETWEEN 1070582400 AND 1072828800 -- 05.12.2023r - 31.12.2023r
	and pre_typ in (1120001, 1120005, 1130001, 1110001, 1110011, 1110019) -- PM, WM, Zmiana po³o¿enia
)


SELECT distinct
	Dateadd(Second, pre_tstamp, '1990-01-01')  as [Data]

	,DokumentERP as [Dokument ERP]

    ,twr_kod AS [Kod]

	,ISNULL(rot.Ilosc, 0) AS [Ilosc]   
	
	,twr_jm as [Jm]

FROM Inwentaryzacja
LEFT JOIN Rotacja rot ON rot.pre_twrid = Inwentaryzacja.twr_id
--where twr_kod = '520.41'
where pre_tstamp is not null
order by 1 desc
