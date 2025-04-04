USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [dbo].[GaskaTypTowaruPozaNormaWagowoObjetosciowa]    Script Date: 2025-04-01 15:11:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[GaskaTypTowaruPozaNormaWagowoObjetosciowa]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


WITH 
CT1 AS (SELECT 'Standardowy' as [Typ], Twr_GIDNumer as [GIDNumer]
from cdn.TwrKarty with(nolock)
left join cdn.twrjm with(nolock) on Twr_GIDNumer = TwJ_TwrNumer and Twr_JMPulpitKnt = TwJ_TwrLp
where case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_Waga else Twr_Waga end BETWEEN 0.000001 AND 12.00 AND case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then case when TwJ_WymJm = 'm' then TwJ_ObjetoscL * 1000000 when TwJ_WymJm = 'mm' then TwJ_ObjetoscL / 1000 else twj_objetoscL end else case when Twr_WymJm = 'm' then twr_objetoscL * 1000000 when Twr_WymJm = 'mm' then twr_objetoscL / 1000 else twr_objetoscL end end between 0.000001 and 500000)

,CT2 AS (SELECT 'Delikatny' as [Typ], Twr_GIDNumer as [GIDNumer]
from cdn.TwrKarty with(nolock)
left join cdn.twrjm with(nolock) on Twr_GIDNumer = TwJ_TwrNumer and Twr_JMPulpitKnt = TwJ_TwrLp
where case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_Waga else Twr_Waga end BETWEEN 0.0000001 AND 6.00 AND case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then case when TwJ_WymJm = 'm' then TwJ_ObjetoscL * 1000000 when TwJ_WymJm = 'mm' then TwJ_ObjetoscL / 1000 else twj_objetoscL end else case when Twr_WymJm = 'm' then twr_objetoscL * 1000000 when Twr_WymJm = 'mm' then twr_objetoscL / 1000 else twr_objetoscL end end between 0.000001 and 500000)

,CT3 AS (SELECT 'Gabarytowy' as [Typ], Twr_GIDNumer as [GIDNumer]
from cdn.TwrKarty with(nolock)
left join cdn.twrjm with(nolock) on Twr_GIDNumer = TwJ_TwrNumer and Twr_JMPulpitKnt = TwJ_TwrLp
where case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_Waga else Twr_Waga end BETWEEN 6.00 AND 120.00 AND case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then case when TwJ_WymJm = 'm' then TwJ_ObjetoscL * 1000000 when TwJ_WymJm = 'mm' then TwJ_ObjetoscL / 1000 else twj_objetoscL end else case when Twr_WymJm = 'm' then twr_objetoscL * 1000000 when Twr_WymJm = 'mm' then twr_objetoscL / 1000 else twr_objetoscL end end between 15000 and 1500000)

,CT4 AS (SELECT 'Ciężki' as [Typ], Twr_GIDNumer as [GIDNumer]
from cdn.TwrKarty with(nolock)
left join cdn.twrjm with(nolock) on Twr_GIDNumer = TwJ_TwrNumer and Twr_JMPulpitKnt = TwJ_TwrLp
where case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_Waga else Twr_Waga end BETWEEN 12.00 AND 50.00 AND case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then case when TwJ_WymJm = 'm' then TwJ_ObjetoscL * 1000000 when TwJ_WymJm = 'mm' then TwJ_ObjetoscL / 1000 else twj_objetoscL end else case when Twr_WymJm = 'm' then twr_objetoscL * 1000000 when Twr_WymJm = 'mm' then twr_objetoscL / 1000 else twr_objetoscL end end between 2000 and 1500000)

,CT5 AS (SELECT 'Paletowy' as [Typ], Twr_GIDNumer as [GIDNumer]
from cdn.TwrKarty with(nolock)
left join cdn.twrjm with(nolock) on Twr_GIDNumer = TwJ_TwrNumer and Twr_JMPulpitKnt = TwJ_TwrLp
where case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_Waga else Twr_Waga end BETWEEN 30.00 AND 400.00 AND case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then case when TwJ_WymJm = 'm' then TwJ_ObjetoscL * 1000000 when TwJ_WymJm = 'mm' then TwJ_ObjetoscL / 1000 else twj_objetoscL end else case when Twr_WymJm = 'm' then twr_objetoscL * 1000000 when Twr_WymJm = 'mm' then twr_objetoscL / 1000 else twr_objetoscL end end between 40000 and 1500000)

