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
where month(r_lg_data) = month(DATEADD(month,-1,getdate())) and year(r_lg_data) = year(getdate())
group by r_lg_kntid)


,Klikniecia AS (Select r_twr_kntid as [Klik_KntID],
count(distinct DATEADD(MINUTE, DATEDIFF(MINUTE, 0, r_twr_data), 0)) / 2 as [Klik_Suma]
from [serwer-sql].[nowe_b2b].[ldd].[RptTowary] with (nolock)
where month(r_twr_data) = month(DATEADD(month,-1,getdate())) and year(r_twr_data) = year(getdate())
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
						else convert(varchar(25),RLE_Status) end as [Rekl_Status]
from cdn.ReklNag 
join cdn.reklelem on RLN_Id=RLE_RLNId 
where RLN_DataWyst >  DATEDIFF(DD,'18001228',GETDATE()-365)
group by RLE_Status, RLN_KntNumer)


select distinct

Knt_GIDNumer
,Knt_Akronim

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

--B2B
,isnull(Log_Suma,0) as [Iloœæ Logowañ B2B]
,isnull(Klik_Suma,0) as [Klikniêcia]
,Lst_Data as [Ostatnia Data Logowania]

--Reklamacje
,isnull(STUFF((Select ', ' + Rekl_Status + ' - ' + convert(varchar(25),Rekl_Suma)
from cdn.KntKarty ss with(nolock) 
left join Reklamacje on Knt_GIDNumer = Rekl_KntID 
where sa.Knt_GIDNumer = ss.Knt_GIDNumer  
FOR XML PATH('')), 1, 1, ''),'') as [Reklamacje]

--Przeterminowane P³atnoœci
,isnull(Plat_Suma,0) as [Przeterminowane P³atnoœci]

from cdn.KntKarty sa with(nolock)
left join Obrot on Knt_GIDNumer = Obr_KntID
left join Logowania on Knt_GIDNumer = Log_KntId
left join Klikniecia on Knt_GIDNumer = Klik_KntID
left join ObrotKategorieRynkowe on Knt_GIDNumer = OKR_KntID
left join LastLogowanie on Knt_GIDNumer = Lst_KntID
left join PrzeterminowePlatnosci on Knt_GIDNumer = Plat_KntID

where Knt_Archiwalny = 0