DECLARE @twrgid INT;
DECLARE @ilosc DECIMAL(15,4);
DECLARE @waga DECIMAL(15,4);
DECLARE @jltid INT;
DECLARE @kierunek varchar (50);
DECLARE @mgaid int;
DECLARE @mgakod varchar (50);
DECLARE @dokid int;


--2164888

DELETE GaskaKolejkaAktualizacjiAtrybutu

FROM GaskaKolejkaAktualizacjiAtrybutu

LEFT JOIN wms_polecrnag ON dok_id = prn_id

LEFT JOIN wms_polecrelem on pre_id = prn_id

WHERE wms_polecrnag.prn_id IS NULL or pre_jltid = 1 or pre_id is null

IF OBJECT_ID('tempdb..#TempResults') IS NOT NULL
BEGIN
	DROP TABLE #TempResults;
END
SELECT *
INTO #TempResults
FROM (
    SELECT 
        twa_twrid AS twrid,
        twa_ilosc AS ilosc,
        twj_wagabrutto * twa_ilosc AS waga,
        pre_jltid AS jltid,
		prn_id as dokid,
        ROW_NUMBER() OVER (PARTITION BY pre_jltid ORDER BY twj_wagabrutto * twa_ilosc DESC) AS rowNumber
    FROM wms_polecrnag with(nolock)
    JOIN wms_polecrelem with(nolock) ON pre_id = prn_id
    LEFT JOIN wms_twrzasobymag with(nolock) ON pre_jltid = twa_jltid
    LEFT JOIN wms_towaryjm with(nolock) ON twa_twrid = twj_twrid AND twj_twrlp = 1
	JOIN GaskaKolejkaAktualizacjiAtrybutu ON prn_id = dok_id
where pre_jltid <> 1
) AS RankedData
WHERE rowNumber = 1;

DECLARE Cursor_ CURSOR LOCAL FAST_FORWARD FOR
    SELECT twrid, ilosc, waga, jltid, dokid FROM #TempResults;
OPEN Cursor_;
FETCH NEXT FROM Cursor_
INTO @twrgid, @ilosc, @waga, @jltid, @dokid;

delete from GaskaKolejkaAktualizacjiAtrybutu where dok_id = @dokid


