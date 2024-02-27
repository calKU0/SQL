Select distinct top 100
Twr_Kod as [product_sku],
Twr_Ean as [ean_code],
STUFF((Select ', ' + 'https://www.b2b.gaska.com.pl/img/produkty/'+convert(varchar,twr_gidnumer) +'/'+convert(varchar,dab_ID)+'_'+DAB_Nazwa+'.jpg'
from cdn.TwrKarty us with(nolock)
join cdn.DaneObiekty with(nolock) on Twr_GIDNumer=DAO_ObiNumer and DAO_ObiTyp=16
join cdn.DaneBinarne with(nolock) on DAB_ID=DAO_DABId
and ss.Twr_GIDNumer = us.Twr_GIDNumer
and DAB_Rozszerzenie = 'jpg'
FOR XML PATH ('')), 1, 1, '') as [links]

from cdn.TwrKarty ss with(nolock)
join cdn.Atrybuty with(nolock) on Twr_GIDNumer=Atr_ObiNumer and Atr_OBITyp=16 and Atr_OBILp = 0
join cdn.AtrybutyKlasy with(nolock) on  AtK_ID=Atr_AtkId
where Twr_PrdNumer in (19468,19467)
and Atr_Wartosc = 'Standardowy'

 