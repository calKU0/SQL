USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [dbo].[GoNet_Synchronizacja]    Script Date: 24.10.2023 11:03:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[GoNet_Synchronizacja]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
WITH
Obrot AS (select Knt_GIDNumer as [Obr_KntID]
,isnull(sum(case when TrN_TrNRok = YEAR(getdate()) and TrN_Data2 <= DATEDIFF(DD,'18001228', getdate()) then tre_ksiegowanetto else null end),0) as [Obr_TenRok]
,isnull(sum(case when TrN_TrNRok = YEAR(DATEADD(YEAR, -1, getdate())) and TrN_Data2 <= DATEDIFF(DD,'18001228', DATEADD(year, -1, getdate())) then tre_ksiegowanetto else null end),0) as [Obr_RokTemu]
from cdn.KntKarty with(nolock)
join cdn.TraNag with(nolock) on Knt_GIDNumer=TrN_KntNumer and TrN_KntTyp=32 
join cdn.traelem with(nolock) on TrN_GIDNumer=TrE_GIDNumer
where TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-760)
group by Knt_GIDNumer)


,ObrotKategorieRynkowe AS (select Knt_GIDNumer as [OKR_KntID] 
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Akcesoria i normalia' then tre_ksiegowanetto else null end),0) as [OKR_Akcesoria]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Części do ciągników' then tre_ksiegowanetto else null end),0) as [OKR_Ciagniki]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Części kombajnów, sieczkarni i pras' then tre_ksiegowanetto else null end),0) as [OKR_Kombajny]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Filtry i oleje' then tre_ksiegowanetto else null end),0) as [OKR_Filtry]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Łańcuchy' then tre_ksiegowanetto else null end),0) as [OKR_Łańcuchy]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Łożyska' then tre_ksiegowanetto else null end),0) as [OKR_Łożyska]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Pasy' then tre_ksiegowanetto else null end),0) as [OKR_Pasy]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Sprzęgła' then tre_ksiegowanetto else null end),0) as [OKR_Sprzęgła]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Uprawa ziemi' then tre_ksiegowanetto else null end),0) as [OKR_Uprawa]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Wewnętrzne' then tre_ksiegowanetto else null end),0) as [OKR_Wewnętrzne]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Wyposaż. gosp. i warszt.' then tre_ksiegowanetto else null end),0) as [OKR_Gospodarstwo]
from cdn.KntKarty with(nolock)
join cdn.TraNag with(nolock) on Knt_GIDNumer=TrN_KntNumer and TrN_KntTyp=32 
join cdn.traelem with(nolock) on TrN_GIDNumer=TrE_GIDNumer
join cdn.TwrKarty with(nolock) on Twr_GIDNumer=TrE_TwrNumer
join cdn.Slowniki with(nolock) on SLW_ID=Twr_Notowania
where Knt_Archiwalny = 0 and TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365)
group by Knt_GIDNumer)


,PrzeterminowePlatnosci AS (select Knt_GIDNumer as [Plat_KntID]
,sum(TrP_Pozostaje) as [Plat_Suma]
from cdn.KntKarty with(nolock)
join cdn.TraNag with(nolock) on Knt_GIDNumer=TrN_KntNumer and TrN_KntTyp=32 
join cdn.TraPlat with(nolock) on TrN_GIDTyp=TrP_GIDTyp AND TrN_GIDNumer=TrP_GIDNumer
where Knt_GIDNumer=TrN_KntNumer and TrN_KntTyp=32
and TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) 
and TrN_GIDTyp in (2033, 2037, 2034)
and TrP_Pozostaje > 0
and TrP_Rozliczona = 0
and TrN_FormaNazwa like '%przelew%'
group by Knt_GIDNumer
)

,Logowania AS (select r_lg_kntid as [Log_KntID]
,count(r_lg_id) as [Log_Suma]
from [serwer-sql].[nowe_b2b].[ldd].[rptlogowanie] with(nolock)
where  r_lg_data > getdate() -30
group by r_lg_kntid)


,Klikniecia AS (Select r_twr_kntid as [Klik_KntID],
count(distinct DATEADD(MINUTE, DATEDIFF(MINUTE, 0, r_twr_data), 0)) / 2 as [Klik_Suma]
from [serwer-sql].[nowe_b2b].[ldd].[RptTowary] with (nolock)
where r_twr_data > getdate() -30
group by r_twr_kntid)


,LastLogowanie AS (Select r_lg_kntid as [Lst_KntID], max(r_lg_data) as [Lst_Data]
from [serwer-sql].[nowe_b2b].[ldd].[rptlogowanie] with (nolock)
where r_lg_data > getdate()-180
group by r_lg_kntid)

,Reklamacje AS (select distinct RLN_KntNumer as [Rekl_KntID]
,count(RLE_Status) as [Rekl_Suma]
,case when RLE_Status = 0 then 'Rozpatrywana' 
						when RLE_Status = 1 then 'Uznana' 
						when RLE_Status = 2 then 'Odrzucona' 
						when RLE_Status = 4 then 'Zrealizowana'
						else convert(varchar(25),RLE_Status)end as [Rekl_Status]
from cdn.ReklNag 
join cdn.reklelem on RLN_Id=RLE_RLNId 
where RLN_DataWyst >  DATEDIFF(DD,'18001228',GETDATE()-365)
group by RLE_Status, RLN_KntNumer)


select distinct

Knt_GIDNumer as [centrala_id]
,Knt_Akronim as [centrala_akronim]
,SLW_WartoscS as [rodzaj]

