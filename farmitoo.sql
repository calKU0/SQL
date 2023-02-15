Select
'G¹ska sp. z o.o.' as [partner],
case when Twr_PrdNumer = 19468 then 'JAG-PREMIUM' else 'JAG' end as [brand],
'Aftermarket' as [sparepart_type],
Twr_Kod as [product_sku],
Twr_Nazwa as [title],

--Grupuje klase oraz wartosci atrubutów jakie posiada produkt. Warunek taki, ¿e grupa klas atrybutów, to wymiary towaru
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

cast((twC_wartosc/4.7) as decimal(10,2)) as [cost],
cast((twC_wartosc*1.35)/4.7 as decimal(10,2)) as [price],
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


--Outputuje to co jest pomiedzy 1-szym a 2-gim '/' w pe³nej nazwie grupy czyli marke np. 'CLASS','URSUS' itp.
SUBSTRING(CDN.TwrGrupaPelnaNazwa(Twg_GRONumer), CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer)) + 1, CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer), CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer)) + 1) - CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer)) - 1) AS [model_brand_name],


--ID Modeli (to co jest po ostatnim '/' w pe³nej nazwie grupy)
REVERSE(SUBSTRING(REVERSE(CDN.TwrGrupaPelnaNazwa(Twg_GRONumer)), 0, CHARINDEX('/', REVERSE(CDN.TwrGrupaPelnaNazwa(Twg_GRONumer))))) as [model_ID]


from cdn.TwrKarty SS with(nolock)
join cdn.TwrCeny with(nolock) on Twr_GIDNumer=TwC_TwrNumer
join cdn.Atrybuty with(nolock) on Twr_GIDNumer=Atr_ObiNumer and Atr_OBITyp=16 and Atr_OBILp = 0
join cdn.AtrybutyKlasy with(nolock) on  AtK_ID=Atr_AtkId
--left join cdn.TwrOpisy with(nolock) on Twr_GIDNumer=TwO_TwrNumer
join cdn.TwrAplikacjeOpisy with(nolock) on Twr_GIDTyp=TPO_ObiTyp AND Twr_GIDNumer=TPO_ObiNumer	and Twr_GIDTyp=16
join cdn.twrgrupy KK with(nolock) on Twr_GIDTyp=TwG_GIDTyp AND Twr_GIDNumer=TwG_GIDNumer and TwG_GIDTyp=16

where TwC_TwrLp = 3
and Twr_PrdNumer in (19468,19467)
and TPO_JezykId = 0
and Atr_Wartosc = 'Standardowy'
and TwG_GrONumer BETWEEN 36501 AND 53404
and CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer), CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer)) + 1) > 0
and CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer), CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer), CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer)) + 1) + 1) > 0
and REVERSE(SUBSTRING(REVERSE(CDN.TwrGrupaPelnaNazwa(Twg_GRONumer)), 0, CHARINDEX('/', REVERSE(CDN.TwrGrupaPelnaNazwa(Twg_GRONumer))))) not in ('PRASY KOSTKUJ¥CE','CONSTANT','DOMINANT')
--and AtK_ID in (28,25,29)
and Twr_GIDNumer<=4176










