USE [CDNXL_GASKA]
GO
/****** Object:  Trigger [CDN].[GASKA_DaneBinarne_DodawanieAtrybutuNaObiektach]    Script Date: 2023.09.04 13:21:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER TRIGGER [CDN].[GASKA_DaneBinarne_DodawanieAtrybutuNaObiektach]
   ON  [CDNXL_GASKA].[CDN].[DaneBinarne]
   FOR INSERT, update
AS 
BEGIN
SET NOCOUNT ON
if update(dab_nazwa)
begin
	DECLARE @GrupaZałącznika varchar(50)
	DECLARE @GIDZałącznika INT
	DECLARE @GIDObiektu INT
DECLARE Cursor_Obiekty CURSOR FOR
SELECT DBG_Nazwa
	,i.DAB_ID
	,DAO_ObiNumer	
	FROM inserted i
	join cdn.DaneBinarneGrupy on DBG_Id=i.DAB_DBGId
	join cdn.DaneObiekty on i.DAB_ID=DAO_DABId

OPEN Cursor_Obiekty
FETCH NEXT FROM Cursor_Obiekty
INTO @GrupaZałącznika, @GIDZałącznika, @GIDObiektu
WHILE @@FETCH_STATUS = 0 and @GrupaZałącznika = 'Oświadczenia wywozowe' and not exists (Select * from cdn.Atrybuty where Atr_AtkId = 82 and Atr_ObiNumer = @GIDObiektu) -- Dopóki nie skończą się wiersze i grupa załącznika to oświadczenia wywozowe i nie ma już atrybutu typ-potwierdzenia
BEGIN
  	INSERT INTO cdn.Atrybuty -- Wrzuca nowy rekord to tabeli atrybutów do każdego podpiętego obiektu z załącznika
		([Atr_ObiTyp]
		,[Atr_ObiFirma]
		,[Atr_ObiNumer]
		,[Atr_ObiLp]
		,[Atr_ObiSubLp]
		,[Atr_AtkId]
		,[Atr_Wartosc]
		,[Atr_AtrTyp]
		,[Atr_AtrFirma]
		,[Atr_AtrNumer]
		,[Atr_AtrLp]
		,[Atr_AtrSubLp])
		VALUES
		(2037,449892,@GIDObiektu,0,0,82,1,0,0,0,0,0), -- Typ potwierdzenia
		(2037,449892,@GIDObiektu,0,0,80,DATEDIFF(DD,'18001228',GETDATE()),0,0,0,0,0), -- Data wprowadzenie
		(2037,449892,@GIDObiektu,0,0,81,DATEDIFF(DD,'18001228',GETDATE()),0,0,0,0,0) -- Data wplyniecie

		Update cdn.Atrybuty set Atr_Wartosc = 'Oświadczenie' where Atr_ObiNumer = @GIDObiektu and Atr_AtkId = 82

	FETCH NEXT FROM Cursor_Obiekty
	INTO @GrupaZałącznika, @GIDZałącznika, @GIDObiektu
END
CLOSE Cursor_Obiekty
DEALLOCATE Cursor_Obiekty
SET NOCOUNT OFF
END
end