,CT6 AS (SELECT 'Pół-Paletowy' as [Typ], Twr_GIDNumer as [GIDNumer]
FROM cdn.TwrKarty with(nolock)
left join cdn.twrjm with(nolock) on Twr_GIDNumer = TwJ_TwrNumer and Twr_JMPulpitKnt = TwJ_TwrLp
WHERE case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_Waga else Twr_Waga end BETWEEN 30.00 AND 200.00 AND case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then case when TwJ_WymJm = 'm' then TwJ_ObjetoscL * 1000000 when TwJ_WymJm = 'mm' then TwJ_ObjetoscL / 1000 else twj_objetoscL end else case when Twr_WymJm = 'm' then twr_objetoscL * 1000000 when Twr_WymJm = 'mm' then twr_objetoscL / 1000 else twr_objetoscL end end BETWEEN 20000 AND 750000)

,CT7 AS (SELECT 'Długi do 2mb' as [Typ], Twr_GIDNumer as [GIDNumer]
FROM cdn.TwrKarty with(nolock)
left join cdn.twrjm with(nolock) on Twr_GIDNumer = TwJ_TwrNumer and Twr_JMPulpitKnt = TwJ_TwrLp
WHERE case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_Waga else Twr_Waga end BETWEEN 1.00 AND 30.00 AND case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then case when TwJ_WymJm = 'm' then TwJ_ObjetoscL * 1000000 when TwJ_WymJm = 'mm' then TwJ_ObjetoscL / 1000 else twj_objetoscL end else case when Twr_WymJm = 'm' then twr_objetoscL * 1000000 when Twr_WymJm = 'mm' then twr_objetoscL / 1000 else twr_objetoscL end end BETWEEN 1000 AND 245000)

,CT8 AS (SELECT 'Długi do 3mb' as [Typ], Twr_GIDNumer as [GIDNumer]
FROM cdn.TwrKarty with(nolock)
left join cdn.twrjm with(nolock) on Twr_GIDNumer = TwJ_TwrNumer and Twr_JMPulpitKnt = TwJ_TwrLp
WHERE case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_Waga else Twr_Waga end BETWEEN 4.00 AND 30.00 AND case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then case when TwJ_WymJm = 'm' then TwJ_ObjetoscL * 1000000 when TwJ_WymJm = 'mm' then TwJ_ObjetoscL / 1000 else twj_objetoscL end else case when Twr_WymJm = 'm' then twr_objetoscL * 1000000 when Twr_WymJm = 'mm' then twr_objetoscL / 1000 else twr_objetoscL end end BETWEEN 2000 AND 125000)

,CT9 AS (SELECT 'Niestandardowy' as [Typ], Twr_GIDNumer as [GIDNumer]
FROM cdn.TwrKarty with(nolock)
left join cdn.twrjm with(nolock) on Twr_GIDNumer = TwJ_TwrNumer and Twr_JMPulpitKnt = TwJ_TwrLp
WHERE case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_Waga else Twr_Waga end BETWEEN 6.00 AND 400.00 AND case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then case when TwJ_WymJm = 'm' then TwJ_ObjetoscL * 1000000 when TwJ_WymJm = 'mm' then TwJ_ObjetoscL / 1000 else twj_objetoscL end else case when Twr_WymJm = 'm' then twr_objetoscL * 1000000 when Twr_WymJm = 'mm' then twr_objetoscL / 1000 else twr_objetoscL end end BETWEEN 1000 AND 6000000)


select distinct
 Twr_GIDNumer [GID]
