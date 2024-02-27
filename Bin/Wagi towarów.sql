select Replace(twr_waga,'.',',') as [Waga_Std] from cdn.TwrKarty 
left join CDN.Atrybuty with(nolock) on Twr_GIDNumer=Atr_ObiNumer and Atr_OBITyp=16 and Atr_OBILp = 0 and Atr_AtkId = 148 
where  Atr_Wartosc = 'Standardowy'
and Twr_Waga <> 0

select Replace(twr_waga,'.',',') as [Waga_Gabaryt] from cdn.TwrKarty 
left join CDN.Atrybuty with(nolock) on Twr_GIDNumer=Atr_ObiNumer and Atr_OBITyp=16 and Atr_OBILp = 0 and Atr_AtkId = 148 
where  Atr_Wartosc = 'Gabarytowy'
and Twr_Waga <> 0

select Replace(twr_waga,'.',',') as [Waga_Delikatne] from cdn.TwrKarty 
left join CDN.Atrybuty with(nolock) on Twr_GIDNumer=Atr_ObiNumer and Atr_OBITyp=16 and Atr_OBILp = 0 and Atr_AtkId = 148 
where  Atr_Wartosc = 'Delikatny'
and Twr_Waga <> 0

select Replace(twr_waga,'.',',') as [Waga_Ciê¿kie] from cdn.TwrKarty 
left join CDN.Atrybuty with(nolock) on Twr_GIDNumer=Atr_ObiNumer and Atr_OBITyp=16 and Atr_OBILp = 0 and Atr_AtkId = 148 
where  Atr_Wartosc = 'Ciê¿ki'
and Twr_Waga <> 0