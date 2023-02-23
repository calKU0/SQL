SELECT

id=1

,mga_kod as [Lokalizacja na magazynie]

,count(distinct Twr_Kod) as [Iloœæ sku]

,cast(isnull(sum(twa_ilosc),0) as int) as [Stan (szt)]

,round(cast(isnull(sum(twj_waganetto*twa_ilosc),0) as decimal(10,3)),3) as [Waga towarów w lokalizacji (kg)]

,cast(mgp_nosnosc as int) as [Maksymalna nosnosc lokalizacji (kg)]

,case when mgp_nosnosc=0 then 100 else round(cast(isnull(sum(twj_waganetto*twa_ilosc),0)/mgp_nosnosc*100 as decimal(9,2)),2)end as [Zajêtoœæ noœnoœci w %]

,round(cast(isnull(sum(case when twj_objetoscjm = 'cm3' then (twj_objetosc/1000000)*twa_ilosc 
        when twj_objetoscjm = 'mm3' then (twj_objetosc/1000000000)*twa_ilosc 
        when twj_objetoscjm = 'dm3' then (twj_objetosc/1000)*twa_ilosc 
        else twj_objetosc*twa_ilosc end),0) as decimal(10,5)),5) as [Objetosc towarow w lokalizacji (m3)]

,mgp_objetosc as [Maksymalna objetosc lokalizacji (m3)]

,case when mgp_objetosc = 0 then 100 else round(cast(isnull(sum(case when twj_objetoscjm = 'cm3' then (twj_objetosc/1000000)*twa_ilosc 
        when twj_objetoscjm = 'mm3' then (twj_objetosc/1000000000)*twa_ilosc 
        when twj_objetoscjm = 'dm3' then (twj_objetosc/1000)*twa_ilosc 
        else twj_objetosc*twa_ilosc end),0) / mgp_objetosc * 100 as decimal(9,2)),2) end as [Zajêtoœæ objêtoœci w %]

FROM [ExpertWMS_Gaska_Produkcja].[dbo].[wms_magadresy] with (nolock)
left join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_twrzasobymag] with (nolock) on twa_mgaid=mga_id
left join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_exp_towaryp] with (nolock) on twa_twrid=etp_twrid
left join CDNXL_GASKA.cdn.TwrKarty with (nolock) on Twr_GIDNumer=etp_sysid
join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_magadresypar] with(nolock) on mgp_id = mga_mgpid
left join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_towaryjm] with(nolock) on twa_twrid = twj_twrid and twj_twrlp=1


where mga_aktywny = 1
and mga_zasoby = 1
group by mga_kod,mgp_nosnosc,mgp_objetosc
order by mga_kod
