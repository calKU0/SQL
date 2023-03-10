USE [CDNXL_TESTOWA_2014]
GO
/****** Object:  StoredProcedure [dbo].[OdwiedzinyPrzedstawicieli]    Script Date: 13.12.2022 12:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[OdwiedzinyPrzedstawicieli]
(
@WartoscOd1 int
,@WartoscDo1 int
,@WartoscOd2 int
,@WartoscDo2 int
,@WizytyOd int
,@WizytyDo int
,@Rejon varchar(50)
,@UwzglednijGrupeCenowa int
,@GrupaCenowa int
)

AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Zapytanie varchar(4000)
	DECLARE @TerminRozpoczecia nvarchar(10) = DATEADD([day], @WizytyOd, CONVERT(date, '18001228', 104))
	DECLARE @TerminZakonczenia nvarchar(10) = DATEADD([day], @WizytyDo, CONVERT(date, '18001228', 104))

	DECLARE @TabelaZapytanieGoNet TABLE(
	Akronim varchar(255) NOT NULL
	,Imie varchar(255) NOT NULL
	,Nazwisko varchar(255) NOT NULL
	,TERMINROZPOCZECIA datetime NOT NULL
	,TERMINZAKONCZENIA datetime NOT NULL
	)
	
	SELECT  @Zapytanie = 
'SELECT * FROM OPENQUERY(gonet,
	''Select
	KH.SKROTNAZWY "Akronim"
	,O.IMIE "Imie"
	,O.NAZWISKO "Nazwisko"
	,Z.TERMINROZPOCZECIA "Termin rozpoczecia"
	,Z.TERMINZAKONCZENIA "Termin zakonczenia"
                                          
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
	AND Z.TERMINROZPOCZECIA >= ''''' + @TerminRozpoczecia + '''''
	AND Z.TERMINZAKONCZENIA <= ''''' + @TerminZakonczenia + '''''
	''
)'

INSERT INTO @TabelaZapytanieGoNet (Akronim, Imie, Nazwisko, TERMINROZPOCZECIA, TERMINZAKONCZENIA) EXEC (@Zapytanie)

select id=1

,knt_akronim as [Akronim]

,rej_nazwa as [Rejon]

,Ulica = Knt_Ulica
,Kod_Pocztowy = Knt_KodP
,Miasto = Knt_Miasto
--Usunąłem także zbęde podzapytania, których Pan Jarek nie potrzebował

,convert(decimal(15,2), (select count(tzg.Akronim)
from @TabelaZapytanieGoNet tzg
where tzg.Akronim = knt_akronim
)) as [Liczba wizyt GoNet punkty]

,isnull((select sum(tre_ksiegowanetto)
from cdn.tranag WITH(NOLOCK)
join cdn.traelem WITH(NOLOCK) on TrN_GIDTyp=TrE_GIDTyp AND TrN_GIDNumer=TrE_GIDNumer
where Knt_GIDNumer=TrN_KntNumer and TrN_KntTyp=32
and trn_gidTyp in (2033, 2034, 2041, 2042, 2001, 2009, 2037, 2045, 2005, 2013)
and trn_data2 between @WartoscOd1 and @WartoscDo1
),0) as [Wartość 1]

,isnull((select sum(tre_ksiegowanetto)
from cdn.tranag WITH(NOLOCK)
join cdn.traelem WITH(NOLOCK) on TrN_GIDTyp=TrE_GIDTyp AND TrN_GIDNumer=TrE_GIDNumer
where Knt_GIDNumer=TrN_KntNumer and TrN_KntTyp=32
and trn_gidTyp in (2033, 2034, 2041, 2042, 2001, 2009, 2037, 2045, 2005, 2013)
and trn_data2 between @WartoscOd2 and @WartoscDo2
),0) as [Wartość 2]

,(select Naz_Nazwa
from cdn.nazwy
where Naz_GIDTyp = 64 and Naz_GIDLp = Knt_Cena) as [Grupa cenowa]


from cdn.kntkarty
join cdn.rejony on REJ_Id=Knt_RegionCRM
join cdn.nazwy on Knt_Cena = Naz_GIDLp AND Naz_GIDTyp = 64

where knt_typ != 8 and rej_nazwa like '%' + @Rejon + '%'

and Knt_Cena = case when @UwzglednijGrupeCenowa = 1 then @GrupaCenowa else Knt_Cena end

order by knt_akronim asc

	SET NOCOUNT OFF
END