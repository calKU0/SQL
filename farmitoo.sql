Select
'G¹ska sp. z o.o.' as [partner],
case when Twr_PrdNumer = 19468 then 'JAG-PREMIUM' else 'JAG' end as [brand],
'Aftermarket' as [sparepart_type],
Twr_Kod as [product_sku],
Twr_Nazwa as [title],

--Grupuje key oraz value atrubutów jakie posiada produkt. Warunek taki, ¿e key group atrybutów, to wymiary towaru
isnull(STUFF(
                 (SELECT distinct ', ' + AtK_Nazwa + ': ' + Atr_Wartosc from cdn.TwrKarty US with(nolock)
				 join cdn.Atrybuty with(nolock) on Twr_GIDNumer=Atr_ObiNumer and Atr_OBITyp=16 and Atr_OBILp = 0
				 join cdn.AtrybutyKlasy with(nolock) on  AtK_ID=Atr_AtkId
				 join cdn.AtrKompletyLinki with (nolock) on AtK_ID=AKl_AtKId
				 --left join cdn.TwrOpisy with(nolock) on Twr_GIDNumer=TwO_TwrNumer
					where US.Twr_Kod = SS.twr_kod
					and AKl_AKpID = 2

                           FOR XML PATH ('')), 1, 1, ''
               ),'') as [description],

--Pobieranie kursu z tabeli historia waluty
cast((twC_wartosc/(select top 1 (WaE_KursL/WaE_KursM) 
from cdn.WalElem 
where WaE_Symbol='EUR'
and WaE_Lp=4
order by WaE_OpisKursu desc)) as decimal(10,2)) as [cost],

--Pobieranie kursu z tabeli historia waluty i mno¿enie przez x, aby otrzymac cene detaliczn¹ u nich na stronie
cast((twC_wartosc*1.3/(select top 1 (WaE_KursL/WaE_KursM) 
from cdn.WalElem 
where WaE_Symbol='EUR'
and WaE_Lp=4
order by WaE_OpisKursu desc)) as decimal(10,2)) as [price],

guarantee_y = 2,
Twr_Ean as [ean_code],
Twr_Waga as [total_weight_kg],

country_origin = 'Poland',
delivery_de_delay = '2-3 days',
delivery_at_delay = '2-3 days',
delivery_fr_delay = '4-5 days',
delivery_be_delay = '3-4 days',
TPO_OpisKrotki as [oem_number],


--Jeœli towar jest w grupie '6.1 Czêœci wed³ug rodzaju' to outputtuje ów rodzaj, a jeœli nie jest podpiêty do takiej grupy to nic
isnull((Select top 1 REVERSE(SUBSTRING(REVERSE(CDN.TwrGrupaPelnaNazwa(Twg_GRONumer)), 0, CHARINDEX('/', REVERSE(CDN.TwrGrupaPelnaNazwa(Twg_GRONumer)))))
from cdn.twrgrupy KS with(nolock)
where ks.TwG_GIDNumer = kk.TwG_GIDNumer
and CDN.TwrGrupaPelnaNazwa(Twg_GRONumer) like '6.1%'),'') as [category],



--Outputtuje to co jest pomiedzy 2-gim a 3-cim '/' w pe³nej nazwie grupy, czyli do jakiej maszyny/pojazdu s³u¿y np. 'Ci¹gnik', 'Prasa' itp. 
SUBSTRING(CDN.TwrGrupaPelnaNazwa(Twg_GRONumer), CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer), CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer)) + 1) + 1, 
    CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer), CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer), CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer)) + 1) + 1) - 
    CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer), CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer)) + 1) - 1) AS [model_vehicle_code],


--Outputtuje to co jest pomiedzy 1-szym a 2-gim '/' w pe³nej nazwie grupy czyli marke np. 'CLASS','URSUS' itp.
SUBSTRING(CDN.TwrGrupaPelnaNazwa(Twg_GRONumer), CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer)) + 1, CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer), CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer)) + 1) - CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer)) - 1) AS [model_brand_name],


--ID Modeli (to co jest po ostatnim '/' w pe³nej nazwie grupy)
(select top 1 TwG_Nazwa from cdn.twrgrupy ss where ss.twg_gidnumer = kk.twg_gronumer and TwG_GIDTyp = -16) as [model_id]


from cdn.TwrKarty SS with(nolock)
join cdn.TwrCeny with(nolock) on Twr_GIDNumer=TwC_TwrNumer
join cdn.Atrybuty with(nolock) on Twr_GIDNumer=Atr_ObiNumer and Atr_OBITyp=16 and Atr_OBILp = 0
join cdn.AtrybutyKlasy with(nolock) on  AtK_ID=Atr_AtkId
--left join cdn.TwrOpisy with(nolock) on Twr_GIDNumer=TwO_TwrNumer
join cdn.TwrAplikacjeOpisy with(nolock) on Twr_GIDTyp=TPO_ObiTyp AND Twr_GIDNumer=TPO_ObiNumer	and Twr_GIDTyp=16
left join cdn.twrgrupy KK with(nolock) on Twr_GIDTyp=TwG_GIDTyp AND Twr_GIDNumer=TwG_GIDNumer and TwG_GIDTyp=16

where TwC_TwrLp = 3
and Twr_PrdNumer in (19468,19467)
and TPO_JezykId = 0
and Atr_Wartosc = 'Standardowy'
and TwG_GrONumer BETWEEN 36501 AND 53404
and CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer), CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer)) + 1) > 0
and CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer), CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer), CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer)) + 1) + 1) > 0
and (select top 1 TwG_Nazwa from cdn.twrgrupy ss where ss.twg_gidnumer = kk.twg_gronumer and TwG_GIDTyp = -16) <> 'PRASY KOSTKUJ¥CE'
--and AtK_ID in (28,25,29)
and Twr_GIDNumer<=4176