WHILE @@fetch_status = 0
BEGIN  
	IF (@twrgid is null)
	BEGIN
		exec wms_atrwartosc 9140001,@jltid,0,44,'Pusta'
	END
	ELSE
	BEGIN
		IF OBJECT_ID('tempdb..#TabelaObliczaniaObjetosci') IS NOT NULL
		BEGIN
			TRUNCATE TABLE #TabelaObliczaniaObjetosci;
		END
		ELSE
		BEGIN
			CREATE TABLE #TabelaObliczaniaObjetosci (
				mgaid INT PRIMARY KEY,
				pozostalaObjetosc DECIMAL(18, 2),
				aktualnapozostalaObjetosc DECIMAL(18, 2)
			);
		END

		INSERT INTO #TabelaObliczaniaObjetosci (mgaid, pozostalaObjetosc, aktualnapozostalaObjetosc)
			SELECT 
				mga_id AS mgaid, 
				--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
				(mgp_objetosc * 1000000 * 0.9 / CASE WHEN RIGHT(mga_kod, 3) <> '000' THEN ISNULL(NULLIF(maxSKU.maa_wartosc, 0), 1) ELSE 1 END) -
				ISNULL(SUM(DISTINCT skladowanyTwrMax.TSM_Stan * dbo.PrzeliczNaCM3(skladowanyTwr.twj_objetoscjm, skladowanyTwr.twj_objetosc)), 0) -
				CASE WHEN dokladanyTwrMax.TSM_TwrNumer in (select distinct twa_twrid from wms_twrzasobymag where twa_mgaid = mga_id) THEN 0 
				ELSE ISNULL(SUM(DISTINCT dokladanyTwrMax.TSM_Stan * dbo.PrzeliczNaCM3(dokladanyTwr.twj_objetoscjm, dokladanyTwr.twj_objetosc)), 0) END AS [pozostalaObjetosc],
				--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
				(mgp_objetosc * 1000000 * 0.9 / CASE WHEN RIGHT(mga_kod, 3) <> '000' THEN ISNULL(NULLIF(maxSKU.maa_wartosc, 0), 1) ELSE 1 END) -
				ISNULL(SUM(DISTINCT twa_ilosc * dbo.PrzeliczNaCM3(skladowanyTwr.twj_objetoscjm, skladowanyTwr.twj_objetosc)), 0) AS [aktualnapozostalaObjetosc]
			FROM 
				wms_magadresy WITH (NOLOCK) 
				JOIN wms_magadresypar WITH (NOLOCK) ON mga_mgpid = mgp_id 
				LEFT JOIN wms_twrzasobymag WITH (NOLOCK) ON twa_mgaid = mga_id
				LEFT JOIN wms_towaryjm skladowanyTwr WITH (NOLOCK) ON skladowanyTwr.twj_twrid = twa_twrid AND skladowanyTwr.twj_twrlp = 1
				LEFT JOIN dbo.TwrStanyMaksymalne skladowanyTwrMax WITH (NOLOCK) ON skladowanyTwr.twj_twrid = skladowanyTwrMax.TSM_TwrNumer 
				JOIN wms_towaryjm dokladanyTwr WITH (NOLOCK) ON dokladanyTwr.twj_twrid = @twrgid AND dokladanyTwr.twj_twrlp = 1
				JOIN dbo.TwrStanyMaksymalne dokladanyTwrMax WITH (NOLOCK) ON dokladanyTwr.twj_twrid = dokladanyTwrMax.TSM_TwrNumer 
				JOIN wms_magadresyatrybuty maxSKU WITH (NOLOCK) ON maxSKU.maa_atrid = 43 AND mga_id = maa_mgaid 
			WHERE mga_mgpid > 1 
			GROUP BY mgp_objetosc, maa_wartosc, mga_id, mga_kod, dokladanyTwrMax.TSM_TwrNumer

			---------------------------------------------------------------------------------------

			select top 1 @mgaid = mga_id, @mgakod = mga_kod
			,@kierunek = 
			case when mgw_id = 8011 then 'Kompletacja_A0'
				when mgw_id = 8012 then 'Kompletacja_A0'
				when mgw_id = 8013 then 'Kompletacja_A3'
				when mgw_id = 8014 then 'Kompletacja_A2'
				when mgw_id = 8015 then 'Konsolidacja'
				when mgw_id = 8016 then 'Konsolidacja'
				when mgw_id = 8017 then 'Kompletacja_A0'
				when mgw_id = 8018 then 'Kompletacja_A1'
				when mgw_id = 8021 then 'Konsolidacja'
				when mgw_id = 8022 then 'Konsolidacja'
				when mgw_id = 8024 then 'Konsolidacja'
				else 'Konsolidacja'
			end

			from wms_exp_towaryp WITH (NOLOCK)
			join dbo.TwrStanyMaksymalne WITH (NOLOCK) on TSM_TwrNumer = etp_twrid
			join [CDNXL_GASKA].cdn.Atrybuty typtowaru  WITH (NOLOCK) on typtowaru.Atr_AtkId in (148) and typtowaru.Atr_ObiNumer = etp_sysid -- Przenoœnik taœmowy towar
			join [CDNXL_GASKA].cdn.Atrybuty sorter WITH (NOLOCK) on sorter.Atr_AtkId in (255) and sorter.Atr_ObiNumer = etp_sysid -- Przenoœnik taœmowy towar
			join AtrybutyLokalizacji() on 1=1
			join wms_magadresy WITH (NOLOCK) on AtrybutyLokalizacji.mgaid = mga_id
			left join [dbo].[wms_magadresywirt_powiaz] on mwp_mgaid=mga_id
			left join [dbo].[wms_magadresywirt] with (nolock) on mgw_id=mwp_mgwid and mgw_mgaid = 0
			join #TabelaObliczaniaObjetosci on mga_id = #TabelaObliczaniaObjetosci.mgaid
			join wms_magadresypar with(nolock) on mga_mgpid = mgp_id

			where etp_twrid=@twrgid
			AND     (
					typtowaru.atr_wartosc IN ('Niestandardowy', 'D³ugi do 2 mb', 'D³ugi do 3 mb', 'Gabarytowy')
					OR 
					(
						(ISNULL(TSM_Analiza, 'E') = 'A' AND analiza IN ('A', 'B'))
						OR
						(ISNULL(TSM_Analiza, 'E') = 'B' AND analiza IN ('B', 'C'))
						OR
						(ISNULL(TSM_Analiza, 'E') = 'C' AND analiza IN ('C', 'D', 'E'))
						OR
						(ISNULL(TSM_Analiza, 'E') = 'D' AND analiza IN ('D', 'E'))
						OR
						(ISNULL(TSM_Analiza, 'E') NOT IN ('A', 'B', 'C', 'D') AND analiza = 'E')
					)
				)

			AND maxSKU > (select distinct count(twa_twrid) from wms_twrzasobymag WITH (NOLOCK) where mga_id = twa_mgaid and twa_twrid <> @twrgid)
			AND sorter.Atr_Wartosc = CASE WHEN isnull(Sorter,'Wszystkie') = 'Wszystkie' THEN sorter.Atr_Wartosc ELSE Sorter END
			AND (
				(typtowaru.Atr_Wartosc IN ('Niestandardowy', 'D³ugi do 2 mb', 'D³ugi do 3 mb', 'Gabarytowy') AND mgw_parentmgwid NOT IN (8009, 8008))
				OR
				(typtowaru.Atr_Wartosc NOT IN ('Niestandardowy', 'D³ugi do 2 mb', 'D³ugi do 3 mb', 'Gabarytowy') AND mgw_parentmgwid NOT IN (1))
			)
			AND mga_zasoby = 1
			AND mga_mgpid <> 1
			AND mga_aktywny = 1
			AND NOT ((MGA_KOD BETWEEN 'AA' AND 'AO' or MGA_KOD in ('CD')) AND len(LEFT(mga_kod, CHARINDEX('-', mga_kod + '-') - 1))=2)
			AND (select mgp_kod from wms_magadresypar where mgp_id = mga_mgpid) like case when pozostalaObjetosc < 0 then ('%PAL%') else ('%%') end
			AND aktualnapozostalaObjetosc>0

			order by
			case when mga_kod like 'ZDJ%' THEN 2 ELSE 1 END
			,case when mga_id = (select top 1 mgs_mgaid from wms_magadresystany
			JOIN wms_magadresyatrybuty WITH (NOLOCK) on maa_atrid = 39 and maa_mgaid = mgs_mgaid
			join dbo.TwrStanyMaksymalne WITH (NOLOCK) on TSM_TwrNumer = @twrgid -- and maa_wartosc=TSM_analiza
			where mgs_twrid = @twrgid
			) then 1 else 999 end
			,Analiza --as [2gi order (Typ rotacji)]
			,mgp_objetosc * 1000000 / isnull(nullif(MaxSKU,0), 1)  -- as [1szy order (Objetosc typu polki)]
			,(select count(twa_twrid) from wms_twrzasobymag WITH (NOLOCK) where twa_mgaid = mga_id) --as [3ci order (Ilosc Towaru skladowanego na polce)]
			,pozostalaObjetosc
			,mga_kod

			exec wms_atrwartosc 9140001,@jltid,0,44,@kierunek
		END

		FETCH NEXT FROM Cursor_
		INTO @twrgid, @ilosc, @waga, @jltid, @dokid;
END;

CLOSE Cursor_;
DEALLOCATE Cursor_;

DROP TABLE #TempResults;
