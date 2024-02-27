select 
ROW_NUMBER() OVER (ORDER BY Zad_TerminDo) as [ID],
Prc_Imie1 + ' ' + Prc_Nazwisko as [Imie i Nazwisko],
replace(convert(varchar,Dateadd(Second, Zad_TerminOd, '1990-01-01') ,20),'.0000000','') as [Data rozpoczêcia],
replace(convert(varchar,Dateadd(Second, Zad_TerminDo, '1990-01-01') ,20),'.0000000','') as [Data zakoñczenia],
CONVERT(CHAR(5),DATEADD(second,sum(DATEDIFF(SECOND,convert(time, Dateadd(Second, Zad_TerminOd, '1990-01-01')),convert(time, Dateadd(Second, Zad_TerminDo, '1990-01-01')))),0),108) as [Godzin],
Zad_Kod as [Nazwa zadania],
Zad_Nazwa as [Nazwa projektu],
Zad_Opis as [Opis],
Zad_Notatki as [Link do repozytorium]
from cdn.zadania with (nolock)
join cdn.ZadaniaObiekty with (nolock) on Zad_Id=ZaO_ZadId
join cdn.PrcKarty with (nolock) on ZaO_ObiNumer=Prc_GIDNumer
where Zad_OpeUNumer in (704) 
and convert(date, Dateadd(Second, Zad_CzasUtworzenia, '1990-01-01'))  between  CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, getdate()), 0)) and CONVERT(DATE, DATEADD(dd,DAY(getdate()), getdate()))
group by Zad_Kod, Zad_OpeUNumer, Zad_TerminOd, Zad_TerminDo, ZaO_ObiNumer,Prc_Imie1, Prc_Nazwisko,Zad_Nazwa,Zad_Opis,Zad_Notatki

UNION ALL

select
@@ROWCOUNT as [ID],
'',
'',
'',
isnull(LTRIM(
    CONVERT(varchar, DATEDIFF(hour, '1900-01-01', CONVERT(datetime, DATEADD(SECOND, sum(DATEDIFF(SECOND, '00:00:00.000', CONVERT(CHAR(8),DATEADD(second,DATEDIFF(SECOND,convert(time, Dateadd(Second, Zad_TerminOd, '1990-01-01')), convert(time, Dateadd(Second, Zad_TerminDo, '1990-01-01'))),0),108))), '00:00:00.000'))))
) + ' h ' + 
LTRIM(
    CONVERT(varchar, 
        DATEDIFF(minute, 0, 
            DATEADD(SECOND, sum(DATEDIFF(SECOND, '00:00:00.000', CONVERT(CHAR(8),DATEADD(second,DATEDIFF(SECOND,convert(time, Dateadd(Second, Zad_TerminOd, '1990-01-01')), convert(time, Dateadd(Second, Zad_TerminDo, '1990-01-01'))),0),108))), '00:00:00.000'))
        % 60
    )
) + ' min ','0 h 0 min'),
'',
'',
'',
''

	from cdn.Zadania 
	join cdn.ZadaniaObiekty on Zad_Id = ZaO_ZadId 
	where Zad_OpeUNumer in (704)
	and convert(date, Dateadd(Second, Zad_CzasUtworzenia, '1990-01-01'))  between  CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, getdate()), 0)) and CONVERT(DATE, DATEADD(dd,DAY(getdate()), getdate()))

order by 1 asc