declare @yearbefore date = DATEADD(year, -1, getdate())
declare @yearandmonthbefore date = DATEADD(month, -1, @yearbefore)
declare @currentmonth date = DATEADD(month, 0, getdate())

Select  
id=1
,Knt_Akronim as [Akronim Kontrahenta]
--Obrót rok temu
,isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@yearbefore , 'yyyy-MM') then tre_ksiegowanetto else null end),0) as [Obrót kontrahenta rok temu]

--Obrót w tym miesi¹cu
,isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@currentmonth , 'yyyy-MM') then tre_ksiegowanetto else null end),0) as [Obrót kontrahenta w tym miesi¹cu]

--Zlicza Ile brakuje kwoty do uzyskania do³adowania w tym miesi¹cu (aby otrzymaæ do³adowanie kontrahent musi mieæ wiekszy obrót w tym miesi¹cu ni¿ rok temu o co najmniej 10%), gdy kontrahent ju¿ ma zapewnione do³adownie to kwota brakuj¹ca do do³adowania = 0
,case when(isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@yearbefore , 'yyyy-MM') then tre_ksiegowanetto else null end),0)*1.10
- isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@currentmonth , 'yyyy-MM') then tre_ksiegowanetto else null end),0)) < 0 then 0 else isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@yearbefore , 'yyyy-MM') then tre_ksiegowanetto else null end),0)*1.10
- isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@currentmonth , 'yyyy-MM') then tre_ksiegowanetto else null end),0) end
as [Kwota brakuj¹ca do do³adowania]


from cdn.KntKarty with(nolock)
join cdn.TraElem with(nolock) on Knt_GIDNumer=TrE_KntNumer and TrE_KntTyp=32
join cdn.TraNag with(nolock) on  trn_gidTyp = tre_gidtyp and trn_gidnumer=tre_gidNumer
join cdn.KntOsoby with(nolock) on Knt_GIDNumer=KnS_KntNumer and KnS_KntTyp=32
join cdn.PrcRole with(nolock) on KnS_KntNumer=PrR_PrcNumer AND KnS_KntLp=PrR_PrcLp and PrR_PrcTyp=32

where PrR_RolId = 11
and TrN_GIDTyp in (2033,2041,2001,2009,2042,2034, 2037, 2045)
and TrN_Data2 >DATEDIFF(DD,'18001228',GETDATE()-730)



group by knt_akronim,Knt_GIDNumer

declare @yearbefore date = DATEADD(year, -1, getdate())
declare @yearandmonthbefore date = DATEADD(month, -1, @yearbefore)
declare @currentmonth date = DATEADD(month, 0, getdate())

Select  
id=1
,Knt_Akronim as [Akronim Kontrahenta]
--Obrót rok temu
,isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@yearbefore , 'yyyy-MM') then tre_ksiegowanetto else null end),0) as [Obrót kontrahenta rok temu]

--Obrót w tym miesi¹cu
,isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@currentmonth , 'yyyy-MM') then tre_ksiegowanetto else null end),0) as [Obrót kontrahenta w tym miesi¹cu]

--Zlicza Ile brakuje kwoty do uzyskania do³adowania w tym miesi¹cu (aby otrzymaæ do³adowanie kontrahent musi mieæ wiekszy obrót w tym miesi¹cu ni¿ rok temu o co najmniej 10%), gdy kontrahent ju¿ ma zapewnione do³adownie to kwota brakuj¹ca do do³adowania = 0
,case when(isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@yearbefore , 'yyyy-MM') then tre_ksiegowanetto else null end),0)*1.10
- isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@currentmonth , 'yyyy-MM') then tre_ksiegowanetto else null end),0)) < 0 then 0 else isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@yearbefore , 'yyyy-MM') then tre_ksiegowanetto else null end),0)*1.10
- isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@currentmonth , 'yyyy-MM') then tre_ksiegowanetto else null end),0) end
as [Kwota brakuj¹ca do do³adowania]


from cdn.KntKarty with(nolock)
join cdn.TraElem with(nolock) on Knt_GIDNumer=TrE_KntNumer and TrE_KntTyp=32
join cdn.TraNag with(nolock) on  trn_gidTyp = tre_gidtyp and trn_gidnumer=tre_gidNumer
join cdn.KntOsoby with(nolock) on Knt_GIDNumer=KnS_KntNumer and KnS_KntTyp=32
join cdn.PrcRole with(nolock) on KnS_KntNumer=PrR_PrcNumer AND KnS_KntLp=PrR_PrcLp and PrR_PrcTyp=32

where PrR_RolId = 11
and TrN_GIDTyp in (2033,2041,2001,2009,2042,2034, 2037, 2045)
and TrN_Data2 >DATEDIFF(DD,'18001228',GETDATE()-730)



group by knt_akronim,Knt_GIDNumer

having (select isnull(sum(TrP_Pozostaje),0) 
		from cdn.traplat WITH (NOLOCK) 
		where 
		Knt_GIDNumer=TrP_KntNumer 
		and TRP_KntTyp=32 and dateadd(day, TrP_Termin+14, '18001228') < getdate()
		and TrP_Rozliczona=0
		and TrP_FormaNr=20
		and TrP_GIDTyp in (2033,2001,2037)
		and trp_typ=2)<=0