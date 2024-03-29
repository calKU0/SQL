USE [CDNXL_TESTOWA_B2B]
--EXEC ldd.BudzetyRabatoweNadaj 960,2014861,2830
GO
/****** Object:  StoredProcedure [dbo].[GaskaNadajBudzet]    Script Date: 27.10.2023 10:28:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Krzysztof Kurowski
-- Create date: 27.10.2023
-- Description:	Procedura nadajaca budzet kontrahenta lub operatora na zamowieniu
-- =============================================
ALTER PROCEDURE [ldd].[BudzetyRabatoweNadaj]
(
@DokTyp int
,@DokNumer int
,@PromoId int
)
AS
BEGIN
--------------- Deklaracja zmiennych -------------
DECLARE @RabatProcent decimal (5,2)
DECLARE @RabatSuma decimal (15,2) = 0
DECLARE @Rabat decimal (15,2)
DECLARE @WartoscPoRabacie decimal (15,2)
DECLARE @Lp int
DECLARE @TwrTyp int
DECLARE @TwrNumer int
DECLARE @Magazyn int
DECLARE @KntTyp int
DECLARE @KntNumer int
DECLARE @FormaNr int
DECLARE @DokCennikNumer int
DECLARE @FormaTermin int
DECLARE @PrmId int
DECLARE @ElementLp int
DECLARE @ElementNumer int
DECLARE @ElementCena decimal (15,2)
DECLARE @ElementWartosc decimal (15,2)
DECLARE @ElementRabat decimal (5,2)
DECLARE @ElementIlosc int
DECLARE @WartoscZamNetto decimal (15,2)
DECLARE @WartoscVat decimal (15,2)
DECLARE @Waluta varchar (3)
DECLARE @TprId int
DECLARE @IdBudzetu int
DECLARE @SposobDostawy int
DECLARE @Kurs decimal (12,2)
DECLARE @UpustId int
DECLARE @Typ int
DECLARE @OpeNumer int = 589
DECLARE @DokFirma int = 449892
DECLARE @Data bigint = cdn.DateToTS(GETDATE())
DECLARE @FormaData int = DATEDIFF(DD,'18001228',GETDATE())
DECLARE @FrsId varchar (30) = '772,10,5,1'
-------------------------------------------------

	SET NOCOUNT ON;
	-- Wypełniamy stale zmienne dla podanego zamowienia
	SET @Magazyn = (SELECT ZaN_MagNumer FROM cdn.ZamNag WHERE ZaN_GIDNumer = @DokNumer and ZaN_GIDTyp = @DokTyp)
	SET @FormaNr = (SELECT ZaN_FormaNr FROM cdn.ZamNag WHERE ZaN_GIDNumer = @DokNumer and ZaN_GIDTyp = @DokTyp)
	SET @KntTyp = (SELECT ZaN_KntTyp FROM cdn.ZamNag WHERE ZaN_GIDNumer = @DokNumer and ZaN_GIDTyp = @DokTyp)
	SET @KntNumer = (SELECT ZaN_KntNumer FROM cdn.ZamNag WHERE ZaN_GIDNumer = @DokNumer and ZaN_GIDTyp = @DokTyp)
	SET @DokCennikNumer = (SELECT ZaN_CenaSpr FROM cdn.ZamNag WHERE ZaN_GIDNumer = @DokNumer and ZaN_GIDTyp = @DokTyp)
	SET @FormaTermin = (SELECT ZaN_TerminPlatnosci FROM cdn.ZamNag WHERE ZaN_GIDNumer = @DokNumer and ZaN_GIDTyp = @DokTyp)
	SET @Waluta = (SELECT ZaN_Waluta FROM cdn.ZamNag WHERE ZaN_GIDTyp = @DokTyp AND ZaN_GIDNumer = @DokNumer)
	SET @SposobDostawy = (SELECT SLW_WartoscL1 FROM cdn.Slowniki JOIN cdn.ZamNag on SLW_WartoscS = ZaN_SpDostawy WHERE ZaN_GIDNumer = @DokNumer and ZaN_GIDTyp = @DokTyp)
	SET @Kurs = isnull((SELECT TOP 1 WaE_KursL / WaE_KursM FROM cdn.WalNag with (nolock) JOIN cdn.WalElem with (nolock) on WaN_Symbol=WaE_Symbol where WaN_Symbol = @Waluta and WaE_Lp = 4 order by WaE_KursTS desc),1)
	
	-- Tworzymy i wypelniamy tabele z budzetami dostepnymi dla zamowienia
	CREATE TABLE #Budzety 
	(
		NazwaBudzetu varchar (50)
		,TypS varchar (50)
		,Akronim varchar (50)
		,WartoscMax decimal (15,4)
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
	EXEC CDN.PRMZwrocBudzetyRabatoweDlaDokumentu @p_DokTyp=@DokTyp, @p_DokNumer=@DokNumer, @p_OpeNumer=@OpeNumer, @p_KntTyp=@KntTyp, @p_KntNumer=@KntNumer, @p_Data=@Data, @p_FormaNr=@FormaNr, @p_FormaTermin=@FormaTermin, @p_FormaData=@FormaData, @p_SposobDostawy=@SposobDostawy, @p_Magazyn=@Magazyn, @p_FrsId=@FrsId
	IF EXISTS (SELECT * FROM #Budzety WHERE TypId = 9 and PrmId = @PrmId)
	BEGIN
		UPDATE #Budzety SET
		WartoscMax = (SELECT Opm_Wartosc FROM cdn.OpePromocje WHERE OPm_PrmId = PrmId and Id = OPm_Id)
		WHERE TypId = 9 and PrmId = @PromoId
	END

	-- Otwieramy cursor na kazdą pozycje z zamowienia
	DECLARE Cursor_ElementyZam CURSOR FOR
	SELECT ZaE_GIDLp, ZaE_TwrNumer ,ZaE_TwrTyp FROM cdn.ZamElem WHERE ZaE_GIDNumer = @DokNumer
	OPEN Cursor_ElementyZam
	FETCH NEXT FROM Cursor_ElementyZam
	INTO @Lp, @TwrNumer, @TwrTyp -- Uzupelniamy zmienne dynamiczne dla pierwszej pozycji

	-- Tworzymy i wypelniamy tabele z cena poczatkowa dla pierwszej pozycji
	CREATE TABLE #CenaPoczatkowa
	(
		CenaLp smallint
		,CenaPocz decimal (15,4)
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
	EXEC CDN.CenaPoczatkowa @GIDTyp = 9472, @GIDNumer = @DokNumer, @GIDLp = @Lp, @Data = @Data, @KntTyp = @KntTyp, @KntNumer = @KntNumer, @FrsId =@FrsId, @TwrTyp = @TwrTyp, @TwrNumer = @TwrNumer, @CennikNumer= -1, @DokCennikNumer = @DokCennikNumer, @FormaNr = @FormaNr, @FormaTermin = @FormaTermin, @FormaData=0, @SposobDostawy = @SposobDostawy, @Magazyn=@Magazyn, @RodzajDok = 1, @ZstNumer  = 0

	-- Tworzymy i wypelniamy tabele z budzetami dla pierwszej pozycji
	CREATE TABLE #MacierzRabatowa
	(
		PrmId int
		,PrmAkronim varchar (50)
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
	EXEC CDN.MacierzRabatowaPozycje  @lNagPoz= 2, @lRodzajDok= 1, @lData = @Data, @lKntTyp = @KntTyp, @lKntNumer = @KntNumer, @lTwrTyp = @TwrTyp, @lTwrNumer = @TwrNumer, @lFormaNr = @FormaNr, @lFormaTermin = @FormaTermin, @lFormaData = 0, @lSposobDostawy = @SposobDostawy, @lMagazyn = @Magazyn, @sFrsId=@FrsId, @lZstNumer=0, @lGIDTyp=9472, @lGIDNumer = @DokNumer, @lGIDLp = @Lp, @lPromocjaID=0, @lPromocjaProgID=0, @lPromocjaWTRID=0, @lProgWTRID=0, @sDsts=''

	WHILE @@FETCH_STATUS = 0 -- Petla elementow na zamowieniu
	BEGIN
		DECLARE Cursor_RabatyNaPozycje CURSOR FOR
		SELECT #MacierzRabatowa.PrmId, TprId, UpustId, PrmTyp FROM #MacierzRabatowa JOIN #Budzety on UpustId = Id WHERE PrmTyp in (10,9) and #MacierzRabatowa.PrmId in (@PromoId)
		OPEN Cursor_RabatyNaPozycje
		FETCH NEXT FROM Cursor_RabatyNaPozycje
		INTO @PrmId, @TprId, @UpustId, @Typ -- Uzupelniamy zmienne dynamiczne dla pierwszej pozycji
		SET @IdBudzetu = (SELECT Id FROM #Budzety WHERE PrmId = @PrmId)
		
		WHILE @@FETCH_STATUS = 0 -- Petla budzetow dla elementu zamowienia
		BEGIN
			IF EXISTS (SELECT * FROM #MacierzRabatowa) AND (SELECT (WartoscMax - Wykorzystana - NaliczonaSys) / @Kurs FROM #Budzety where PrmId = @PrmId) > 0 -- Dopóki nie skończą sie pozycje i nie zostanie wykorzystany budzet
			BEGIN
				-- Wypelniamy zmienne z aktualnymi rabatami i cenami na zamowieniu (przed naliczeniem budżetu)
				SET @ElementLp = (SELECT ZaE_TwrLp FROM cdn.ZamElem WHERE ZaE_GIDNumer = @DokNumer AND ZaE_GIDTyp = @DokTyp and ZaE_GIDLp = @Lp)
				SET @ElementNumer = (SELECT ZaE_TwrNumer FROM cdn.ZamElem WHERE ZaE_GIDNumer = @DokNumer AND ZaE_GIDTyp = @DokTyp and ZaE_GIDLp = @Lp)
				SET @ElementCena = (SELECT ZaE_CenaUzgodniona FROM cdn.ZamElem WHERE ZaE_GIDNumer = @DokNumer AND ZaE_GIDTyp = @DokTyp and ZaE_GIDLp = @Lp)
				SET @ElementWartosc = (SELECT Zae_WartoscPoRabacie FROM cdn.ZamElem WHERE ZaE_GIDNumer = @DokNumer AND ZaE_GIDTyp = @DokTyp and ZaE_GIDLp = @Lp)
				SET @ElementRabat = (SELECT ZaE_Rabat FROM cdn.ZamElem WHERE ZaE_GIDNumer = @DokNumer AND ZaE_GIDTyp = @DokTyp and ZaE_GIDLp = @Lp)
				SET @ElementIlosc =  (SELECT ZaE_Ilosc FROM cdn.ZamElem WHERE ZaE_GIDNumer = @DokNumer AND ZaE_GIDTyp = @DokTyp and ZaE_GIDLp = @Lp)

				-- Wyliczanie rabatu
				-- a) Jeśli maksymalny rabat procentowy przekracza pozostaly budzet
				IF (SELECT case when UpustTyp = 1 then CenaPocz*@ElementIlosc*(UpustWartosc/100) else UpustWartosc / @Kurs end FROM #MacierzRabatowa join #CenaPoczatkowa on 1=1 where PrmId = @PrmId and UpustId = @IdBudzetu) >= (SELECT (WartoscMax - Wykorzystana - NaliczonaSys) / @Kurs FROM #Budzety WHERE PrmId = @PrmId)
				BEGIN
					SET @RabatProcent = (SELECT case when UpustTyp = 1 then @ElementRabat + (100*(CenaPocz*@ElementIlosc - (CenaPocz*@ElementIlosc-(WartoscMax - Wykorzystana - NaliczonaSys)))/(CenaPocz*@ElementIlosc)) else @ElementRabat + (100*(CenaPocz*@ElementIlosc - (CenaPocz*@ElementIlosc- UpustWartosc))/(CenaPocz*@ElementIlosc)) end FROM #CenaPoczatkowa join #Budzety b on 1=1 join #MacierzRabatowa m on m.PrmId = b.PrmId where b.PrmId = @PrmId and UpustId = @IdBudzetu) -- Obliczamy procentowa wartosc rabatu poprzez odjecie ceny poczatkowej od ceny po rabacie budzetowym i podzieleniu tej roznicy przez cene poczatkowa
					SET @Rabat = (SELECT (WartoscMax - Wykorzystana - NaliczonaSys) / @Kurs FROM #Budzety b join #MacierzRabatowa m on b.PrmId = m.PrmId WHERE b.PrmId = @PrmId and UpustId = @IdBudzetu) -- Odejmujemy maksymalna wartosc rabatu z wykorzystanym juz rabatem
					SET @WartoscPoRabacie = @ElementCena - (@Rabat / @ElementIlosc) -- Odejmujemy cene przed naliczeniem budzetu z wartoscia rabatu dla jednej sztuki
					
					UPDATE CDN.ZamElem SET 
					ZaE_Rabat = @RabatProcent
					,ZaE_CenaUzgodniona = @WartoscPoRabacie
					,ZaE_WartoscPoRabacie = @WartoscPoRabacie * @ElementIlosc 
					,ZaE_RabatPromocyjny = @RabatProcent
					WHERE ZaE_GIDTyp = @DokTyp AND ZaE_GIDNumer = @DokNumer AND ZaE_GIDLp = @Lp

					-- Aktualizujemy cdn.prmhistoria o wyliczone wartosci
					DELETE FROM cdn.prmhistoria WHERE PrH_GIDTyp = @DokTyp and PrH_GIDNumer = @DokNumer and PrH_GIDLp = @Lp and PrH_IDPrm = @PrmId
					INSERT INTO CDN.PrmHistoria (PrH_GIDTyp, PrH_GIDFirma, PrH_GIDNumer, PrH_GIDLp, PrH_IDPrm, PrH_RabatKwota, PrH_RabatProcent, PrH_RodzajRabatu, PrH_RabatKwotaDokl, PrH_RabatEfektywny,PrH_BudzetId,PRH_TPRID)  values(@DokTyp, @DokFirma, @DokNumer, @Lp, @PrmId, @Rabat, @RabatProcent, 40977, @Rabat*@Kurs, @RabatProcent, @IDBudzetu, @TprId )	
					SET @RabatSuma += @Rabat		
				END
				-- b) Jesli rabat procentowy miesci się w pozostałym do wykorzystania budzecie
				ELSE
				BEGIN
					SET @RabatProcent = (SELECT case when UpustTyp = 1 then @ElementRabat + UpustWartosc else @ElementRabat + (100*(CenaPocz*@ElementIlosc - (CenaPocz*@ElementIlosc- UpustWartosc))/(CenaPocz*@ElementIlosc)) end FROM #MacierzRabatowa m join #Budzety b join #CenaPoczatkowa on 1=1 on m.PrmId = b.PrmId WHERE m.PrmId = @PrmId and UpustId = @IdBudzetu) -- Dodajemy obowiazujacy rabat przed naliczeniem budzetu procentowym rabatem budzetu
					SET @Rabat = (SELECT case when UpustTyp = 1 then (CenaPocz*@ElementIlosc*(UpustWartosc/100)) / @Kurs else UpustWartosc / @Kurs end from #CenaPoczatkowa join #MacierzRabatowa on PrmId = @PrmId and UpustId = @IdBudzetu) -- Mnozymy wartosc poczatkowa z procentowym rabatem
					SET @WartoscPoRabacie = @ElementCena - (@Rabat / @ElementIlosc) -- Odejmujemy cene przed naliczeniem budzetu z wartoscia rabatu dla jednej sztuki
					
					UPDATE CDN.ZamElem SET 
					ZaE_Rabat = @RabatProcent
					,ZaE_CenaUzgodniona = @WartoscPoRabacie 
					,ZaE_WartoscPoRabacie = @WartoscPoRabacie * @ElementIlosc
					,ZaE_RabatPromocyjny = @RabatProcent
					WHERE ZaE_GIDTyp = @DokTyp AND ZaE_GIDNumer = @DokNumer AND ZaE_GIDLp = @Lp

					-- Aktualizujemy cdn.prmhistoria o wyliczone wartosci
					DELETE FROM cdn.prmhistoria WHERE PrH_GIDTyp = @DokTyp and PrH_GIDNumer = @DokNumer and PrH_GIDLp = @Lp and PrH_IDPrm = @PrmId
					INSERT INTO CDN.PrmHistoria (PrH_GIDTyp, PrH_GIDFirma, PrH_GIDNumer, PrH_GIDLp, PrH_IDPrm, PrH_RabatKwota, PrH_RabatProcent, PrH_RodzajRabatu, PrH_RabatKwotaDokl, PrH_RabatEfektywny,PrH_BudzetId,PRH_TPRID)  values(@DokTyp, @DokFirma, @DokNumer, @Lp, @PrmId, @Rabat, @RabatProcent, 40977, @Rabat*@Kurs, @RabatProcent, @IDBudzetu, @TprId )	
					SET @RabatSuma += @Rabat
				END
			END
			FETCH NEXT FROM Cursor_RabatyNaPozycje -- Jesli na towar jest wiecej niz 1 rabat, to cofamy sie do poczatku petli i dodajemy rabat, jesli nie to idziemy do nowej pozycji
			INTO @PrmId, @TprId, @UpustId, @Typ
			SET @IdBudzetu = (SELECT Id FROM #Budzety WHERE #Budzety.PrmId = @PrmId)
		END -- Koniec petli na rabatach elementu zamowienia
		
		CLOSE Cursor_RabatyNaPozycje
		DEALLOCATE Cursor_RabatyNaPozycje

		FETCH NEXT FROM Cursor_ElementyZam
		INTO @Lp, @TwrNumer, @TwrTyp -- Uzupełniamy zmienne dynamiczne dla następnego elementu zamowienia
			
		-- Aktualizujemy tabele o dane dla nowej pozycji
		DELETE FROM #MacierzRabatowa
		INSERT INTO #MacierzRabatowa
		EXEC CDN.MacierzRabatowaPozycje  @lNagPoz= 2, @lRodzajDok= 1, @lData = @Data, @lKntTyp = @KntTyp, @lKntNumer = @KntNumer, @lTwrTyp = @TwrTyp, @lTwrNumer = @TwrNumer, @lFormaNr = @FormaNr, @lFormaTermin = @FormaTermin, @lFormaData = 0, @lSposobDostawy = @SposobDostawy, @lMagazyn = @Magazyn, @sFrsId = @FrsId, @lZstNumer=0, @lGIDTyp=9472, @lGIDNumer = @DokNumer, @lGIDLp = @Lp, @lPromocjaID=0, @lPromocjaProgID=0, @lPromocjaWTRID=0, @lProgWTRID=0, @sDsts=''

		DELETE FROM #CenaPoczatkowa
		INSERT INTO #CenaPoczatkowa
		EXEC CDN.CenaPoczatkowa @GIDTyp = 9472, @GIDNumer = @DokNumer, @GIDLp = @Lp, @Data = @Data, @KntTyp = @KntTyp, @KntNumer = @KntNumer, @FrsId = @FrsId, @TwrTyp = @TwrTyp, @TwrNumer = @TwrNumer, @CennikNumer= -1, @DokCennikNumer = @DokCennikNumer, @FormaNr = @FormaNr, @FormaTermin = @FormaTermin, @FormaData=0, @SposobDostawy = @SposobDostawy, @Magazyn=@Magazyn, @RodzajDok = 1, @ZstNumer  = 0

		DELETE FROM #Budzety
		INSERT INTO #Budzety
		EXEC CDN.PRMZwrocBudzetyRabatoweDlaDokumentu @p_DokTyp = @DokTyp, @p_DokNumer = @DokNumer, @p_OpeNumer = @OpeNumer, @p_KntTyp = @KntTyp, @p_KntNumer = @KntNumer, @p_Data = @Data, @p_FormaNr = @FormaNr, @p_FormaTermin = @FormaTermin, @p_FormaData = @FormaData, @p_SposobDostawy = @SposobDostawy, @p_Magazyn = @Magazyn, @p_FrsId = @FrsId
		IF EXISTS (SELECT * FROM #Budzety WHERE TypId = 9 and PrmId = @PrmId)
		BEGIN
			UPDATE #Budzety SET
			WartoscMax = (SELECT Opm_Wartosc FROM cdn.OpePromocje WHERE OPm_PrmId = PrmId and Id = OPm_Id)
			WHERE TypId = 9 and PrmId = @PromoId
		END	
	END -- Koniec petli na elementach zamowienia
	CLOSE Cursor_ElementyZam
	DEALLOCATE Cursor_ElementyZam
	
	-- Zrzucamy tabele tymczasowe
	DROP TABLE #CenaPoczatkowa
	DROP TABLE #MacierzRabatowa

	-- Aktualizujemy ZamVat po zaktualizowaniu cen na pozycjach
	SET @WartoscZamNetto = (SELECT sum(ZaE_WartoscPoRabacie) FROM cdn.ZamElem WHERE ZaE_GIDTyp = @DokTyp AND ZaE_GIDNumer = @DokNumer)
	SET @WartoscVat = (SELECT sum(ZaE_WartoscPoRabacie) * 0.23 FROM cdn.ZamElem WHERE ZaE_GIDTyp = @DokTyp AND ZaE_GIDNumer = @DokNumer)
	
	UPDATE CDN.ZamVat SET
	ZaV_Netto = @WartoscZamNetto 
	,ZaV_Vat = @WartoscVat
	WHERE ZaV_GIDTyp = @DokTyp AND ZaV_GIDNumer = @DokNumer AND ZaV_Waluta = @Waluta AND ZaV_StawkaPod = 23.00 AND ZaV_FlagaVat = 1

	-- Wyswietlamy naliczony budzet i zrzucamy ostatnia tabele tymczasowa
	SELECT @PrmId as IdPromocji, (SELECT NazwaBudzetu FROM #Budzety where @PrmId = PrmId) as NazwaBudzetu,  @RabatSuma as RabatKwota, @Waluta as Waluta
	DROP TABLE #Budzety
END