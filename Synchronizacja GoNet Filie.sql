WITH
Obrot AS (select KnA_GIDNumer as [Obr_KnAID]
,isnull(sum(case when TrN_TrNRok = YEAR(getdate()) and TrN_Data2 <= DATEDIFF(DD,'18001228', getdate()) then tre_ksiegowanetto else null end),0) as [Obr_TenRok]
,isnull(sum(case when TrN_TrNRok = YEAR(DATEADD(YEAR, -1, getdate())) and TrN_Data2 <= DATEDIFF(DD,'18001228', DATEADD(year, -1, getdate())) then tre_ksiegowanetto else null end),0) as [Obr_RokTemu]
from cdn.KntAdresy with(nolock)
join cdn.TraNag with(nolock) on KnA_GIDNumer=TrN_KnANumer AND KnA_GIDTyp=TrN_KnATyp
join cdn.traelem with(nolock) on TrN_GIDNumer=TrE_GIDNumer
where TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-760)
group by KnA_GIDNumer)

,ObrotKategorieRynkowe AS (select KnA_GIDNumer as [OKR_KnAID] 
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Akcesoria i normalia' then tre_ksiegowanetto else null end),0) as [OKR_Akcesoria]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Czêœci do ci¹gników' then tre_ksiegowanetto else null end),0) as [OKR_Ciagniki]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Czêœci kombajnów, sieczkarni i pras' then tre_ksiegowanetto else null end),0) as [OKR_Kombajny]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Filtry i oleje' then tre_ksiegowanetto else null end),0) as [OKR_Filtry]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = '£añcuchy' then tre_ksiegowanetto else null end),0) as [OKR_£añcuchy]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = '£o¿yska' then tre_ksiegowanetto else null end),0) as [OKR_£o¿yska]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Pasy' then tre_ksiegowanetto else null end),0) as [OKR_Pasy]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Sprzêg³a' then tre_ksiegowanetto else null end),0) as [OKR_Sprzêg³a]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Uprawa ziemi' then tre_ksiegowanetto else null end),0) as [OKR_Uprawa]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Wewnêtrzne' then tre_ksiegowanetto else null end),0) as [OKR_Wewnêtrzne]
,isnull(sum(case when TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365) and SLW_WartoscS = 'Wyposa¿. gosp. i warszt.' then tre_ksiegowanetto else null end),0) as [OKR_Gospodarstwo]
from cdn.KntAdresy with(nolock)
join cdn.TraNag with(nolock) on KnA_GIDNumer=TrN_KnANumer AND KnA_GIDTyp=TrN_KnATyp
join cdn.traelem with(nolock) on TrN_GIDNumer=TrE_GIDNumer
join cdn.TwrKarty with(nolock) on Twr_GIDNumer=TrE_TwrNumer
join cdn.Slowniki with(nolock) on SLW_ID=Twr_Notowania
where TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-365)
group by KnA_GIDNumer)

