SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE GaskaNadajBudzet
AS
BEGIN
DECLARE @Rabat decimal (5,2)
DECLARE @WartoscPoRabacie decimal (15,4)

	SET NOCOUNT ON;
	-- 1. Tworzymy i wype³niamy tabelê z bud¿etami dostêpnymi dla zamówienia
	CREATE TABLE #Budzety 
	(
		Nazwa varchar
		,TypS varchar
		,Akronim varchar
		,Wartosc decimal (15,4)
		,Wykorzystana decimal (15,2)
		,NaliczonaSys decimal(15,6)
		,TypId int
		,Id int
		,PrmId int
		,PriorytetLp int
		,PominPozostale smallint
		,ObiNumer int
	)
	INSERT INTO #Budzety
	EXEC CDN.PRMZwrocBudzetyRabatoweDlaDokumentu @p_DokTyp=960, @p_DokNumer=2014853, @p_OpeNumer=20, @p_KntTyp=32, @p_KntNumer=7237, @p_Data=1066493801, @p_FormaNr=20, @p_FormaTermin=14, @p_FormaData=81392, @p_SposobDostawy=2, @p_Magazyn=1, @p_FrsId='120,119,1'

	-- 2. Sprawdzamy czy tabela coœ zawiera. Jeœli na dokumencie nie ma bud¿etu to tabela jest pusta i nie wchodzimy w pêtle
	IF EXISTS (SELECT * FROM #Budzety)
	BEGIN
		-- Tworzymy i wype³niamy tabelê z Cen¹ Pocz¹tkow¹ pojedyñczej pozycji
		CREATE TABLE #CenaPoczatkowa
		(
			CenaLp smallint
			,CenaWartosc decimal (15,4)
			,CenaPrmId int
			,CenaWaluta varchar(3)
			,CenaKursL int
			,CenaKursM int
			,CenaPrecyzja decimal (15,4)
			,CenaDokladnosc int
			,CenaFlabaNB varchar(3)
			,CenaPominPozostale smallint
			,CenaZrodlo int
			,CenaBlokadaZmianyCeny smallint
		)
		INSERT INTO #CenaPoczatkowa
		EXEC CDN.CenaPoczatkowa @GIDTyp = 9472, @GIDNumer =2014853, @GIDLp    = 1, @Data 	= 1066558944	, @KntTyp 	= 32, @KntNumer	=7237, @FrsId    ='120,119,1', @TwrTyp 	= 16, @TwrNumer = 43351, @CennikNumer= -1	, @DokCennikNumer= 7, @FormaNr 	= 20, @FormaTermin = 14, @FormaData=0, @SposobDostawy = 2, @Magazyn=1, @RodzajDok = 1, @ZstNumer  = 0

		-- Tworzymy i wype³niamy tabelê z bud¿etem pojedyñczej pozycji
		CREATE TABLE #MacierzRabatowa
		(
			PrmId int
			,PrmAkronim varchar
			,PrmTyp int
			,PrmPriorytet int
			,PrmPriorytetLp int
			,TwgNumer int
			,TwrNumer int
			,UpustTyp smallint
			,UpustWartosc decimal (15,4)
			,UpustWaluta varchar(3)
			,UpustFlagaNB varchar(3)
			,UpustProg decimal (15,4)
			,KntNumer int
			,PrmOperacja smallint
			,PrmPomin smallint
			,UpustId int
			,ZestNumer int
			,UpustSort int
			,BudzetMaks decimal (15,4)
			,TprId int
			,PrmLimitTyp int
			,TprLimitTyp int
			,PrmLimitWartosc decimal (15,4)
			,TprLimitWartosc decimal (15,4)
			,PrmProgTyp int
			,PrmProgWartosc decimal (15,4)
			,OkresTransakcjiOd int
			,OkresTransakcjiDo int
			,ProgTpr smallint
			,PrmWarunekSql varchar (1000)
			,LimitRodzaj int
		)
		INSERT INTO #MacierzRabatowa
		EXEC CDN.MacierzRabatowaPozycje  @lNagPoz= 2, @lRodzajDok= 1, @lData =1066558944, @lKntTyp =32, @lKntNumer=7237, @lTwrTyp =16, @lTwrNumer=43351, @lFormaNr=20, @lFormaTermin=14, @lFormaData=0, @lSposobDostawy=2, @lMagazyn=1, @sFrsId='120,119,1', @lZstNumer=0, @lGIDTyp=9472, @lGIDNumer=2014853, @lGIDLp=1, @lPromocjaID=0, @lPromocjaProgID=0, @lPromocjaWTRID=0, @lProgWTRID=0, @sDsts=''

		-- Tworzymy i wype³niamy tabelê z aktualnymi rabatami jakie obowi¹zuj¹ na danej pozycji (przed naliczeneniem bud¿etu)
		CREATE TABLE #ElementZamowienia
		(
			ElementZamNumer int
			,ElementLp int
			,ElementTwrNumer int
			,ElementCena decimal (15,4)
			,ElementRabat decimal (15,4)
		)
		INSERT INTO #ElementZamowienia
		SELECT ZaE_GIDNumer, ZaE_TwrLp, ZaE_TwrNumer, ZaE_CenaUzgodniona, ZaE_Rabat FROM cdn.ZamElem WHERE ZaE_GIDNumer = 2014853

		-- Zmieniamy dane na pojedyñczym elemencie zamówienia
			-- a) Jeœli pierwszy element pobiera odrazu ca³y bud¿et
		IF (SELECT (CenaWartosc*(UpustWartosc/100)) FROM #CenaPoczatkowa join #MacierzRabatowa on 1=1) >= (SELECT BudzetMaks FROM #MacierzRabatowa where PrmTyp = 10) and (SELECT NaliczonaSys FROM #Budzety) = 0
		BEGIN
			SET @Rabat = (SELECT ElementRabat + (100*(CenaWartosc - (CenaWartosc-BudzetMaks))/CenaWartosc) FROM #ElementZamowienia join #MacierzRabatowa ON 1=1 and PrmTyp = 10 join #CenaPoczatkowa on 1=1)
			SET @WartoscPoRabacie = (SELECT CenaWartosc - (CenaWartosc*(@Rabat/100)) FROM #CenaPoczatkowa)
			UPDATE CDN.ZamElem SET 
			ZaE_Rabat = @Rabat -- Dodajemy obowiazujacy rabat przed naliczeniem budzetu z wartoscia budzetu
			,ZaE_CenaUzgodniona = @WartoscPoRabacie -- Odejmujemy cene przed naliczeniem budzetu z podzielona cena poczatkowa przez procentowa wartosc budzetu
			,ZaE_WartoscPoRabacie = @WartoscPoRabacie -- jw.
			,ZaE_RabatPromocyjny = @Rabat -- To samo co ZaE_Rabat
			WHERE ZaE_GIDTyp = 960 AND ZaE_GIDNumer = 2014853 AND ZaE_GIDLp = 1
		END
			-- b) Jeœli element nie skorzysta z calej wartosci procentowej budzetu, poniewaz skonczyl sie limit
		ELSE IF ()
		BEGIN
		END
			-- c) Jeœli element wykorzysta cala wartosc procentowa budzetu 
		ELSE
		BEGIN
			UPDATE CDN.ZamElem SET 
			ZaE_Rabat = (SELECT ElementRabat + UpustWartosc FROM #ElementZamowienia join #MacierzRabatowa ON 1=1 and PrmTyp = 10) -- Dodajemy obowiazujacy rabat przed naliczeniem budzetu z wartoscia budzetu
			,ZaE_CenaUzgodniona = (SELECT ElementCena - (CenaWartosc*(UpustWartosc/100)) FROM #ElementZamowienia join #CenaPoczatkowa ON 1=1 join #MacierzRabatowa on 1=1 and PrmTyp = 10) -- Odejmujemy cene przed naliczeniem budzetu z podzielona cena poczatkowa przez procentowa wartosc budzetu
			,ZaE_WartoscPoRabacie = (SELECT ElementCena + (CenaWartosc*(UpustWartosc/100)) FROM #ElementZamowienia join #CenaPoczatkowa ON 1=1 join #MacierzRabatowa on 1=1 and PrmTyp = 10) -- jw.
			,ZaE_RabatPromocyjny = (SELECT ElementRabat + UpustWartosc FROM #ElementZamowienia join #MacierzRabatowa ON 1=1 and PrmTyp = 10) -- To samo co ZaE_Rabat
			WHERE ZaE_GIDTyp = 960 AND ZaE_GIDNumer = 2014853 AND ZaE_GIDLp = 1 
		END

		DELETE FROM #Budzety
		INSERT INTO #Budzety
		EXEC CDN.PRMZwrocBudzetyRabatoweDlaDokumentu @p_DokTyp=960, @p_DokNumer=2014853, @p_OpeNumer=20, @p_KntTyp=32, @p_KntNumer=7237, @p_Data=1066493801, @p_FormaNr=20, @p_FormaTermin=14, @p_FormaData=81392, @p_SposobDostawy=2, @p_Magazyn=1, @p_FrsId='120,119,1'

		DROP TABLE #ElementZamowienia
		DROP TABLE #MacierzRabatowa
		DROP TABLE #CenaPoczatkowa
	END
	DROP TABLE #Budzety
END
GO