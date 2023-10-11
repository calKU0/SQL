SELECT * FROM OPENQUERY(gonet,
'select distinct
k.id "ID Klient"
,k.PELNANAZWA "Nazwa"
,s1.NAZWA "Kraj"
,k.KODPOCZTOWY "Kod"
,s2.NAZWA "Miejscowoœæ"
,k.Adres "Ulica"
,k.ADRESDOM "Numer"
,k.IDMANAGERA "ID PH"
,i.DATASTART "Data Start"
,i.DATAKONIEC "Data Koniec"

from inwestycja i
left join inwestycjaetap ie on i.id = ie.idinwestycja
left join grupyinwestycji g on ie.id = g.idetapu
left join kontrahent k on k.id = g.idkontrahenta
left join slownik s1 on s1.id = k.idkraj
left join slownik s2 on s2.id = k.idmiasto

where ie.idtyp = 4292 -- Tylko kontrahenci z etapem ''Wizyta u klienta''
and i.IDMANAGERA = 78 -- Trasy Automat jako prowadz¹cy
'

)
where [Data Koniec] >= GETDATE()