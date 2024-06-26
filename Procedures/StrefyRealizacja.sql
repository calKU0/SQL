USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [dbo].[StrefyRealizacja]    Script Date: 2024.06.18 10:34:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[StrefyRealizacja] 

AS
BEGIN

	SET NOCOUNT ON;

declare @data int = dbo.wms_data2int(getdate())
declare @data2 datetime =  (select DATEADD(MINUTE, -convert(int,KPK_Wartosc), GETDATE()) FROM [CDNXL_GASKA].[dbo].[KontrolaPakowaniaKonfiguracja] where [KPK_Parametr] = 'Strefy realizacja, czas ostatniej realizacji operatora większy niż X minut')

SELECT 
case when (select tryb from [ExpertWMS_Gaska_Produkcja].[dbo].[wms_d_zajetosc_sortera] with(nolock))=2 then 'Dobieranie' else 'Std' end  as TRYB
,case
	when left(A.pon_nrdok,9) = 'PWM-PI1-1' then 'PI1-1 AA-AO'
	when left(A.pon_nrdok,9) = 'PWM-PI1-3' then 'PI1-3 A-GÓRA'
	when left(A.pon_nrdok,9) = 'PWM-PI2-1' then 'PI2-1 BA-BG'
	when left(A.pon_nrdok,9) = 'PWM-PI2-2' then 'PI3-6 C-003'
	when left(A.pon_nrdok,9) = 'PWM-PI2-3' then 'PI2-3 B-GÓRA'
	when left(A.pon_nrdok,9) = 'PWM-PI3-1' then 'PI3-1 CA-CD'
	when left(A.pon_nrdok,9) = 'PWM-PI3-2' then 'PI3-2 DA-DH'
	when left(A.pon_nrdok,9) = 'PWM-PI3-3' then 'PI3-3 DI-DP'
	when left(A.pon_nrdok,9) = 'PWM-PI3-4' then 'PI3-4 DR-DZ'
	when left(A.pon_nrdok,9) = 'PWM-PI3-5' then 'PI3-5 C-GÓRA'
	when left(A.pon_nrdok,9) = 'PWM-GA1-1' then 'GA1-1 AA-AO'
	when left(A.pon_nrdok,9) = 'PWM-GA1-3' then 'GA1-3 A-GÓRA'
	when left(A.pon_nrdok,9) = 'PWM-GA2-1' then 'GA2-1 BA-BG'
	when left(A.pon_nrdok,9) = 'PWM-GA2-2' then 'GA3-6 C-003'
	when left(A.pon_nrdok,9) = 'PWM-GA2-3' then 'GA2-3 B-GÓRA'
	when left(A.pon_nrdok,9) = 'PWM-GA3-1' then 'GA3-1 CA-CD'
	when left(A.pon_nrdok,9) = 'PWM-GA3-2' then 'GA3-2 DA-DH'
	when left(A.pon_nrdok,9) = 'PWM-GA3-3' then 'GA3-3 DI-DP'
	when left(A.pon_nrdok,9) = 'PWM-GA3-4' then 'GA3-4 DR-DZ'
	when left(A.pon_nrdok,9) = 'PWM-GA3-5' then 'GA3-5 C-GÓRA'
	else left(A.pon_nrdok,9)
end AS STREFA

,isnull((
select top 1
LEFT(LTRIM(DATEADD(second, b.pon_czasutw, CAST('00:00:00' AS TIME))),5)
+ ' / '
	+ isnull((select top 1
	LEFT(LTRIM(DATEADD(second, prn_czaszat, CAST('00:00:00' AS TIME))),5)
	from [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecrnag] with(nolock)
	where 
	prn_pontyp = A.pon_typ	and 
	prn_stan = 2
	and prn_datazat = DATEDIFF(DD,'19000101',getdate()) order by prn_czaszat desc),'')
FROM [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecnag] B with(nolock)
where b.pon_status in (1,2) and b.pon_zrdid<>0
and B.pon_typ = A.pon_typ
and b.pon_datautw = DATEDIFF(DD,'19000101',getdate())
order by b.pon_datautw + b.pon_czasutw
), 'Zaległy') as [Czas zlec]


