USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [dbo].[StrefyRealizacjaZlecenia]    Script Date: 2024.06.18 10:34:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[StrefyRealizacjaZlecenia] 

AS
BEGIN

	SET NOCOUNT ON;

declare @data int = dbo.wms_data2int(getdate())

;WITH Paczki AS (
    SELECT 
		isnull(count(distinct pon_zrdid),0) as [Razem],
		convert(int,ceiling(isnull(sum(a.pon_wagabrutto),0))) as [RazemWaga],
        isnull(count(distinct CASE WHEN A.PON_TRASA in (5,25,24,22) THEN pon_zrdid ELSE null END),0) as [DPD],
        convert(int,ceiling(isnull(sum(CASE WHEN A.PON_TRASA in (5,25,24,22) THEN a.pon_wagabrutto ELSE 0 END),0)))  as [DPDWaga],
        isnull(count(distinct CASE WHEN A.PON_TRASA = 21 THEN pon_zrdid ELSE null END),0) AS [FEDEX],
        convert(int,ceiling(isnull(sum(CASE WHEN A.PON_TRASA = 21 THEN a.pon_wagabrutto ELSE 0 END),0))) AS [FEDEXWaga],
        isnull(count(distinct CASE WHEN A.PON_TRASA in (6,19) THEN pon_zrdid ELSE null END),0) AS [GLS],
        convert(int,ceiling(isnull(sum(CASE WHEN A.PON_TRASA in (6,19) THEN a.pon_wagabrutto ELSE 0 END),0))) AS [GLSWaga],
        isnull(count(distinct CASE WHEN A.PON_TRASA = 23 THEN pon_zrdid ELSE null END),0) AS [DPD_R],
        convert(int,ceiling(isnull(sum(CASE WHEN A.PON_TRASA = 23 THEN a.pon_wagabrutto ELSE 0 END),0))) AS [DPD_RWaga],
		--isnull(sum(CASE WHEN pon_sposobdostawy = 2 THEN 1 ELSE 0 END),0) AS [OW],
		--convert(decimal(15,2), isnull(sum(CASE WHEN pon_sposobdostawy = 2 THEN a.pon_wagabrutto ELSE 0 END),0)) AS [OWWaga],
		isnull(count(distinct CASE WHEN (A.PON_TRASA NOT IN (5,6,23,21,19,25,24,22) OR A.PON_TRASA IS NULL) THEN pon_zrdid ELSE null END),0) AS [INNE],
		convert(int,ceiling(isnull(sum(CASE WHEN (A.PON_TRASA NOT IN (5,6,23,21,19,25,24,22) OR A.PON_TRASA IS NULL) THEN a.pon_wagabrutto ELSE 0 END),0))) AS [INNEWaga]
    FROM [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecnag] a with(nolock)
    LEFT JOIN (select DISTINCT(XX.pon_nrdokobcy) AS REAL_DOK from [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecnag] XX with(nolock) WHERE XX.pon_status<>1 AND XX.pon_zrdid<>0) RE ON RE.REAL_DOK = A.pon_nrdokobcy
    LEFT JOIN (select DISTINCT(XXX.pon_id) AS WREAL_DOK
               from [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecnag] XXX with(nolock) 
               join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecrnag] with (nolock) on prn_pontyp = XXX.pon_typ and prn_ponid = XXX.pon_id
               WHERE (XXX.pon_status = 2 or prn_stan = 1) AND XXX.pon_zrdid<>0
              ) WRE ON WRE.WREAL_DOK = A.pon_id
    JOIN [ExpertWMS_Gaska_Produkcja].[dbo].[wms_exp_polecpowiaz] with (nolock) on epp_typ = pon_typ and epp_numer = pon_id
    WHERE pon_status IN (1,2) and pon_zrdid <> 0 and left(A.pon_nrdok,9) not like 'PAK-REG%' and left(A.pon_nrdok,9) not like 'PAK-OUT%' and pon_zrdtyp in (1130001, 2120001)
    GROUP BY pon_zrdid
    HAVING sum(a.pon_wagabrutto) <= 120
)
,Palety AS (
    SELECT 
		isnull(count(distinct pon_zrdid),0) as [Razem],
		convert(int,ceiling(isnull(sum(a.pon_wagabrutto),0))) as [RazemWaga],
        isnull(count(distinct CASE WHEN A.PON_TRASA in (5,25,24,22) THEN pon_zrdid ELSE null END),0) as [DPD],
        convert(int,ceiling(isnull(sum(CASE WHEN A.PON_TRASA in (5,25,24,22) THEN a.pon_wagabrutto ELSE 0 END),0))) as [DPDWaga],
        isnull(count(distinct CASE WHEN A.PON_TRASA = 21 THEN pon_zrdid ELSE null END),0) AS [FEDEX],
        convert(int,ceiling(isnull(sum(CASE WHEN A.PON_TRASA = 21 THEN a.pon_wagabrutto ELSE 0 END),0))) AS [FEDEXWaga],
        isnull(count(distinct CASE WHEN A.PON_TRASA in (6,19) THEN pon_zrdid ELSE null END),0) AS [GLS],
        convert(int,ceiling(isnull(sum(CASE WHEN A.PON_TRASA in (6,19) THEN a.pon_wagabrutto ELSE 0 END),0))) AS [GLSWaga],
        isnull(count(distinct CASE WHEN A.PON_TRASA = 23 THEN pon_zrdid ELSE null END),0) AS [DPD_R],
        convert(int,ceiling(isnull(sum(CASE WHEN A.PON_TRASA = 23 THEN a.pon_wagabrutto ELSE 0 END),0))) AS [DPD_RWaga],
		--isnull(sum(CASE WHEN pon_sposobdostawy = 2 THEN 1 ELSE 0 END),0) AS [OW],
		--convert(decimal(15,2), isnull(sum(CASE WHEN pon_sposobdostawy = 2 THEN a.pon_wagabrutto ELSE 0 END),0)) AS [OWWaga],
		isnull(count(distinct CASE WHEN (A.PON_TRASA NOT IN (5,6,23,21,19,25,24,22) OR A.PON_TRASA IS NULL) THEN pon_zrdid ELSE null END),0) AS [INNE],
		convert(int,ceiling(isnull(sum(CASE WHEN (A.PON_TRASA NOT IN (5,6,23,21,19,25,24,22) OR A.PON_TRASA IS NULL) THEN a.pon_wagabrutto ELSE 0 END),0))) AS [INNEWaga]
    FROM [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecnag] a with(nolock)
    LEFT JOIN (select DISTINCT(XX.pon_nrdokobcy) AS REAL_DOK from [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecnag] XX with(nolock) WHERE XX.pon_status<>1 AND XX.pon_zrdid<>0) RE ON RE.REAL_DOK = A.pon_nrdokobcy
    LEFT JOIN (select DISTINCT(XXX.pon_id) AS WREAL_DOK
               from [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecnag] XXX with(nolock) 
               join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecrnag] with (nolock) on prn_pontyp = XXX.pon_typ and prn_ponid = XXX.pon_id
               WHERE (XXX.pon_status = 2 or prn_stan = 1) AND XXX.pon_zrdid<>0
              ) WRE ON WRE.WREAL_DOK = A.pon_id
    JOIN [ExpertWMS_Gaska_Produkcja].[dbo].[wms_exp_polecpowiaz] with (nolock) on epp_typ = pon_typ and epp_numer = pon_id
    WHERE pon_status IN (1,2) and pon_zrdid <> 0 and left(A.pon_nrdok,9) not like 'PAK-REG%' and left(A.pon_nrdok,9) not like 'PAK-OUT%' and pon_zrdtyp in (1130001, 2120001)
    GROUP BY pon_zrdid
    HAVING sum(a.pon_wagabrutto) > 120
)

