SET NOCOUNT ON;

DECLARE @GidTowaru INT;

DECLARE twrList CURSOR FORWARD_ONLY FOR
SELECT Twr_GIDNumer
FROM cdn.TwrKarty WITH (NOLOCK)
WHERE Twr_Archiwalny = 0 
AND Twr_Typ IN (1,2)
AND Twr_GIDNumer IN (SELECT TrE_TwrNumer FROM cdn.TraElem WITH (NOLOCK))
ORDER BY Twr_GIDNumer ASC;

OPEN twrList;
FETCH NEXT FROM twrList INTO @GidTowaru;

BEGIN
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @IloscPozycji INT;
        DECLARE @CenaSrednioWazona DECIMAL(15,2);
        DECLARE @ExistingCena DECIMAL(15,2);
        
        SELECT @IloscPozycji = COUNT(TwZ_DstNumer)
        FROM cdn.twrzasoby WITH (NOLOCK)
        JOIN cdn.dostawy WITH (NOLOCK) ON Dst_GIDNumer = TwZ_DstNumer
        WHERE @GidTowaru = TwZ_TwrNumer AND TwZ_MagNumer = 1;

        IF (@IloscPozycji > 0)
        BEGIN
            SELECT @CenaSrednioWazona = ISNULL(SUM(TwZ_KsiegowaNetto), 0) / 
                CASE WHEN ISNULL(SUM(TwZ_Ilosc), 0) = 0 THEN 1 ELSE SUM(TwZ_Ilosc) END
            FROM cdn.twrzasoby WITH (NOLOCK)
            JOIN cdn.dostawy WITH (NOLOCK) ON Dst_GIDNumer = TwZ_DstNumer
            JOIN cdn.tranag WITH (NOLOCK) ON TrN_GIDTyp = Dst_TrnTyp AND TrN_GIDNumer = Dst_TrnNumer
            WHERE @GidTowaru = TwZ_TwrNumer AND TwZ_MagNumer = 1;
        END
        ELSE
        BEGIN
            SELECT TOP 1 @CenaSrednioWazona = TrE_Cena
            FROM cdn.tranag WITH (NOLOCK)
            JOIN cdn.traelem WITH (NOLOCK) ON TrN_GIDTyp = TrE_GIDTyp AND TrN_GIDNumer = TrE_GIDNumer
            WHERE TrE_TwrNumer = @GidTowaru
            AND (TrN_GIDTyp IN (1521, 1490) OR (TrN_GIDTyp = 1617 AND TrN_TrNSeria = 'PROD'))
            AND TrN_Stan > 3
            ORDER BY TrN_Data2 DESC;
        END  

        UPDATE [ExpertWMS_Gaska_Produkcja].[dbo].[twrstanymaksymalne]
        SET TSM_CenaKatalogowa = ISNULL(@CenaSrednioWazona, 0) 

		FROM [ExpertWMS_Gaska_Produkcja].[dbo].[twrstanymaksymalne]
		join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_exp_towaryp] on TSM_TwrNumer = etp_twrid

        WHERE etp_sysid = @GidTowaru;
        
        FETCH NEXT FROM twrList INTO @GidTowaru;
    END
END

CLOSE twrList;
DEALLOCATE twrList;