,twr_kod [Kod]
,Twr_Nazwa [Nazwa]
,replace(case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_Waga else Twr_Waga end,'.',',') as [Waga (kg)]
,cast(ROUND(case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then case when TwJ_WymJm = 'm' then TwJ_ObjetoscL * 1000000 when TwJ_WymJm = 'mm' then TwJ_ObjetoscL / 1000 else twj_objetoscL end else case when Twr_WymJm = 'm' then twr_objetoscL * 1000000 when Twr_WymJm = 'mm' then twr_objetoscL / 1000 else twr_objetoscL end end,2) as decimal(15,2)) [Objętość (cm3)]
,cast(ROUND(case when Twr_ObjetoscL = 0 or TwJ_ObjetoscL = 0 then 0 when TwJ_PulpitKnt <> 0 and Twr_JMPulpitKnt = 1 then TwJ_Waga/CASE WHEN TwJ_WymJm = 'cm' THEN TwJ_ObjetoscL / 1000000 WHEN TwJ_WymJm = 'mm' THEN TwJ_ObjetoscL / 1000000000 WHEN TwJ_WymJm = 'dm' THEN TwJ_ObjetoscL / 1000 ELSE TwJ_ObjetoscL END else Twr_Waga/CASE WHEN Twr_WymJm = 'cm' THEN Twr_ObjetoscL / 1000000 WHEN Twr_WymJm = 'mm' THEN Twr_ObjetoscL / 1000000000 WHEN Twr_WymJm = 'dm' THEN Twr_ObjetoscL / 1000 ELSE Twr_ObjetoscL END end,2) as decimal(15,2)) as [Gestosc (kg/m3)]
,case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_JmZ else Twr_Jm end as [Jednostka]
,Atr_Wartosc [Typ towaru]
,[Przyczyna Odrzucenia] = case when 
	(Atr_Wartosc = 'Standardowy' AND case when TwJ_PulpitKnt <> 0 and Twr_JMPulpitKnt = 1 then TwJ_Waga else Twr_Waga end not BETWEEN 0.000001 AND 12.00)
     OR (Atr_Wartosc = 'Delikatny' AND case when TwJ_PulpitKnt <> 0 and Twr_JMPulpitKnt = 1 then TwJ_Waga else Twr_Waga end not BETWEEN 0.0000001 AND 6.00)
     OR (Atr_Wartosc = 'Gabarytowy' AND case when TwJ_PulpitKnt <> 0 and Twr_JMPulpitKnt = 1 then TwJ_Waga else Twr_Waga end not BETWEEN 6.00 AND 120.00)
	 OR (Atr_Wartosc = 'Ciężki' AND case when TwJ_PulpitKnt <> 0 and Twr_JMPulpitKnt = 1 then TwJ_Waga else Twr_Waga end not BETWEEN 12.00 AND 50.00)
	 OR (Atr_Wartosc = 'Paletowy' AND case when TwJ_PulpitKnt <> 0 and Twr_JMPulpitKnt = 1 then TwJ_Waga else Twr_Waga end not BETWEEN 30.00 AND 400.00)
	 OR (Atr_Wartosc = 'Pół-paletowy' AND case when TwJ_PulpitKnt <> 0 and Twr_JMPulpitKnt = 1 then TwJ_Waga else Twr_Waga end not BETWEEN 30.00 AND 200.00)
	 OR (Atr_Wartosc = 'Długi do 2 mb' AND case when TwJ_PulpitKnt <> 0 and Twr_JMPulpitKnt = 1 then TwJ_Waga else Twr_Waga end not BETWEEN 1.00 AND 30.00)
	 OR (Atr_Wartosc = 'Długi do 3 mb' AND case when TwJ_PulpitKnt <> 0 and Twr_JMPulpitKnt = 1 then TwJ_Waga else Twr_Waga end not BETWEEN 4.00 AND 30.00)
	 OR (Atr_Wartosc = 'Niestandardowy' AND case when TwJ_PulpitKnt <> 0 and Twr_JMPulpitKnt = 1 then TwJ_Waga else Twr_Waga end not BETWEEN 6.00 AND 400.00)
	 then 'Waga'
	 when case when Twr_ObjetoscL = 0 or TwJ_ObjetoscL = 0 then 0 when TwJ_PulpitKnt <> 0 and Twr_JMPulpitKnt = 1 then TwJ_Waga/CASE WHEN TwJ_WymJm = 'cm' THEN TwJ_ObjetoscL / 1000000 WHEN TwJ_WymJm = 'mm' THEN TwJ_ObjetoscL / 1000000000 WHEN TwJ_WymJm = 'dm' THEN TwJ_ObjetoscL / 1000 ELSE TwJ_ObjetoscL END else Twr_Waga/CASE WHEN Twr_WymJm = 'cm' THEN Twr_ObjetoscL / 1000000 WHEN Twr_WymJm = 'mm' THEN Twr_ObjetoscL / 1000000000 WHEN Twr_WymJm = 'dm' THEN Twr_ObjetoscL / 1000 ELSE Twr_ObjetoscL END end not BETWEEN 40.00 AND 8000.00
	 then 'Gęstość'
	 else 'Objętość'
	 end