Select 
'PACZKI' as [Typ]
,convert(varchar, sum(Razem)) + '/' + convert(varchar, sum(RazemWaga)) + ' kg' as [Razem]
,convert(varchar, sum(DPD)) + '/' + convert(varchar, sum(DPDWaga)) + ' kg' as [DPD]
,convert(varchar, sum(FEDEX)) + '/' + convert(varchar, sum(FEDEXWaga)) + ' kg' as [FEDEX]
,convert(varchar, sum(GLS)) + '/' + convert(varchar, sum(GLSWaga)) + ' kg' as [GLS]
,convert(varchar, sum(DPD_R)) + '/' + convert(varchar, sum(DPD_RWaga)) + ' kg' as [DPD_R]
--,convert(varchar, sum(OW)) + '/' + convert(varchar, sum(OWWaga)) + ' kg' as [OW] Nie działa
,convert(varchar, sum(INNE)) + '/' + convert(varchar, sum(INNEWaga)) + ' kg' as [INNE]
from Paczki

UNION ALL

Select 
'PALETY' as [Typ]
,convert(varchar, sum(Razem)) + '/' + convert(varchar, sum(RazemWaga)) + ' kg' as [Razem]
,convert(varchar, sum(DPD)) + '/' + convert(varchar, sum(DPDWaga)) + ' kg' as [DPD]
,convert(varchar, sum(FEDEX)) + '/' + convert(varchar, sum(FEDEXWaga)) + ' kg' as [FEDEX]
,convert(varchar, sum(GLS)) + '/' + convert(varchar, sum(GLSWaga)) + ' kg' as [GLS]
,convert(varchar, sum(DPD_R)) + '/' + convert(varchar, sum(DPD_RWaga)) + ' kg' as [DPD_R]
--,convert(varchar, sum(OW)) + '/' + convert(varchar, sum(OWWaga)) + ' kg' as [OW] Nie działa
,convert(varchar, sum(INNE)) + '/' + convert(varchar, sum(INNEWaga)) + ' kg' as [INNE]
from Palety

END
