USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [kkur].[ZaktualizujAtrybut]    Script Date: 2025-04-01 14:57:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [kkur].[ZaktualizujAtrybut]
@ObjectId int,
@ObjectType int,
@ObjectLp int,
@Class varchar(100),
@Value varchar(250)

AS
BEGIN
	DECLARE @ClassId int = (SELECT TOP 1 atk_id FROM cdn.AtrybutyKlasy WITH(NOLOCK) WHERE AtK_Nazwa = @Class)

	UPDATE cdn.Atrybuty with(rowlock)
	SET Atr_Wartosc = @Value
	WHERE Atr_AtkId = @ClassId AND Atr_ObiNumer = @ObjectId AND Atr_ObiLp = @ObjectLp AND Atr_ObiTyp = @ObjectType

	-- Dajemy IF ponieważ nie da się założyć atrybutów opakowania przez API. Musimy robić INSERTA
	IF (@@ROWCOUNT <= 0 AND @ObjectLp > 0 AND @ClassId is not null)
		INSERT INTO cdn.Atrybuty with(rowlock) (Atr_ObiTyp, Atr_ObiFirma, Atr_ObiNumer, Atr_ObiLp, Atr_ObiSubLp, Atr_AtkId, Atr_Wartosc, Atr_AtrTyp, Atr_AtrFirma, Atr_AtrNumer, Atr_AtrLp, Atr_AtrSubLp, Atr_OptimaId, Atr_Grupujacy, Atr_Pozycja)
		VALUES (@ObjectType, 449892, @ObjectId, @ObjectLp, 0, @ClassId, @Value, 0, 0, 0 ,0, 0, 0, 0, 0)
END
