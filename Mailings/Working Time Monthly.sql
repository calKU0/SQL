DECLARE @tableHTML varchar(MAX)
DECLARE @Temat varchar(255)
DECLARE @data date = convert(date, getdate()-1)
declare
	@dataOd date = CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, getdate()) - 1, 0))
	,@dataDo date = CONVERT(DATE, DATEADD(dd,-DAY(getdate()), getdate()))


set @Temat = 'Produkcja mailing miesiêczny czasy od ' + convert(varchar(50), @dataOd) + ' do ' + convert(varchar(50), @dataDo)

SET @tableHTML = 

N'<h2>' + @Temat + '</h2>' +
N'<table border="1">' +
N'<tr>
<th>Pracownik</th>
<th>Czas z ZP</th>
<th>Czas Pozaprodukcyjny</th>
<th>Czas Pracy</th>
<th>Wype³nienie czasu pracy</th>
</tr>' +
CAST ( ( SELECT

'yellow'AS [@bgcolor],
td = podzapytanie.Pracownik, '',

td = podzapytanie.Czas,'',

td = isnull(LTRIM(
    CONVERT(varchar, DATEDIFF(hour, '1900-01-01', CONVERT(datetime, DATEADD(ms, DATEDIFF(ms, '00:00:00.000', podzapytanie.[Czas Pozaprodukcyjny]), '00:00:00.000'))))
) + ' h ' + 
LTRIM(
    CONVERT(varchar, 
        DATEDIFF(minute, 0, 
            DATEADD(ms, DATEDIFF(ms, '00:00:00.000', podzapytanie.[Czas Pozaprodukcyjny]), '00:00:00.000'))
        % 60
    )
) + ' min ','0 h 0 min'),'',

td = convert(varchar(10), [Godziny pracy] / 60) + ' h' + ' ' + convert(varchar(10), [Godziny pracy] % 60) + ' min','',

td = convert(varchar(10), convert(decimal(15,2),convert(decimal(15,2),((isnull([Czas Pozaprodukcyjny2],0) + isnull(Czas2,0)))) / ([Godziny pracy] * 60) * 100)) + ' %'

from
(
select

	Prc_Nazwisko + ' ' + Prc_Imie1 as [Pracownik]

	,isnull(
		LTRIM(
		CONVERT(varchar, DATEDIFF(hour, '1900-01-01', CONVERT(datetime, DATEADD(ms, SUM(DATEDIFF(ms, '00:00:00.000', convert(time(0), DATEADD(ms, DATEDIFF(ms, 0, convert(time, DATEADD(ss,PCZ_CzasRealizacji / case when ISNULL(sa.Atr_Wartosc,'') = 'TAK' then 2 else 1 end,0))), 0)))), '00:00:00.000'))))
	) + ' h ' + 
	LTRIM(
		CONVERT(varchar, 
			DATEDIFF(minute, 0, 
				DATEADD(ms, SUM(DATEDIFF(ms, '00:00:00.000', convert(time(0), DATEADD(ms, DATEDIFF(ms, 0, convert(time, DATEADD(ss,PCZ_CzasRealizacji / case when ISNULL(sa.Atr_Wartosc,'') = 'TAK' then 2 else 1 end,0))), 0)))), '00:00:00.000'))
			% 60
		)
	) + ' min ','0 h 0 min') as [Czas]

	,(Select CONVERT(CHAR(8),DATEADD(second,sum(DATEDIFF(SECOND,convert(time, Dateadd(Second, Zad_TerminOd, '1990-01-01')), convert(time, Dateadd(Second, Zad_TerminDo, '1990-01-01')))),0),108)
	from cdn.Zadania join cdn.ZadaniaObiekty on Zad_Id = ZaO_ZadId where ZaO_ObiNumer = prc1.prc_gidnumer
	and convert(date, Dateadd(Second, Zad_TerminDo, '1990-01-01'))  between @DataOd and @DataDo and Zad_ZrdTyp = 0 and Zad_CzasWykonania != 0) 
	as [Czas Pozaprodukcyjny]

		,(SELECT sum(SUBSTRING(Cast([RCG_CzasWPracy] as varchar(50)),0,6)/ 60) 
	from CDN_GASKA_KADRY.cdn.Pracidx with(nolock)
	left join [CDN_GASKA_KADRY].[CDN].[EP_RCPDni] with(nolock) on RCP_PraId = PRI_PraId and convert(date, rcp_data) between convert(date, @dataOd) and convert(date, @dataDo)
	left join [CDN_GASKA_KADRY].[CDN].[EP_RCPDniGodz] with(nolock) on RCG_RcpId = RCP_RcpId
	where prc1.Prc_Imie1 = PRI_Imie1 and prc1.Prc_Nazwisko = PRI_Nazwisko and PRI_Typ = 10) [Godziny pracy]

	,(Select sum(DATEDIFF(SECOND,convert(time, Dateadd(Second, Zad_TerminOd, '1990-01-01')), convert(time, Dateadd(Second, Zad_TerminDo, '1990-01-01'))))
	from cdn.Zadania join cdn.ZadaniaObiekty on Zad_Id = ZaO_ZadId where ZaO_ObiNumer = prc1.prc_gidnumer
	and convert(date, Dateadd(Second, Zad_TerminDo, '1990-01-01')) between @DataOd and @DataDo and Zad_ZrdTyp = 0 and Zad_CzasWykonania != 0) 
	as [Czas Pozaprodukcyjny2]

	,SUM(DATEDIFF(SECOND, 0, convert(time, DATEADD(SECOND,PCZ_CzasRealizacji / case when ISNULL(sa.Atr_Wartosc,'') = 'TAK' then 2 else 1 end,0)))) as [Czas2]

	from cdn.PrcKarty prc1
	left join cdn.prodobiekty pob1 on prc1.Prc_GIDNumer=pob1.POB_ObiNumer and pob1.POB_ObiTyp=944-- pracownik
	left join cdn.ProdCzynnosciObiekty pco1 on pob1.POB_Id=pco1.PCO_Obiekt
	left join cdn.prodczynnosci pcz1 on pcz1.PCZ_Id=pco1.PCO_Czynnosc and DATEDIFF(DD,'18001228',convert(date, Dateadd(Second, PCZ_TerminZakonczenia , '1990-01-01'))) between DATEDIFF(DD,'18001228',@dataOd) and DATEDIFF(DD,'18001228', @dataDo)
	left join cdn.prodprocesy ppc1 on ppc1.PPC_Id=pcz1.PCZ_Proces 
	left join cdn.prodzlecenia pzl1 on pzl1.PZL_Id=ppc1.PPC_Zlecenie
	left join cdn.ProdTechnologia pte1 on pte1.PTE_Id=ppc1.PPC_Technologia
	left join cdn.ProdTechnologiaCzynnosci ptc1 on pte1.PTE_Id=ptc1.PTC_Technologia and pcz1.PCZ_TechnologiaCzynnosc = ptc1.PTC_Id
	left join CDNXL_GASKA.cdn.Atrybuty sa with (nolock) on PCZ_Id=Atr_ObiNumer and Atr_OBITyp=14345 and Atr_OBILp = 0 and Atr_AtkId = 450 -- CNC x 2

	where Prc_FrSId = 581 and Prc_Archiwalny = 0
	group by Prc_Nazwisko,Prc_Imie1,Prc_GIDNumer) podzapytanie
	where Pracownik not in ('Staroñ S³awomir', 'Ma³ek £ukasz','Sieradzki Grzegorz','Paw³owski Szymon')
	and 1 = case when (isnull(CAST(podzapytanie.[Czas Pozaprodukcyjny] AS TIME),'00:00:00') = '00:00:00' and podzapytanie.Czas = '0 h 0 min') then 0 else 1 end

order by podzapytanie.Pracownik

FOR XML PATH('tr'), TYPE 
) AS NVARCHAR(MAX) ) 
+ CAST ((SELECT 
'orange'AS [@bgcolor],
td = 'Suma:','',

td = LTRIM(
    CONVERT(varchar, DATEDIFF(HOUR, '1900-01-01', CONVERT(datetime, DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00.000', podzapytanie.Czas)), '00:00:00.000'))))
) + ' h ',
LTRIM(
    CONVERT(varchar, 
        DATEDIFF(minute, 0, 
            DATEADD(SECOND, SUM(DATEDIFF(SECOND, '00:00:00.000', podzapytanie.Czas)), '00:00:00.000'))
        % 60
    )
) + ' min ','',

td = isnull(LTRIM(
    CONVERT(varchar, DATEDIFF(hour, '1900-01-01', CONVERT(datetime, DATEADD(SECOND, sum(distinct DATEDIFF(SECOND, '00:00:00.000', podzapytanie.[Czas Pozaprodukcyjny])), '00:00:00.000'))))
) + ' h ' + 
LTRIM(
    CONVERT(varchar, 
        DATEDIFF(minute, 0, 
            DATEADD(SECOND, sum(distinct DATEDIFF(SECOND, '00:00:00.000', podzapytanie.[Czas Pozaprodukcyjny])), '00:00:00.000'))
        % 60
    )
) + ' min ','0 h 0 min')

from
(
select

	Prc_Nazwisko + ' ' + Prc_Imie1 as [Pracownik]

	,isnull((select convert(time(0), DATEADD(ms, SUM(DATEDIFF(ms, 0, convert(time, DATEADD(ss,PCZ_CzasRealizacji / case when ISNULL(sa.Atr_Wartosc,'') = 'TAK' then 2 else 1 end,0)))), 0))
	from cdn.PrcKarty prc2
	left join cdn.prodobiekty pob2 on prc2.Prc_GIDNumer=pob2.POB_ObiNumer and pob2.POB_ObiTyp=944-- pracownik
	left join cdn.ProdCzynnosciObiekty pco2 on pob2.POB_Id=pco2.PCO_Obiekt
	left join cdn.prodczynnosci pcz2 on pcz2.PCZ_Id=pco2.PCO_Czynnosc and DATEDIFF(DD,'18001228',convert(date, Dateadd(Second, PCZ_TerminZakonczenia , '1990-01-01'))) between DATEDIFF(DD,'18001228',@dataOd) and DATEDIFF(DD,'18001228', @dataDo)
	left join cdn.prodprocesy ppc2 on ppc2.PPC_Id=pcz2.PCZ_Proces
	left join cdn.prodzlecenia pzl2 on pzl2.PZL_Id=ppc2.PPC_Zlecenie
    left join CDNXL_GASKA.cdn.Atrybuty sa with (nolock) on PCZ_Id=Atr_ObiNumer and Atr_OBITyp=14345 and Atr_OBILp = 0 and Atr_AtkId = 450 -- CNC x 2
	where pzl1.PZL_Id = pzl2.PZL_Id and prc1.prc_gidnumer = prc2.prc_gidnumer
	),'00:00:00')as [Czas]

	,(Select CONVERT(CHAR(8),DATEADD(second,sum(DATEDIFF(SECOND,convert(time, Dateadd(Second, Zad_TerminOd, '1990-01-01')), convert(time, Dateadd(Second, Zad_TerminDo, '1990-01-01')))),0),108)
	from cdn.Zadania join cdn.ZadaniaObiekty on Zad_Id = ZaO_ZadId where ZaO_ObiNumer = prc1.prc_gidnumer
	and convert(date, Dateadd(Second, Zad_TerminDo, '1990-01-01'))  between @DataOd and @DataDo and Zad_ZrdTyp = 0 and Zad_CzasWykonania != 0) 
	as [Czas Pozaprodukcyjny]

	from cdn.PrcKarty prc1
	left join cdn.prodobiekty pob1 on prc1.Prc_GIDNumer=pob1.POB_ObiNumer and pob1.POB_ObiTyp=944-- pracownik
	left join cdn.ProdCzynnosciObiekty pco1 on pob1.POB_Id=pco1.PCO_Obiekt
	left join cdn.prodczynnosci pcz1 on pcz1.PCZ_Id=pco1.PCO_Czynnosc and DATEDIFF(DD,'18001228',convert(date, Dateadd(Second, PCZ_TerminZakonczenia , '1990-01-01'))) between DATEDIFF(DD,'18001228',@dataOd) and DATEDIFF(DD,'18001228', @dataDo)
	left join cdn.prodprocesy ppc1 on ppc1.PPC_Id=pcz1.PCZ_Proces 
	left join cdn.prodzlecenia pzl1 on pzl1.PZL_Id=ppc1.PPC_Zlecenie
	left join cdn.ProdTechnologia pte1 on pte1.PTE_Id=ppc1.PPC_Technologia
	left join cdn.ProdTechnologiaCzynnosci ptc1 on pte1.PTE_Id=ptc1.PTC_Technologia and pcz1.PCZ_TechnologiaCzynnosc = ptc1.PTC_Id

	where Prc_FrSId = 581 and Prc_Archiwalny = 0
	group by POB_Kod, PZL_Id, PZL_Numer, PZL_Rok, PZL_Seria, Prc_Nazwisko,Prc_Imie1,Prc_GIDNumer) podzapytanie
	where 1 = case when (isnull(CAST(podzapytanie.[Czas Pozaprodukcyjny] AS TIME),'00:00:00') = '00:00:00' and isnull(convert(time, DATEADD(ms, DATEDIFF(ms, '00:00:00.000', podzapytanie.Czas), '00:00:00.000')),'00:00:00') = '00:00:00') then 0 else 1 end
	and Pracownik not in ('Staroñ S³awomir', 'Ma³ek £ukasz','Sieradzki Grzegorz')
FOR XML PATH('tr'), TYPE 
) AS NVARCHAR(MAX) ) 
+
N'</table>';

EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'Gaska',
@recipients='michal.g@gaska.com.pl',
@subject = @Temat,
@body = @tableHTML,
@body_format = 'HTML'