USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [kkur].[WMSPobierzAtrybutyKontrahenta]    Script Date: 2025-04-01 14:55:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [kkur].[WMSPobierzAtrybutyKontrahenta]
@GidNumer int,
@GidTyp int
AS
BEGIN
	SET NOCOUNT ON;
	/*select
	AtK_Nazwa as [Klasa]
	,case when substring(AtK_Format, 2, 1) = 's' then 'TEXT'
		when substring(AtK_Format, 2, 1) = 'n' then 'DECIMAL'
		when substring(AtK_Format, 2, 1) = 'd' then 'DATE'
	end as [Typ]
	,Atr_Wartosc as [Wartosc]

	from cdn.KntKarty with(nolock)
	join cdn.Atrybuty with(nolock) on Atr_ObiNumer = Knt_GIDNumer and Atr_ObiTyp = Knt_GIDTyp
	join cdn.AtrybutyKlasy with(nolock) on Atr_AtkId = AtK_ID

	where Knt_GIDNumer = @GidNumer and Knt_GIDTyp = @GidTyp and AtK_ID in (424, 394)*/
END




