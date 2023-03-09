Select distinct TOP 100
Twr_kod as [reference],
case when (isnull((select sum(TwZ_IlSpr) from cdn.TwrZasoby with(nolock) join cdn.TwrKarty us with(nolock) on Twr_GIDNumer=TwZ_TwrNumer where TwZ_MagNumer = 1 and us.Twr_Kod = ss.twr_kod),0)
- isnull((select sum(Rez_Ilosc) from cdn.Rezerwacje with(nolock) join cdn.TwrKarty us with(nolock) on Twr_GIDNumer=Rez_TwrNumer where Rez_MagNumer = 1 and us.twr_kod = ss.twr_kod and Rez_Aktywna = 1 and Rez_Typ=1 and Rez_DataWaznosci>DATEDIFF(DD,'18001228',GETDATE())),0)) < 0 then 0 
else cast(isnull((select sum(TwZ_IlSpr) from cdn.TwrZasoby with(nolock) join cdn.TwrKarty us with(nolock) on Twr_GIDNumer=TwZ_TwrNumer where TwZ_MagNumer = 1 and us.Twr_Kod = ss.twr_kod),0)
- isnull((select sum(Rez_Ilosc) from cdn.Rezerwacje with(nolock) join cdn.TwrKarty us with(nolock) on Twr_GIDNumer=Rez_TwrNumer where Rez_MagNumer = 1 and us.twr_kod = ss.twr_kod and Rez_Aktywna = 1 and Rez_Typ=1 and Rez_DataWaznosci>DATEDIFF(DD,'18001228',GETDATE())),0) as decimal (10,0)) end as [quantity],
'sku' as [reference_type]

from cdn.TwrKarty ss with(nolock)
join cdn.Atrybuty with(nolock) on Twr_GIDNumer=Atr_ObiNumer and Atr_OBITyp=16 and Atr_OBILp = 0
join cdn.AtrybutyKlasy with(nolock) on  AtK_ID=Atr_AtkId
left join cdn.twrgrupy KK with(nolock) on Twr_GIDTyp=TwG_GIDTyp AND Twr_GIDNumer=TwG_GIDNumer and TwG_GIDTyp=16

where Twr_PrdNumer in (19468,19467)
and Atr_Wartosc = 'Standardowy'

and TwG_GrONumer BETWEEN 36501 AND 53404
and CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer), CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer)) + 1) > 0
and CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer), CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer), CHARINDEX('/', CDN.TwrGrupaPelnaNazwa(Twg_GRONumer)) + 1) + 1) > 0
and (select top 1 TwG_Nazwa from cdn.twrgrupy ss where ss.twg_gidnumer = kk.twg_gronumer and TwG_GIDTyp = -16) <> 'PRASY KOSTKUJ¥CE'

group by twr_kod,twr_ean