,PrzeterminowePlatnosci AS (select KnA_GIDNumer as [Plat_KnAID]
,sum(TrP_Pozostaje) as [Plat_Suma]
from cdn.KntAdresy with(nolock)
join cdn.TraNag with(nolock) on KnA_GIDNumer=TrN_KnANumer AND KnA_GIDTyp=TrN_KnATyp
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
Knt_GIDNumer as [Centrala ID]
,Knt_Akronim as [Centrala Akronim]
,KnA_GIDNumer as [Filia ID]
,KnA_Akronim as [Filia Akronim]
,KnA_Miasto as [Miasto]
,KnA_Ulica as [Ulica]
,KnA_KodP as [KodP]
,KnA_Kraj as [Kraj]
,KnA_EMail as [Email]
,KnA_Telefon1 as [Telefon]
,KnA_Nip as [NIP]
,Prc_Imie1 + ' ' + Prc_Nazwisko as [Prowadz¹cy]
--Obroty
,isnull(convert(varchar(25),Obr_RokTemu) + ' // ' + convert(varchar(25),Obr_TenRok) + ' (' + convert(varchar(25),CEILING((Obr_TenRok - Obr_RokTemu) / case when Obr_RokTemu = 0 then 0.01 else Obr_RokTemu end * 100)) + '%)','0.00 // 0.00 (0%)') as [Obrót Rok do Roku]
,isnull(OKR_Akcesoria,0) as [Akcesoria i normalia]
,isnull(OKR_Ciagniki,0) as [Czêœci do ci¹gników]
,isnull(OKR_Kombajny,0) as [Czêœci kombajnów, sieczkarni i pras]
,isnull(OKR_Filtry,0) as [Filtry i oleje]
,isnull(OKR_£añcuchy,0) as [£añcuchy]
,isnull(OKR_£o¿yska,0) as [£o¿yska]
,isnull(OKR_Pasy,0) as [Pasy]
,isnull(OKR_Sprzêg³a,0) as [Sprzêg³a]
,isnull(OKR_Uprawa,0) as [Uprawa ziemi]
,isnull(OKR_Wewnêtrzne,0) as [Wewnêtrzne]
,isnull(OKR_Gospodarstwo,0) as [Wyposa¿. gosp. i warszt.]

--Reklamacje
,isnull(STUFF((Select ', ' + Rekl_Status + ' - ' + convert(varchar(25),Rekl_Suma)
from cdn.KntAdresy ss with(nolock) 
left join Reklamacje on Knt_GIDNumer = Rekl_KnAID 
where sa.KnA_GIDNumer = ss.KnA_GIDNumer  
FOR XML PATH('')), 1, 1, ''),'') as [Reklamacje]

--Przeterminowane P³atnoœci
,isnull(Plat_Suma,0) as [Przeterminowane P³atnoœci]

--Atrybuty
,rk.Atr_Wartosc as [Przedstawiciele rodzaj kontrahenta]
,rko.Atr_Wartosc as [Przedstawiciele rodzaj kontrahenta opis]
,zdk.Atr_Wartosc as [Przedstawiciele zakres dzia³alnoœci kontrahenta]
,zdko.Atr_Wartosc as [Przedstawiciele zakres dzia³alnosci kontrahenta opis]
,replace(replace(pu.Atr_Wartosc,'<',''),'>','') as [Promesa uczestnik]
,replace(puo.Atr_Wartosc,'.',',') as [Promesa uzyskany obrot]
,CONVERT(DATE, DATEADD(DAY,convert(int,ppo.Atr_Wartosc),'1800-12-28')) as [Promesa pocz¹tek okresu]
,co.Atr_Wartosc as [Czy odwiedzaæ]
,piw.Atr_Wartosc as [Potrzebna iloœæ wizyt]


from cdn.KntAdresy sa
join cdn.KntKarty on Knt_GIDNumer=KnA_KntNumer and KnA_KntTyp=32
join cdn.Rejony on REJ_Id=KnA_RegionCRM
join cdn.KntOpiekun on REJ_Id=KtO_KntNumer
join cdn.PrcKarty on Prc_GIDNumer=KtO_PrcNumer	
left join Obrot on Knt_GIDNumer = Obr_KnAID
left join ObrotKategorieRynkowe on Knt_GIDNumer = OKR_KnAID
left join PrzeterminowePlatnosci on Knt_GIDNumer = Plat_KnAID
left join cdn.Atrybuty rk with(nolock) on KnA_GIDTyp=rk.Atr_ObiTyp AND KnA_GIDNumer=rk.Atr_ObiNumer and (rk.Atr_OBITyp=864 or rk.Atr_OBITyp=896) and rk.atr_atkid = 453
left join cdn.Atrybuty rko with(nolock) on KnA_GIDTyp=rko.Atr_ObiTyp AND KnA_GIDNumer=rko.Atr_ObiNumer and (rko.Atr_OBITyp=864 or rko.Atr_OBITyp=896)  and rko.atr_atkid = 454
left join cdn.Atrybuty zdk with(nolock) on KnA_GIDTyp=zdk.Atr_ObiTyp AND KnA_GIDNumer=zdk.Atr_ObiNumer  and (zdk.Atr_OBITyp=864 or zdk.Atr_OBITyp=896) and zdk.atr_atkid = 455
left join cdn.Atrybuty zdko with(nolock) on KnA_GIDTyp=zdko.Atr_ObiTyp AND KnA_GIDNumer=zdko.Atr_ObiNumer and (zdko.Atr_OBITyp=864 or zdko.Atr_OBITyp=896)  and zdko.atr_atkid = 456
left join cdn.Atrybuty pu with(nolock) on KnA_GIDTyp=pu.Atr_ObiTyp AND KnA_GIDNumer=pu.Atr_ObiNumer and (pu.Atr_OBITyp=864 or pu.Atr_OBITyp=896) and pu.atr_atkid = 188
left join cdn.Atrybuty puo with(nolock) on KnA_GIDTyp=puo.Atr_ObiTyp AND KnA_GIDNumer=puo.Atr_ObiNumer and (puo.Atr_OBITyp=864 or puo.Atr_OBITyp=896) and puo.atr_atkid = 189
left join cdn.Atrybuty ppo with(nolock) on KnA_GIDTyp=ppo.Atr_ObiTyp AND KnA_GIDNumer=ppo.Atr_ObiNumer and (ppo.Atr_OBITyp=864 or ppo.Atr_OBITyp=896) and ppo.atr_atkid = 187
left join cdn.Atrybuty co with(nolock) on KnA_GIDTyp=co.Atr_ObiTyp AND KnA_GIDNumer=co.Atr_ObiNumer and (co.Atr_OBITyp=864 or co.Atr_OBITyp=896) and ppo.atr_atkid = 470
left join cdn.Atrybuty piw with(nolock) on KnA_GIDTyp=piw.Atr_ObiTyp AND KnA_GIDNumer=piw.Atr_ObiNumer and (piw.Atr_OBITyp=864 or piw.Atr_OBITyp=896) and ppo.atr_atkid = 459


where KtO_Glowny = 0 and KnA_AdresBank = 1 and KnA_DataArc = ''