,convert(varchar,isnull(sum(CASE WHEN A.pon_status=1 THEN 1 ELSE 0 END),0)) + '/' + convert(varchar,isnull(sum(CASE WHEN pon_status=1 AND RE.REAL_DOK IS NOT NULL THEN 1 ELSE 0 END),0))+ '(' + convert(varchar,isnull(sum(CASE WHEN WRE.WREAL_DOK IS NOT NULL THEN 1 ELSE 0 END),0))+ ')'  AS [IL DOK./dop.(R)]

,convert(varchar,isnull(sum(CASE WHEN A.PON_TRASA in (5,25,24,22) AND pon_status=1 THEN 1 ELSE 0 END),0)) + '/' + convert(varchar,isnull(sum(CASE WHEN A.PON_TRASA in (5,25,24,22) AND pon_status=1 AND RE.REAL_DOK IS NOT NULL THEN 1 ELSE 0 END),0))+ '(' + convert(varchar,isnull(sum(CASE WHEN A.PON_TRASA in (5,25,24,22) AND WRE.WREAL_DOK IS NOT NULL THEN 1 ELSE 0 END),0))+ ')' AS  [DPD/dop.(R)]
,convert(varchar,isnull(sum(CASE WHEN A.PON_TRASA = 21 AND pon_status=1 THEN 1 ELSE 0 END),0))  + '/' + convert(varchar,isnull(sum(CASE WHEN A.PON_TRASA = 21 AND pon_status=1 AND RE.REAL_DOK IS NOT NULL THEN 1 ELSE 0 END),0))+ '(' + convert(varchar,isnull(sum(CASE WHEN A.PON_TRASA =21 AND WRE.WREAL_DOK IS NOT NULL THEN 1 ELSE 0 END),0))+ ')' AS [FEDEX/dop.(R)]
,convert(varchar,isnull(sum(CASE WHEN A.PON_TRASA in (6,19) AND pon_status=1 THEN 1 ELSE 0 END),0)) + '/' + convert(varchar,isnull(sum(CASE WHEN A.PON_TRASA in (6,19) AND pon_status=1 AND RE.REAL_DOK IS NOT NULL THEN 1 ELSE 0 END),0))+ '(' + convert(varchar,isnull(sum(CASE WHEN A.PON_TRASA in (6,19) AND WRE.WREAL_DOK IS NOT NULL THEN 1 ELSE 0 END),0))+ ')'  AS [GLS/dop.(R)]
,convert(varchar,isnull(sum(CASE WHEN a.pon_trasa = 23 AND pon_status=1 THEN 1 ELSE 0 END),0)) + '/' + convert(varchar,isnull(sum(CASE WHEN a.pon_trasa = 23 AND pon_status=1 AND RE.REAL_DOK IS NOT NULL THEN 1 ELSE 0 END),0))+ '(' + convert(varchar,isnull(sum(CASE WHEN A.PON_TRASA = 23 AND WRE.WREAL_DOK IS NOT NULL THEN 1 ELSE 0 END),0))+ ')' AS  [DPD_R/dop.(R)]
,convert(varchar,isnull(sum(CASE WHEN (A.PON_TRASA NOT IN (5,6,23,21,19,25,24,22) OR A.PON_TRASA IS NULL) AND pon_status=1 THEN 1 ELSE 0 END),0)) + '/' + convert(varchar,isnull(sum(CASE WHEN (A.PON_TRASA NOT IN (5,6,23,21,19,25,24,22) OR A.PON_TRASA IS NULL) AND pon_status=1 AND RE.REAL_DOK IS NOT NULL THEN 1 ELSE 0 END),0))+ '(' + convert(varchar,isnull(sum(CASE WHEN (A.PON_TRASA NOT IN (5,6,23,21,19,25,24,22) OR A.PON_TRASA IS NULL) AND WRE.WREAL_DOK IS NOT NULL THEN 1 ELSE 0 END),0))+ ')' AS [INNE/dop.(R)]
,CAST(ISNULL(STUFF((
                    SELECT DISTINCT ','+ operator
                    FROM (
                    SELECT ope_user  + case when (select max(pre_tstamp) from [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecrelem] where pre_id = prn_id) < DATEDIFF(SECOND, '1990-01-01', @data2) then '!' else '' end as operator
                    FROM [ExpertWMS_Gaska_Produkcja].[dbo].[wms_operatorzy] WITH (NOLOCK)
                    JOIN [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecrnag] WITH (NOLOCK) ON prn_pontyp = a.pon_typ 
					AND ((prn_opeid = ope_id AND prn_stan = 1)        
                    OR 
                    (prn_opeid = ope_id AND prn_datazat = DATEDIFF(DD, '19000101', GETDATE()) AND DATEADD(SECOND, prn_czaszat, CAST('00:00:00' AS TIME))  
                     BETWEEN CONVERT(TIME, DATEADD(SECOND, -15, GETDATE())) AND CONVERT(TIME, DATEADD(SECOND, 0, GETDATE())))
                    )
                    UNION
                    SELECT ope_user + case when opa_tstamp < DATEDIFF(SECOND, '1990-01-01', @data2) then '!' else '' end as operator
                    FROM [ExpertWMS_Gaska_Produkcja].[dbo].[wms_operatorzy] WITH (NOLOCK)
                    LEFT JOIN [ExpertWMS_Gaska_Produkcja].dbo.wms_operatorzyatrybuty WITH (NOLOCK) ON ope_id = opa_opeid AND opa_atrid = 6
                    LEFT JOIN [ExpertWMS_Gaska_Produkcja].dbo.wms_magadresywirt WITH (NOLOCK) ON opa_wartosc = mgw_id 
                    WHERE a.pon_typ = [ExpertWMS_Gaska_Produkcja].dbo.wms_d_dtrefa_doktyp(mgw_kod)) AS CombinedResults
                    FOR XML PATH('')), 1, 1, ''), '') AS VARCHAR(100)) as [Operator]

										
