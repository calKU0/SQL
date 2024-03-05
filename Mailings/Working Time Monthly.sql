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

td = ISNULL(
    LTRIM(CONVERT(varchar, DATEDIFF(hour, '1900-01-01', 
        CONVERT(datetime, DATEADD(ms, podzapytanie.[Czas Pozaprodukcyjny2] * 1000, '1900-01-01')))
    )) + ' h ' + 
    LTRIM(CONVERT(varchar, DATEDIFF(minute, 0,  
        DATEADD(ms, podzapytanie.[Czas Pozaprodukcyjny2] * 1000, '1900-01-01')) % 60
    )) + ' min', '0 h 0 min'),'',

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

td = CONCAT(FLOOR(sum(isnull(podzapytanie.Czas,0)) / 60), ' h ',sum(isnull(podzapytanie.Czas,0)) % 60, ' min'),'',

td = CONCAT(FLOOR(sum(isnull(podzapytanie.[Czas Pozaprodukcyjny],0)) / 60), ' h ',sum(isnull(podzapytanie.[Czas Pozaprodukcyjny],0)) % 60, ' min'),'',

td = CONCAT(FLOOR(sum(isnull([Godziny pracy],0)) / 60), ' h ', sum(isnull([Godziny pracy],0)) % 60, ' min')

from
(
  SELECT
        Prc_Nazwisko + ' ' + Prc_Imie1 AS [Pracownik],
        SUM(DATEDIFF(minute, 0, CONVERT(TIME, DATEADD(SECOND, PCZ_CzasRealizacji / CASE WHEN ISNULL(sa.Atr_Wartosc,'') = 'TAK' THEN 2 ELSE 1 END, 0)))) AS [Czas],
        
		(SELECT sum(DATEDIFF(minute, CONVERT(TIME, DATEADD(SECOND, Zad_TerminOd, '1990-01-01')), CONVERT(TIME, DATEADD(SECOND, Zad_TerminDo, '1990-01-01'))))
         FROM cdn.Zadania
         JOIN cdn.ZadaniaObiekty ON Zad_Id = ZaO_ZadId
         WHERE ZaO_ObiNumer = prc1.prc_gidnumer
           AND CONVERT(DATE, DATEADD(SECOND, Zad_TerminDo, '1990-01-01')) BETWEEN @DataOd AND @DataDo
           AND Zad_ZrdTyp = 0
           AND Zad_CzasWykonania != 0) AS [Czas Pozaprodukcyjny],
        
		(SELECT SUM(SUBSTRING(CAST([RCG_CzasWPracy] AS VARCHAR(50)), 0, 6) / 60)
         FROM CDN_GASKA_KADRY.cdn.Pracidx WITH(NOLOCK)
         LEFT JOIN [CDN_GASKA_KADRY].[CDN].[EP_RCPDni] WITH(NOLOCK) ON RCP_PraId = PRI_PraId AND CONVERT(DATE, rcp_data) BETWEEN CONVERT(DATE, @DataOd) AND CONVERT(DATE, @DataDo)
         LEFT JOIN [CDN_GASKA_KADRY].[CDN].[EP_RCPDniGodz] WITH(NOLOCK) ON RCG_RcpId = RCP_RcpId
         WHERE prc1.Prc_Imie1 = PRI_Imie1 AND prc1.Prc_Nazwisko = PRI_Nazwisko AND PRI_Typ = 10) AS [Godziny pracy]

    FROM
        cdn.PrcKarty prc1
        LEFT JOIN cdn.prodobiekty pob1 ON prc1.Prc_GIDNumer = pob1.POB_ObiNumer AND pob1.POB_ObiTyp = 944 -- pracownik
        LEFT JOIN cdn.ProdCzynnosciObiekty pco1 ON pob1.POB_Id = pco1.PCO_Obiekt
        LEFT JOIN cdn.prodczynnosci pcz1 ON pcz1.PCZ_Id = pco1.PCO_Czynnosc AND DATEDIFF(DAY, '18001228', CONVERT(DATE, DATEADD(SECOND, PCZ_TerminZakonczenia, '1990-01-01'))) BETWEEN DATEDIFF(DAY, '18001228', @DataOd) AND DATEDIFF(DAY, '18001228', @DataDo)
        LEFT JOIN cdn.prodprocesy ppc1 ON ppc1.PPC_Id = pcz1.PCZ_Proces 
        LEFT JOIN cdn.prodzlecenia pzl1 ON pzl1.PZL_Id = ppc1.PPC_Zlecenie
        LEFT JOIN cdn.ProdTechnologia pte1 ON pte1.PTE_Id = ppc1.PPC_Technologia
        LEFT JOIN cdn.ProdTechnologiaCzynnosci ptc1 ON pte1.PTE_Id = ptc1.PTC_Technologia AND pcz1.PCZ_TechnologiaCzynnosc = ptc1.PTC_Id
        LEFT JOIN CDNXL_GASKA.cdn.Atrybuty sa WITH(NOLOCK) ON PCZ_Id = Atr_ObiNumer AND Atr_OBITyp = 14345 AND Atr_OBILp = 0 AND Atr_AtkId = 450 -- CNC x 2
    WHERE Prc_FrSId = 581 AND Prc_Archiwalny = 0
    GROUP BY Prc_Nazwisko, Prc_Imie1, Prc_GIDNumer
	having 1 = case when isnull((SELECT sum(DATEDIFF(minute, CONVERT(TIME, DATEADD(SECOND, Zad_TerminOd, '1990-01-01')), CONVERT(TIME, DATEADD(SECOND, Zad_TerminDo, '1990-01-01'))))
         FROM cdn.Zadania
         JOIN cdn.ZadaniaObiekty ON Zad_Id = ZaO_ZadId
         WHERE ZaO_ObiNumer = prc1.prc_gidnumer
           AND CONVERT(DATE, DATEADD(SECOND, Zad_TerminDo, '1990-01-01')) BETWEEN @DataOd AND @DataDo
           AND Zad_ZrdTyp = 0
           AND Zad_CzasWykonania != 0),0) = 0 and isnull(SUM(DATEDIFF(minute, 0, CONVERT(TIME, DATEADD(SECOND, PCZ_CzasRealizacji / CASE WHEN ISNULL(sa.Atr_Wartosc,'') = 'TAK' THEN 2 ELSE 1 END, 0)))),0) = 0 then 0 else 1 end) podzapytanie

	where Pracownik not in ('Staroñ S³awomir', 'Ma³ek £ukasz','Sieradzki Grzegorz','Paw³owski Szymon')
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