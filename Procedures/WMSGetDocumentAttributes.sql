USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [kkur].[WMSPobierzAtrybutyDokumentu]    Script Date: 2025-04-01 14:55:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [kkur].[WMSPobierzAtrybutyDokumentu]
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

	from cdn.TraNag with(nolock)
	join cdn.Atrybuty with(nolock) on Atr_ObiNumer = TrN_GIDNumer and Atr_ObiTyp = TrN_GIDTyp
	join cdn.AtrybutyKlasy with(nolock) on Atr_AtkId = AtK_ID

	WHERE TrN_GIDNumer = @GidNumer and TrN_GIDTyp = @GidTyp and AtK_ID in (449, 394)*/

	/*UNION ALL

	select
	'Rodzaj wysyłki' as [Klasa]
	,'TEXT' as [Typ]
	,case when Atr_Wartosc = 'TAK' then 'Paczka' else 'Paleta' end as [Wartosc]

	from cdn.TraNag with(nolock)
	join cdn.Atrybuty with(nolock) on Atr_ObiNumer = TrN_GIDNumer and Atr_ObiTyp = TrN_GIDTyp
	join cdn.AtrybutyKlasy with(nolock) on Atr_AtkId = AtK_ID

	WHERE TrN_GIDNumer = @GidNumer and TrN_GIDTyp = @GidTyp and AtK_ID =374

	
	UNION ALL
	
	select 'Data synchronizacji'
	,'DATE'
	,FORMAT(GETUTCDATE(), 'yyyy-MM-ddTHH:mm:ss.fffZ')*/
END




