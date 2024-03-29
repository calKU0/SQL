USE [CDNXL_GASKA]
GO
/****** Object:  Trigger [CDN].[Gaska_KntKarty_WymuszajTylkoCyfryWNumerachTelefonu]    Script Date: 28.02.2024 10:54:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER TRIGGER [CDN].[Gaska_KntKarty_WymuszajTylkoCyfryWNumerachTelefonu]
   ON  [CDN].[KntKarty] 
   AFTER update, insert
AS 
SET NOCOUNT ON;

IF UPDATE (Knt_Telefon1) -- Jeśli update Pola Telefon1
BEGIN
DECLARE @phone varchar(100) = (select Knt_Telefon1 as telefon from inserted)
DECLARE @phoneValid varchar(100)

SET @phoneValid = REPLACE(@phone,'+','')

IF SUBSTRING(@phoneValid,3,1) = ' '
BEGIN
	SET @phoneValid = STUFF(@phoneValid,3,1,'') 
END

IF (ISNUMERIC(@phoneValid) = 0) and (@phone) <> ''  -- Jeśli wpisany ciag znaków nie jest liczbą
	BEGIN
		declare @komunikat1 varchar(1000)
		set @komunikat1='#CDN_BLAD/# #CDN_1=Nie można zapisać. Powód: Pole Telefon1 musi być w jednym z następujacych formatów +yy xxxxxxxxx, +yyxxxxxxxxx lub xxxxxxxxx gdzie x - numer kierunkowy, y - numer telefonu'  + '#CDN_2=(Blokada założona przez dział IT) /# #CDN_3=Brak/#'
		RAISERROR(@komunikat1,16,1)
		rollback tran
		return
	END
END

IF UPDATE (Knt_Telefon2) -- Jeśli update Pola Telefon2
BEGIN
DECLARE @phone2 varchar(100) = (select Knt_Telefon2 as telefon from inserted)
DECLARE @phoneValid2 varchar(100)

SET @phoneValid = REPLACE(@phone,'+','')

IF SUBSTRING(@phoneValid,3,1) = ' '
BEGIN
	SET @phoneValid = STUFF(@phoneValid,3,1,'') 
END

IF (ISNUMERIC(@phoneValid) = 0) and (@phone) <> ''  -- Jeśli wpisany ciag znaków nie jest liczbą
	BEGIN
		declare @komunikat2 varchar(1000)
		set @komunikat1='#CDN_BLAD/# #CDN_1=Nie można zapisać. Powód: Pole Telefon2 musi być w jednym z następujacych formatów +yy xxxxxxxxx, +yyxxxxxxxxx lub xxxxxxxxx gdzie x - numer kierunkowy, y - numer telefonu'  + '#CDN_2=(Blokada założona przez dział IT) /# #CDN_3=Brak/#'
		RAISERROR(@komunikat2,16,1)
		rollback tran
		return 
	END
END

IF UPDATE (Knt_Email) --Jeśli update Emaila
BEGIN
	IF (select knt_email from inserted) like ('%;%') or (select knt_email from inserted) like ('%,%') --Jeśli email ma w sobie ';' lub ','
	BEGIN
		declare @komunikat3 varchar(1000)
		set @komunikat3='#CDN_BLAD/# #CDN_1=Użyto niedozwolonego znaku w polu Email! '  + '#CDN_2=(Blokada założona przez dział IT) /# #CDN_3=Brak/#'
		RAISERROR(@komunikat3,16,1)
		rollback tran
		return 
	END
END

IF UPDATE (Knt_EFaVatEmail) --Jeśli update Emaila do Efaktury
BEGIN
	IF (select Knt_EFaVatEmail from inserted) like '%,%' --Jeśli email ma w sobie ','
	BEGIN
		declare @komunikat4 varchar(1000)
		set @komunikat4='#CDN_BLAD/# #CDN_1=Użyto niedozwolonego znaku w polu E-faktura Email! '  + '#CDN_2=(Blokada założona przez dział IT) /# #CDN_3=Brak/#'
		RAISERROR(@komunikat4,16,1)
		rollback tran
		return 
	END
END

