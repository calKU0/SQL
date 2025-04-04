USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [kkur].[WMSPobierzDostawcowTowaru]    Script Date: 2025-04-01 14:56:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [kkur].[WMSPobierzDostawcowTowaru]
@GidNumer int,
@GidTyp int
AS
BEGIN
	SET NOCOUNT ON;
	select distinct
		TWD_KntNumer as [KntNumer]
		,TwK_Kod as [Kod]
		,TwK_Kod as [Symbol]
		,TwK_Jm as [Jm]
		from cdn.TwrDost with(nolock) 
		left join cdn.TwrKodyKnt with(nolock) on TWD_KntNumer = TKK_KntNumer
		join cdn.TwrKody with(nolock) on TKK_TwKId = TwK_Id and TwK_TwrNumer = TWD_TwrNumer and TwK_TypKodu = 3

		where TWD_TwrNumer = @GidNumer and TWD_TwrTyp = @GidTyp  and TWD_KlasaKnt = 8 	
END
