USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [kkur].[WMSPobierzTowary]    Script Date: 2025-04-07 14:17:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [kkur].[WMSPobierzTowary]
AS
BEGIN
	SET NOCOUNT ON;
	select
		Twr_GIDNumer as [TwrNumer]
		,Twr_GIDTyp as [TwrTyp]
		,Twr_Kod as [Kod]
		,Twr_Nazwa as [Nazwa]
		,Twr_Jm as [Jm]
		,'Sorter-' + isnull(nullif(Sorter.Atr_Wartosc,''),'<Brak>') + ':Typ-' + isnull(nullif(Typ.Atr_Wartosc,''),'<Brak>') as [Grupa]

		from cdn.TwrKarty with(nolock)
		join cdn.OEM with(nolock) on Twr_GIDNumer = ID
		left join cdn.Atrybuty Typ with(nolock) on Twr_GIDNumer = Typ.Atr_ObiNumer and Twr_GIDTyp = Typ.Atr_ObiTyp and Typ.Atr_AtkId = 148
		left join cdn.Atrybuty Sorter with(nolock) on Twr_GIDNumer = Sorter.Atr_ObiNumer and Twr_GIDTyp = Sorter.Atr_ObiTyp and Sorter.Atr_AtkId = 255
		left join cdn.Atrybuty StatusWMS with(nolock) on Twr_GIDNumer = StatusWMS.Atr_ObiNumer and Twr_GIDTyp = StatusWMS.Atr_ObiTyp and StatusWMS.Atr_AtkId = 355
		
		where SynchronizujKarteDoWMS = 1 and isnull(StatusWMS.Atr_Wartosc, 'Do synchronizacji') = 'Do synchronizacji' 
		and Twr_Archiwalny = 0 and Twr_Typ in (1,2)
END
