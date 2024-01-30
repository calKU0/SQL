select 
Prc_Imie1 + ' ' + Prc_Nazwisko as [Imie i Nazwisko],
Zad_Kod as [Nazwa zadania],
Zad_Nazwa as [Nazwa projektu],
Zad_Opis as [Opis],
Zad_Notatki as [Lnk do repozytorium],
replace(convert(varchar,Dateadd(Second, Zad_TerminOd, '1990-01-01') ,20),'.0000000','') as [Data rozpoczêcia],
replace(convert(varchar,Dateadd(Second, Zad_TerminDo, '1990-01-01') ,20),'.0000000','') as [Data zakoñczenia],
CONVERT(CHAR(8),DATEADD(second,sum(DATEDIFF(SECOND,convert(time, Dateadd(Second, Zad_TerminOd, '1990-01-01')),convert(time, Dateadd(Second, Zad_TerminDo, '1990-01-01')))),0),108) as [Godzin]
from cdn.zadania with (nolock)
join cdn.ZadaniaObiekty with (nolock) on Zad_Id=ZaO_ZadId
join cdn.PrcKarty with (nolock) on ZaO_ObiNumer=Prc_GIDNumer
where Zad_OpeUNumer in (704) and convert(date, Dateadd(Second, Zad_CzasUtworzenia, '1990-01-01'))  >= convert(date, getdate()-30)
group by Zad_Kod, Zad_OpeUNumer, Zad_TerminOd, Zad_TerminDo, ZaO_ObiNumer,Prc_Imie1, Prc_Nazwisko,Zad_Nazwa,Zad_Opis,Zad_Notatki
order by Zad_TerminOd