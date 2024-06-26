USE [CDNXL_GASKA]
GO
/****** Object:  Trigger [CDN].[Gaska_TraNag_UpdateAtrybutu_Sorter]    Script Date: 16.05.2024 08:13:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [CDN].[Gaska_TraNag_UpdateAtrybutu_Sorter]
   ON [CDN].[TraNag]
   AFTER INSERT, UPDATE
AS 
BEGIN
declare @trnTyp int = (select trn_gidtyp from inserted);
declare @trnGid int = (select trn_gidnumer from inserted);
	SET NOCOUNT ON;

	
    IF (
		select sum(tre_ilosc * 
		case when Twr_WymJm = 'mm' then twr_objetoscl / 1000000000 
		when Twr_WymJm = 'cm' then twr_objetoscl / 1000000
		when Twr_WymJm = 'dm' then twr_objetoscl / 1000
		else twr_objetoscl
		end) 
		from cdn.TraNag
		join cdn.TraElem on TrN_GIDNumer = TrE_GIDNumer
		join cdn.TwrKarty on Twr_GIDNumer = TrE_TwrNumer

		where TrN_GIDNumer = @trnGid and trn_gidTyp = @trnTyp) >= 0.22275
	BEGIN 
		Update cdn.Atrybuty
		SET Atr_Wartosc = 'NIE'
		where atr_obinumer = @trnGid and atr_obityp = @trnTyp
		and atr_atkid = 374
	END
END
