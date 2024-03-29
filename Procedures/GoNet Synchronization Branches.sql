USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [dbo].[GoNet_Synchronizacja_Filie]    Script Date: 24.10.2023 11:03:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[GoNet_Synchronizacja_Filie] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
WITH
Obrot AS (select KnA_GIDNumer as [Obr_KnAID]
,isnull(sum(case when TrN_TrNRok = YEAR(getdate()) and TrN_Data2 <= DATEDIFF(DD,'18001228', getdate()) then tre_ksiegowanetto else null end),0) as [Obr_TenRok]
,isnull(sum(case when TrN_TrNRok = YEAR(DATEADD(YEAR, -1, getdate())) and TrN_Data2 <= DATEDIFF(DD,'18001228', DATEADD(year, -1, getdate())) then tre_ksiegowanetto else null end),0) as [Obr_RokTemu]
from cdn.KntAdresy with(nolock)
join cdn.TraNag with(nolock) on KnA_GIDNumer=TrN_AdWNumer
join cdn.traelem with(nolock) on TrN_GIDNumer=TrE_GIDNumer
where TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-760)
group by KnA_GIDNumer)

,ObrotKategorieRynkowe AS (select KnA_GIDNumer as [OKR_KnAID] 
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
from cdn.KntAdresy with(nolock)
join cdn.TraNag with(nolock) on KnA_GIDNumer=TrN_AdWNumer
join cdn.traelem with(nolock) on TrN_GIDNumer=TrE_GIDNumer
join cdn.TwrKarty with(nolock) on Twr_GIDNumer=TrE_TwrNumer
join cdn.Slowniki with(nolock) on SLW_ID=Twr_Notowania
where TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365)
group by KnA_GIDNumer)

,PrzeterminowePlatnosci AS (select KnA_GIDNumer as [Plat_KnAID]
,sum(TrP_Pozostaje) as [Plat_Suma]
from cdn.KntAdresy with(nolock)
join cdn.TraNag with(nolock) on KnA_GIDNumer=TrN_AdWNumer
join cdn.TraPlat with(nolock) on TrN_GIDTyp=TrP_GIDTyp AND TrN_GIDNumer=TrP_GIDNumer
where KnA_GIDNumer=TrN_KntNumer and TrN_KntTyp=32
and TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) 
and TrN_GIDTyp in (2033, 2037, 2034)
and TrP_Pozostaje > 0
and TrP_Rozliczona = 0
and TrN_FormaNazwa like '%przelew%'
group by KnA_GIDNumer
)

,Reklamacje AS (select distinct RLN_KnANumer as [Rekl_KnAID]
,count(RLE_Status) as [Rekl_Suma]
,case when RLE_Status = 0 then 'Rozpatrywana' 
						when RLE_Status = 1 then 'Uznana' 
						when RLE_Status = 2 then 'Odrzucona' 
						when RLE_Status = 4 then 'Zrealizowana'
						else convert(varchar(25),RLE_Status) end as [Rekl_Status]
from cdn.ReklNag 
join cdn.reklelem on RLN_Id=RLE_RLNId
where RLN_DataWyst >  DATEDIFF(DD,'18001228',GETDATE()-365)
group by RLE_Status, RLN_KnANumer)

select 
Knt_GIDNumer as [centrala_id]
,Knt_Akronim as [centrala_akronim]
,KnA_GIDNumer as [filia_id]
,KnA_Akronim as [filia_akronim]
,isnull(KnA_Miasto,'') as [miasto]
,isnull(KnA_Ulica,'') as [ulica]
,isnull(KnA_KodP,'') as [kodp]
,isnull(KnA_Kraj,'') as [kraj]
,isnull(KnA_EMail,'') as [email]
,isnull(KnA_Telefon1,'') as [telefon]
,isnull(KnA_Nip,'') as [nip]
,isnull(Prc_Imie1,'') as [prowadzacy_imie]
,isnull(Prc_Nazwisko,'') as [prowadzacy_nazwisko]

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
,isnull(co.Atr_Wartosc, 0) as [czy_odwiedzac]
,isnull(piw.Atr_Wartosc,'') as [potrzebna_ilosc_wizyt]


from cdn.KntAdresy sa
join cdn.KntKarty on Knt_GIDNumer=KnA_KntNumer and KnA_KntTyp=32
join cdn.Rejony on REJ_Id=KnA_RegionCRM
join cdn.KntOpiekun on REJ_Id=KtO_KntNumer
join cdn.PrcKarty on Prc_GIDNumer=KtO_PrcNumer	
left join Obrot on KnA_GIDNumer = Obr_KnAID
left join ObrotKategorieRynkowe on KnA_GIDNumer = OKR_KnAID
left join PrzeterminowePlatnosci on KnA_GIDNumer = Plat_KnAID
left join cdn.Atrybuty rk with(nolock) on KnA_GIDNumer=rk.Atr_ObiNumer and rk.atr_atkid = 453
left join cdn.Atrybuty rko with(nolock) on KnA_GIDNumer=rko.Atr_ObiNumer and rko.atr_atkid = 454
left join cdn.Atrybuty zdk with(nolock) on KnA_GIDNumer=zdk.Atr_ObiNumer and zdk.atr_atkid = 455
left join cdn.Atrybuty zdko with(nolock) on KnA_GIDNumer=zdko.Atr_ObiNumer and zdko.atr_atkid = 456
left join cdn.Atrybuty pu with(nolock) on KnA_GIDNumer=pu.Atr_ObiNumer and pu.atr_atkid = 188
left join cdn.Atrybuty puo with(nolock) on KnA_GIDNumer=puo.Atr_ObiNumer and puo.atr_atkid = 189
left join cdn.Atrybuty ppo with(nolock) on KnA_GIDNumer=ppo.Atr_ObiNumer and ppo.atr_atkid = 187
left join cdn.Atrybuty co with(nolock) on KnA_GIDNumer=co.Atr_ObiNumer and co.atr_atkid = 470
left join cdn.Atrybuty piw with(nolock) on KnA_GIDNumer=piw.Atr_ObiNumer and piw.atr_atkid = 459


where KnA_AdresBank = 1 and KnA_DataArc = '' and KtO_PrcNumer in (1425,1426,1491,382)
END
