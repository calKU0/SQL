USE [CDNXL_GASKA]
GO
/****** Object:  Trigger [CDN].[Gaska_TraNag_BlokadaPrzelewuEOM]    Script Date: 2025-04-01 15:06:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER TRIGGER [CDN].[Gaska_TraNag_BlokadaPrzelewuEOM]
   ON  [CDN].[TraNag] 
   AFTER UPDATE
   AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @GIDNUMER INT
	DECLARE @GIDTYP INT
	DECLARE @OpeNumer int;

	DECLARE @FormaNazwa VARCHAR(50)
	DECLARE @TrPTermin int;
	DECLARE @TrNTermin int;
	IF UPDATE(TRN_STAN)
	BEGIN  
		SELECT
		@GIDNUMER = i.trn_gidnumer,
		@GIDTYP = i.trn_gidtyp,
		@FormaNazwa = i.TrN_FormaNazwa,
		@TrNTermin = i.TrN_Termin,
		@TrPTermin = TrP_Termin,
		@OpeNumer = i.TrN_OpeNumerW
				  
		FROM
		inserted i
		join cdn.TraPlat with(nolock) on i.TrN_GIDNumer = TrP_GIDNumer
   
		IF @GIDTYP IN (2033,2037,2001,2005)
		BEGIN 
			IF (case when @FormaNazwa = 'Przelew EOM' AND (DATEADD(DAY,@TrNTermin,'18001228') <> EOMONTH(DATEADD(DAY,@TrNTermin,'18001228')) OR DATEADD(DAY,@TrPTermin,'18001228') <> EOMONTH(DATEADD(DAY,@TrPTermin,'18001228'))) then 1 else 0 end) = 1 AND @OpeNumer <> 423
			BEGIN
				declare @kom1 varchar(1000)
				set @kom1='#CDN_BLAD/# #CDN_1=Nie można zapisać dokumentu, powód: forma płatności Przelew EOM musi mieć termin płatności ustawiony na ostatni dzień miesiąca. Ustaw datę na ' + CONVERT(VARCHAR(10), EOMONTH(DATEADD(DAY, @TrNTermin, '18001228')), 120)  +' i spróbuj ponownie '  + '#CDN_2=(Blokada założona przez dział IT) /# #CDN_3=Brak/#'
				RAISERROR(@kom1,16,1)
				rollback tran
				return
			END
			ELSE IF (case when @FormaNazwa = 'Przelew EOM' AND (DATEADD(DAY,@TrNTermin,'18001228') <> EOMONTH(DATEADD(DAY,@TrNTermin,'18001228')) OR DATEADD(DAY,@TrPTermin,'18001228') <> EOMONTH(DATEADD(DAY,@TrPTermin,'18001228'))) then 1 else 0 end) = 1 AND @OpeNumer = 423
			BEGIN
				UPDATE cdn.TraNag 
				SET TrN_Termin = DATEDIFF(DAY,'18001228',EOMONTH(DATEADD(DAY,@TrNTermin,'18001228')))
				WHERE TrN_GIDNumer = @GIDNUMER

				UPDATE cdn.TraPlat
				SET TrP_Termin = DATEDIFF(DAY,'18001228',EOMONTH(DATEADD(DAY,@TrNTermin,'18001228')))
				,TrP_MaksymalnyTermin = DATEDIFF(DAY,'18001228',EOMONTH(DATEADD(DAY,@TrNTermin,'18001228')))
				,TrP_SpodziewanyTermin = DATEDIFF(DAY,'18001228',EOMONTH(DATEADD(DAY,@TrNTermin,'18001228')))
				WHERE TrP_GIDNumer = @GIDNUMER
			END
		END
	END
END