FROM [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecnag] a with(nolock)
	LEFT JOIN (select DISTINCT(XX.pon_nrdokobcy) AS REAL_DOK from [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecnag] XX with(nolock) WHERE XX.pon_status<>1 AND XX.pon_zrdid<>0) RE ON  RE.REAL_DOK=A.pon_nrdokobcy
	LEFT JOIN (select DISTINCT(XXX.pon_id) AS WREAL_DOK
					from [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecnag] XXX with(nolock) 
					join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecrnag] with (nolock) on prn_pontyp=xxx.pon_typ and prn_ponid=xxx.pon_id
				WHERE (XXX.pon_status=2 or prn_stan=1) AND XXX.pon_zrdid<>0
		) WRE ON  WRE.WREAL_DOK=A.pon_id
	join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_exp_polecpowiaz] with (nolock) on epp_typ=pon_typ and epp_numer=pon_id

where pon_status IN (1,2) and pon_zrdid<>0 and left(A.pon_nrdok,9) not like 'PAK-REG%' and left(A.pon_nrdok,9) not like 'PAK-OUT%' and pon_zrdtyp in (1130001, 2120001)

GROUP BY left(A.pon_nrdok,9), a.pon_typ--, pon_datautw
order by 

isnull(sum(CASE WHEN A.PON_TRASA in (5,25,24,22) AND RE.REAL_DOK IS NOT NULL THEN 1 ELSE 0 END),0) DESC, 
isnull(sum(CASE WHEN A.PON_TRASA in (5,25,24,22) THEN 1 ELSE 0 END),0) DESC, 
isnull(sum(CASE WHEN a.pon_trasa = 21 AND RE.REAL_DOK IS NOT NULL THEN 1 ELSE 0 END),0) DESC,
isnull(sum(CASE WHEN a.pon_trasa = 21 THEN 1 ELSE 0 END),0) DESC,
isnull(sum(CASE WHEN A.PON_TRASA in(6,19) AND RE.REAL_DOK IS NOT NULL THEN 1 ELSE 0 END),0) DESC,
isnull(sum(CASE WHEN A.PON_TRASA in(6,19)  THEN 1 ELSE 0 END),0) DESC,
isnull(sum(CASE WHEN a.pon_trasa = 23 AND RE.REAL_DOK IS NOT NULL THEN 1 ELSE 0 END),0) DESC, 
isnull(sum(CASE WHEN a.pon_trasa = 23 THEN 1 ELSE 0 END),0) DESC, 
[IL DOK./dop.(R)] DESC,
[Czas zlec],
[STREFA]
END
