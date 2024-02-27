declare @yearbefore date = DATEADD(year, -1, getdate())
declare @yearandmonthbefore date = DATEADD(month, -1, @yearbefore)
declare @monthbefore date = DATEADD(month, -1, getdate())

Select id=1
,Knt_Akronim as [Akronim Kontrahenta]
,Knt_KartaLoj as [Numer Karty Sodexo]
,KnS_Nazwa as [Osoba uprawniona]
,isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@yearandmonthbefore , 'yyyy-MM') then tre_ksiegowanetto else null end),0) as [Obrot rok temu w analogicznym miesiacu]
,isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@monthbefore , 'yyyy-MM') then tre_ksiegowanetto else null end),0) as [Obrot poprzedni miesiac]
,round(cast(isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@monthbefore , 'yyyy-MM') then tre_ksiegowanetto else null end),0)*0.01 as decimal(10,2)),2) as [Doladowanie]

from cdn.KntKarty with(nolock)
join cdn.TraElem with(nolock) on Knt_GIDNumer=TrE_KntNumer and TrE_KntTyp=32
join cdn.TraNag with(nolock) on  trn_gidTyp = tre_gidtyp and trn_gidnumer=tre_gidNumer
join cdn.KntOsoby with(nolock) on Knt_GIDNumer=KnS_KntNumer and KnS_KntTyp=32
join cdn.PrcRole with(nolock) on KnS_KntNumer=PrR_PrcNumer AND KnS_KntLp=PrR_PrcLp and PrR_PrcTyp=32

where PrR_RolId = 11
and TrN_GIDTyp in (2033,2041,2001,2009,2042,2034, 2037, 2045)
and TrN_Data2 > DATEDIFF(DD,'18001228',GETDATE()-730)

group by knt_akronim, Knt_GIDNumer, Knt_KartaLoj, KnS_Nazwa

having  isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@monthbefore , 'yyyy-MM') then tre_ksiegowanetto else null end),0) 
>
isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@yearandmonthbefore , 'yyyy-MM') then tre_ksiegowanetto else null end),0)*1.09999

and (select isnull(sum(TrP_Pozostaje),0) 
		from cdn.traplat WITH (NOLOCK) 
		where 
		Knt_GIDNumer=TrP_KntNumer 
		and TRP_KntTyp=32 
		and dateadd(day, TrP_Termin+14, '18001228') < case when datepart(day,getdate())<=10 then getdate() else getdate() - datepart(day,getdate()) + 10 end
		and TrP_Rozliczona=0
		and TrP_FormaNr=20
		and TrP_GIDTyp in (2033,2001,2037)
		and trp_typ=2)<=0

order by Knt_Akronim
