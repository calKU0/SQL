USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [kkur].[UpdateProduct]    Script Date: 2025-04-01 14:53:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [kkur].[UpdateProduct]
@ProductId int,
@Ean varchar (50),
@Weight decimal(15,3),
@Volume decimal(15,2),
@VolumeUnit varchar(6)
AS
BEGIN
	UPDATE cdn.TwrKarty with(rowlock)
	SET Twr_Ean = CASE WHEN @Ean = '' THEN Twr_Ean ELSE @Ean END
	,Twr_Waga = CASE WHEN @Weight is null THEN Twr_Waga ELSE @Weight END
	,Twr_WagaBrutto = CASE WHEN @Weight is null THEN Twr_WagaBrutto ELSE @Weight END
	,Twr_ObjetoscL = CASE WHEN @Volume is null THEN Twr_ObjetoscL ELSE @Volume END
	,Twr_WymJm = CASE WHEN @VolumeUnit = '' THEN Twr_WymJm ELSE @VolumeUnit END
	where Twr_GIDNumer = @ProductId
END