--Obroty
,isnull(convert(varchar(25),Obr_RokTemu) + ' // ' + convert(varchar(25),Obr_TenRok) + ' (' + convert(varchar(25),CEILING((Obr_TenRok - Obr_RokTemu) / case when Obr_RokTemu = 0 then 0.01 else Obr_RokTemu end * 100)) + '%)','0.00 // 0.00 (0%)') as [obrot_rok_do_roku]
,isnull(OKR_Akcesoria,0) as [akcesoria_i_normalia]
,isnull(OKR_Ciagniki,0) as [czesci_do_ciagnikow]
,isnull(OKR_Kombajny,0) as [czesci_komb_sieczkarni_i_pras]
,isnull(OKR_Filtry,0) as [filtry_i_oleje]
,isnull(OKR_Łańcuchy,0) as [lancuchy]
,isnull(OKR_Łożyska,0) as [lozyska]
,isnull(OKR_Pasy,0) as [pasy]
,isnull(OKR_Sprzęgła,0) as [sprzegla]
,isnull(OKR_Uprawa,0) as [uprawa_ziemi]
,isnull(OKR_Wewnętrzne,0) as [wewnetrzne]
,isnull(OKR_Gospodarstwo,0) as [wyposazenie_gosp]

--B2B
,isnull(Log_Suma,0) as [ilosc_logowan_b2b]
,isnull(Klik_Suma,0) as [klikniecia_b2b]
,ISNULL(CONVERT(varchar(19), Lst_Data, 120), '') as [ostatnia_data_logowania_b2b]

--Reklamacje
,isnull(STUFF((Select ',' + Rekl_Status + ' - ' + convert(varchar(25),Rekl_Suma)
from cdn.KntKarty ss with(nolock) 
left join Reklamacje on Knt_GIDNumer = Rekl_KntID 
where sa.Knt_GIDNumer = ss.Knt_GIDNumer  
FOR XML PATH('')), 1, 1, ''),'')
, '' as [reklamacje]

--Przeterminowane Płatności
,isnull(Plat_Suma,0) as [przeterminowane_platnosci]

--Atrybuty
,isnull(rk.Atr_Wartosc,'') as [przedst_rodzaj_kontrahenta]
,isnull(rko.Atr_Wartosc,'') as [przedst_rodzaj_kontrahenta_opis]
,isnull(zdk.Atr_Wartosc,'') as [przedst_zakres_dz_kontr]
,isnull(zdko.Atr_Wartosc,'') as [przedst_zakres_dz_kontr_opis]
,isnull(replace(replace(pu.Atr_Wartosc,'<',''),'>',''),'') as [promesa_uczestnik]
,isnull(puo.Atr_Wartosc,0) as [promesa_uzyskany_obrot]
,ISNULL(ppo.Atr_Wartosc, '') as [promesa_poczatek_okresu]
,isnull(co.Atr_Wartosc,'') as [czy_odwiedzac]
,isnull(piw.Atr_Wartosc,0) as [potrzebna_ilosc_wizyt]

from cdn.KntKarty sa with(nolock)
join cdn.Slowniki on SLW_ID = Knt_Rodzaj
left join Obrot on Knt_GIDNumer = Obr_KntID
left join Logowania on Knt_GIDNumer = Log_KntId
left join Klikniecia on Knt_GIDNumer = Klik_KntID	
left join ObrotKategorieRynkowe on Knt_GIDNumer = OKR_KntID
left join LastLogowanie on Knt_GIDNumer = Lst_KntID
left join PrzeterminowePlatnosci on Knt_GIDNumer = Plat_KntID
left join cdn.Atrybuty rk with(nolock) on Knt_GIDNumer=rk.Atr_ObiNumer and rk.Atr_OBITyp=32 AND rk.Atr_OBISubLp=0 and rk.atr_atkid = 453
left join cdn.Atrybuty rko with(nolock) on Knt_GIDNumer=rko.Atr_ObiNumer and rko.Atr_OBITyp=32 AND rko.Atr_OBISubLp=0 and rko.atr_atkid = 454
left join cdn.Atrybuty zdk with(nolock) on Knt_GIDNumer=zdk.Atr_ObiNumer and zdk.Atr_OBITyp=32 AND zdk.Atr_OBISubLp=0 and zdk.atr_atkid = 455
left join cdn.Atrybuty zdko with(nolock) on Knt_GIDNumer=zdko.Atr_ObiNumer and zdko.Atr_OBITyp=32 AND zdko.Atr_OBISubLp=0 and zdko.atr_atkid = 456
--left join cdn.Atrybuty ia on Knt_GIDNumer=ia.Atr_ObiNumer and ia.Atr_OBITyp=32 AND ia.Atr_OBISubLp=0 and ia.atr_atkid = 457
left join cdn.Atrybuty pu with(nolock) on Knt_GIDNumer=pu.Atr_ObiNumer and pu.Atr_OBITyp=32 AND pu.Atr_OBISubLp=0 and pu.atr_atkid = 188
left join cdn.Atrybuty puo with(nolock) on Knt_GIDNumer=puo.Atr_ObiNumer and puo.Atr_OBITyp=32 AND puo.Atr_OBISubLp=0 and puo.atr_atkid = 189
left join cdn.Atrybuty ppo with(nolock) on Knt_GIDNumer=ppo.Atr_ObiNumer and ppo.Atr_OBITyp=32 AND ppo.Atr_OBISubLp=0 and ppo.atr_atkid = 187
left join cdn.Atrybuty co with(nolock) on Knt_GIDNumer=co.Atr_ObiNumer and co.Atr_OBITyp=32 AND co.Atr_OBISubLp=0 and co.atr_atkid = 470
left join cdn.Atrybuty piw with(nolock) on Knt_GIDNumer=piw.Atr_ObiNumer and piw.Atr_OBITyp=32 AND piw.Atr_OBISubLp=0 and piw.atr_atkid = 459
where Knt_Archiwalny = 0
END
