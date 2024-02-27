SELECT CONVERT(date, [Data rozpoczecia]) as Data
,[ID Wizyty]
,[ID PH]
,[ID Klient]
,cast([Data rozpoczecia] as time) as [Godzina rozpoczecia]
,cast([Data zakonczenia] as time) as[Godzina zakonczenia]

FROM OPENQUERY(gonet,
	'Select
	Z.ID "ID Wizyty"
	,KH.ID "ID Klient"
	,O.ID "ID PH"
	,Z.TERMINROZPOCZECIA "Data rozpoczecia"
	,Z.TERMINZAKONCZENIA "Data zakonczenia"
                                          
	FROM KORESPONDENCJADZIENNIK KD 
	JOIN KORESPONDENCJA KO ON KO.ID = KD.IDKORESPONDENCJI
	JOIN ZADANIA Z On Z.IDKORESPONDENCJADZIENNIKROOT = KD.ID                                                          
	JOIN KONTRAHENT KH On KH.ID = KD.IDKONTRAHENTA
	LEFT JOIN SLOWNIK S1 On S1.ID = KH.IDMIASTO
	JOIN OPERATOR O On O.ID = KO.IDOPERATORA

	WHERE KD.USUNIETY = 0
	AND KD.ARC = 0
	AND KO.USUNIETY = 0
	AND KO.ARC = 0
	AND cast(Z.TERMINROZPOCZECIA as date) = cast(''NOW'' as date) - 1 
	'
	)