USE [CDNXL_TESTOWA_B2B]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [CDN].[Gaska_TraNag_BlokadaKorektyZRoznymiDostawami]
   ON  [CDN].[TraNag]
   AFTER UPDATE, INSERT
AS 
BEGIN
SET NOCOUNT ON;
IF UPDATE(Trn_Stan)
BEGIN
		IF (select trn_gidtyp from inserted) in (1498) and (select trn_stan from inserted) = 5
		BEGIN
			DECLARE @stop int = 0
			DECLARE SprawdzDostawe_Cursor CURSOR
			FOR select distinct case when dostawaKorygowana <> dostawaKorekta then 1 else 0 end 
			from (select distinct 
			zrdSElem.TrS_DstNumer as [dostawaKorygowana]
			,korSElem.TrS_DstNumer as [dostawaKorekta]
			from inserted i
			join cdn.TraElem korElem on TrN_GIDNumer = korElem.TrE_GIDNumer
			join cdn.TraSElem korSElem on korElem.TrE_GIDNumer=korSElem.TrS_GIDNumer AND korElem.TrE_GIDLp=korSElem.TrS_GIDLp
			join cdn.TraElem zrdElem on TrN_ZwrNumer = zrdElem.TrE_GIDNumer and TrN_ZwrTyp = zrdElem.TrE_GIDTyp and zrdElem.TrE_TwrNumer = korElem.TrE_TwrNumer
			join cdn.TraSElem zrdSElem on zrdElem.TrE_GIDNumer=zrdSElem.TrS_GIDNumer AND zrdElem.TrE_GIDLp=zrdSElem.TrS_GIDLp
			where korElem.TrE_GIDTyp=i.TrN_GIDTyp AND korElem.TrE_GIDFirma=i.TrN_GIDFirma AND korElem.TrE_GIDNumer=i.trn_gidnumer) podzapytanie
			OPEN SprawdzDostawe_Cursor;
			FETCH NEXT FROM SprawdzDostawe_Cursor INTO @stop;
			WHILE @@FETCH_STATUS = 0
				BEGIN
				IF @stop = 1
				BEGIN BREAK END
				FETCH NEXT FROM SprawdzDostawe_Cursor INTO @stop;
			END
			CLOSE SprawdzDostawe_Cursor;
			DEALLOCATE SprawdzDostawe_Cursor;

			IF @stop = 1
			BEGIN 					
				declare @kom1 varchar(1000)
				set @kom1='#CDN_BLAD/# #CDN_1=Nie można zapisać dokumentu, powód: Brak zasobu na magazynach z wybranej dostawy. Wybierz inną dostawę lub skoryguj fakturę wartościowo'  + '#CDN_2=(Blokada założona przez dział IT) /# #CDN_3=Brak/#'
				RAISERROR(@kom1,16,1)
				rollback tran
				return 
			END
		END
	END
END
