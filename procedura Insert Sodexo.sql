USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [dbo].[Gaska_Sodexo_Doladowanie]    Script Date: 02.03.2023 08:03:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Gaska_Sodexo_Doladowanie]
AS
BEGIN
declare @yearbefore date = DATEADD(year, -1, getdate())
declare @yearandmonthbefore date = DATEADD(month, -1, @yearbefore)
declare @monthbefore date = DATEADD(month, -1, getdate())

INSERT INTO dbo.Gaska_Sodexo_doładowanie(Sod_KntGIDNumer,Sod_Miesiac,Sod_Rok,Sod_Kwota)
Select
Knt_GIDNumer
,case when datepart(month,getdate()) !=1 then datepart(month,getdate())-1 else 12 end
,case when datepart(month,getdate()) !=1 then datepart(year,getdate()) else datepart(year,getdate())-1 end
,round(cast(isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@monthbefore , 'yyyy-MM') then tre_ksiegowanetto else null end),0)*0.01 as decimal(10,2)),2)


from cdn.KntKarty with(nolock)
join cdn.TraElem with(nolock) on Knt_GIDNumer=TrE_KntNumer and TrE_KntTyp=32
join cdn.TraNag with(nolock) on  trn_gidTyp = tre_gidtyp and trn_gidnumer=tre_gidNumer
join cdn.KntOsoby with(nolock) on Knt_GIDNumer=KnS_KntNumer and KnS_KntTyp=32
join cdn.PrcRole with(nolock) on KnS_KntNumer=PrR_PrcNumer AND KnS_KntLp=PrR_PrcLp and PrR_PrcTyp=32

where PrR_RolId = 11
and TrN_GIDTyp in (2033,2041,2001,2009,2042,2034, 2037, 2045)
and TrN_Data2 >DATEDIFF(DD,'18001228',GETDATE()-730)

group by knt_akronim, Knt_GIDNumer

having  isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@monthbefore , 'yyyy-MM') then tre_ksiegowanetto else null end),0) 
>
isnull(sum(case when format(dateadd(day, trn_data2, '18001228'), 'yyyy-MM') = FORMAT(@yearandmonthbefore , 'yyyy-MM') then tre_ksiegowanetto else null end),0)*1.09999

and (select isnull(sum(TrP_Pozostaje),0) 
		from cdnxl_gaska.cdn.traplat WITH (NOLOCK) 
		where 
		Knt_GIDNumer=TrP_KntNumer 
		and TRP_KntTyp=32 
        and dateadd(day, TrP_Termin+14, '18001228') <getdate()
		and TrP_Rozliczona=0
		and TrP_FormaNr=20
		and TrP_GIDTyp in (2033,2001,2037)
		and trp_typ=2)<=0
END