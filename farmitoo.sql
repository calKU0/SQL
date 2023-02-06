Select distinct TOP 100
partner = 'G¹ska sp. z o.o.',
case when Twr_PrdNumer = 19468 then 'JAG-PREMIUM' else 'JAG' end as [brand],
'Aftermarket' as [sparepart_type],
Twr_Kod as [product_sku],
Twr_Nazwa as [title],
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
--AtK_Nazwa + ': ' + Atr_Wartosc as [description],

--TwO_Opis as [description],
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
TPO_OpisKrotki as [oem_number]



from cdn.TwrKarty SS with(nolock)
join cdn.TwrCeny with(nolock) on Twr_GIDNumer=TwC_TwrNumer
--join cdn.Atrybuty with(nolock) on Twr_GIDNumer=Atr_ObiNumer and Atr_OBITyp=16 and Atr_OBILp = 0
--join cdn.AtrybutyKlasy with(nolock) on  AtK_ID=Atr_AtkId
--left join cdn.TwrOpisy with(nolock) on Twr_GIDNumer=TwO_TwrNumer
join cdn.TwrAplikacjeOpisy with(nolock) on Twr_GIDTyp=TPO_ObiTyp AND Twr_GIDNumer=TPO_ObiNumer	and Twr_GIDTyp=16

where TwC_TwrLp = 3
and Twr_PrdNumer in (19468,19467)
and TPO_JezykId = 0
--and AtK_ID in (28,25,29)