,STUFF((
        SELECT ',' + Typ
        FROM (
            SELECT CT1.Typ UNION ALL
            SELECT CT2.Typ UNION ALL
            SELECT CT3.Typ UNION ALL
            SELECT CT4.Typ UNION ALL
            SELECT CT5.Typ UNION ALL
            SELECT CT6.Typ UNION ALL
            SELECT CT7.Typ UNION ALL
            SELECT CT8.Typ UNION ALL
            SELECT CT9.Typ
        ) AS SubQuery
        WHERE Typ IS NOT NULL
        FOR XML PATH('')
    ), 1, 1, '') AS [Sugerowana zmiana]
,STUFF(( select ',' + mga_kod
from cdn.TwrKarty ss 
join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_exp_towaryp] with (nolock) on Twr_GIDNumer=etp_sysid
join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_twrzasobymag] with (nolock) on twa_twrid = etp_twrid
join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_magadresy] with (nolock) on twa_mgaid=mga_id
where ss.Twr_GIDNumer = sa.Twr_GIDNumer
FOR XML PATH('') ), 1, 1, '') as [Lokalizacja]
from cdn.TwrKarty sa with(nolock)
join cdn.Atrybuty with(nolock) on Twr_GIDNumer = Atr_ObiNumer and Atr_OBITyp=16 and Atr_OBILp = 0 and Atr_AtkId = 148 and Atr_Wartosc <> ''--Typ towaru pack
join cdn.TwrZasoby with(nolock) on Twr_GIDNumer=TwZ_TwrNumer
left join cdn.twrjm with(nolock) on Twr_GIDNumer = TwJ_TwrNumer and Twr_JMPulpitKnt = TwJ_TwrLp
left join CT1 on Twr_GIDNumer = CT1.GIDNumer
left join CT2 on Twr_GIDNumer = CT2.GIDNumer
left join CT3 on Twr_GIDNumer = CT3.GIDNumer
left join CT4 on Twr_GIDNumer = CT4.GIDNumer
left join CT5 on Twr_GIDNumer = CT5.GIDNumer
left join CT6 on Twr_GIDNumer = CT6.GIDNumer
left join CT7 on Twr_GIDNumer = CT7.GIDNumer
left join CT8 on Twr_GIDNumer = CT8.GIDNumer
left join CT9 on Twr_GIDNumer = CT9.GIDNumer
WHERE (
	(Atr_Wartosc = 'Standardowy' AND (case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_Waga else Twr_Waga end not BETWEEN 0.000001 AND 12.00 OR case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then case when TwJ_WymJm = 'm' then TwJ_ObjetoscL * 1000000 when TwJ_WymJm = 'mm' then TwJ_ObjetoscL / 1000 else twj_objetoscL end else case when Twr_WymJm = 'm' then twr_objetoscL * 1000000 when Twr_WymJm = 'mm' then twr_objetoscL / 1000 else twr_objetoscL end end not between 0.000001 and 500000))
     OR (Atr_Wartosc = 'Delikatny' AND (case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_Waga else Twr_Waga end not BETWEEN 0.0000001 AND 6.00 OR case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then case when TwJ_WymJm = 'm' then TwJ_ObjetoscL * 1000000 when TwJ_WymJm = 'mm' then TwJ_ObjetoscL / 1000 else twj_objetoscL end else case when Twr_WymJm = 'm' then twr_objetoscL * 1000000 when Twr_WymJm = 'mm' then twr_objetoscL / 1000 else twr_objetoscL end end not between 0.000001 and 500000))
     OR (Atr_Wartosc = 'Gabarytowy' AND (case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_Waga else Twr_Waga end not BETWEEN 6.00 AND 120.00 OR case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then case when TwJ_WymJm = 'm' then TwJ_ObjetoscL * 1000000 when TwJ_WymJm = 'mm' then TwJ_ObjetoscL / 1000 else twj_objetoscL end else case when Twr_WymJm = 'm' then twr_objetoscL * 1000000 when Twr_WymJm = 'mm' then twr_objetoscL / 1000 else twr_objetoscL end end not between 15000 and 1500000))
	 OR (Atr_Wartosc = 'Ciężki' AND (case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_Waga else Twr_Waga end not BETWEEN 12.00 AND 50.00 OR case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then case when TwJ_WymJm = 'm' then TwJ_ObjetoscL * 1000000 when TwJ_WymJm = 'mm' then TwJ_ObjetoscL / 1000 else twj_objetoscL end else case when Twr_WymJm = 'm' then twr_objetoscL * 1000000 when Twr_WymJm = 'mm' then twr_objetoscL / 1000 else twr_objetoscL end end not between 2000 and 1500000))
	 OR (Atr_Wartosc = 'Paletowy' AND (case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_Waga else Twr_Waga end not BETWEEN 30.00 AND 400.00 OR case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then case when TwJ_WymJm = 'm' then TwJ_ObjetoscL * 1000000 when TwJ_WymJm = 'mm' then TwJ_ObjetoscL / 1000 else twj_objetoscL end else case when Twr_WymJm = 'm' then twr_objetoscL * 1000000 when Twr_WymJm = 'mm' then twr_objetoscL / 1000 else twr_objetoscL end end not between 40000 and 1500000))
	 OR (Atr_Wartosc = 'Pół-paletowy' AND (case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_Waga else Twr_Waga end not BETWEEN 30.00 AND 200.00 OR case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then case when TwJ_WymJm = 'm' then TwJ_ObjetoscL * 1000000 when TwJ_WymJm = 'mm' then TwJ_ObjetoscL / 1000 else twj_objetoscL end else case when Twr_WymJm = 'm' then twr_objetoscL * 1000000 when Twr_WymJm = 'mm' then twr_objetoscL / 1000 else twr_objetoscL end end not between 20000 and 750000))
	 OR (Atr_Wartosc = 'Długi do 2 mb' AND (case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_Waga else Twr_Waga end not BETWEEN 1.00 AND 30.00 OR case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then case when TwJ_WymJm = 'm' then TwJ_ObjetoscL * 1000000 when TwJ_WymJm = 'mm' then TwJ_ObjetoscL / 1000 else twj_objetoscL end else case when Twr_WymJm = 'm' then twr_objetoscL * 1000000 when Twr_WymJm = 'mm' then twr_objetoscL / 1000 else twr_objetoscL end end not between 1000 and 245000))
	 OR (Atr_Wartosc = 'Długi do 3 mb' AND (case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_Waga else Twr_Waga end not BETWEEN 4.00 AND 30.00 OR case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then case when TwJ_WymJm = 'm' then TwJ_ObjetoscL * 1000000 when TwJ_WymJm = 'mm' then TwJ_ObjetoscL / 1000 else twj_objetoscL end else case when Twr_WymJm = 'm' then twr_objetoscL * 1000000 when Twr_WymJm = 'mm' then twr_objetoscL / 1000 else twr_objetoscL end end not between 2000 and 125000))
	 OR (Atr_Wartosc = 'Niestandardowy' AND (case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then TwJ_Waga else Twr_Waga end not BETWEEN 6.00 AND 400.00 OR case when TwJ_PulpitKnt = 1 and Twr_JMPulpitKnt <> 0 then case when TwJ_WymJm = 'm' then TwJ_ObjetoscL * 1000000 when TwJ_WymJm = 'mm' then TwJ_ObjetoscL / 1000 else twj_objetoscL end else case when Twr_WymJm = 'm' then twr_objetoscL * 1000000 when Twr_WymJm = 'mm' then twr_objetoscL / 1000 else twr_objetoscL end end not between 1000 and 6000000))
	 OR case when Twr_ObjetoscL = 0 or TwJ_ObjetoscL = 0 then 0 when TwJ_PulpitKnt <> 0 and Twr_JMPulpitKnt = 1 then TwJ_Waga/CASE WHEN TwJ_WymJm = 'cm' THEN TwJ_ObjetoscL / 1000000 WHEN TwJ_WymJm = 'mm' THEN TwJ_ObjetoscL / 1000000000 WHEN TwJ_WymJm = 'dm' THEN TwJ_ObjetoscL / 1000 ELSE TwJ_ObjetoscL END else Twr_Waga/CASE WHEN Twr_WymJm = 'cm' THEN Twr_ObjetoscL / 1000000 WHEN Twr_WymJm = 'mm' THEN Twr_ObjetoscL / 1000000000 WHEN Twr_WymJm = 'dm' THEN Twr_ObjetoscL / 1000 ELSE Twr_ObjetoscL END end not BETWEEN 40.00 AND 8000.00)

AND Twr_Archiwalny = 0 and Twr_Waga <> 0 and Twr_ObjetoscL <> 0  and TwZ_MagNumer = 1 and TwZ_IlMag <> 0

order by Lokalizacja




END
