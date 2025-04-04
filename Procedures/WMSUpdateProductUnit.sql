USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [kkur].[ZaktualizujJMTowaru]    Script Date: 2025-04-01 14:57:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
ALTER PROCEDURE [kkur].[ZaktualizujJMTowaru]
@ProductId int,
@Jm varchar (50),
@Ean varchar (50),
@Weight decimal(15,3),
@Volume decimal(15,2),
@VolumeUnit varchar(6),
@Converter int
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE CDN.TwrJm with(rowlock)
	SET TwJ_Waga = @Weight
	,TwJ_WagaBrutto = @Weight
	,TwJ_WJm = TwJ_WJm
	,TwJ_WJmBrutto = TwJ_WJmBrutto
	,TwJ_ObjetoscL = @Volume
	,TwJ_WymJm = @VolumeUnit
	,TwJ_PrzeliczL = @Converter

	WHERE TwJ_TwrNumer = @ProductId and TwJ_JmZ = @Jm

	IF @@ROWCOUNT > 0
	BEGIN
		UPDATE CDN.TwrKody with(rowlock)
		SET TwK_Kod = @Ean
		WHERE TwK_TwrNumer = @ProductId and TwK_Jm = @Jm
	END

	select isnull(TwJ_TwrLp,0) from cdn.TwrJm WHERE TwJ_TwrNumer = @ProductId and TwJ_JmZ = @Jm
END
