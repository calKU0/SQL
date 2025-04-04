USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [kkur].[WMSPobierzZdjeciaTowaru]    Script Date: 2025-04-01 14:57:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [kkur].[WMSPobierzZdjeciaTowaru]
@GidNumer int,
@GidTyp int
AS
BEGIN
	SET NOCOUNT ON;
	WITH Images AS (
		SELECT 
			ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum,
			'https://api.gaska.com.pl:8089/f/image/' + LTRIM(Twr_GIDNumer) + '/' + LTRIM(DAB_ID) + '_' + REPLACE(DAB_Nazwa,'/','') + '.' + DAB_Rozszerzenie AS [Path]
		FROM CDN.TwrKarty WITH (NOLOCK)
		JOIN CDN.DaneObiekty WITH (NOLOCK) ON Twr_GIDNumer = DAO_ObiNumer AND DAO_ObiTyp = 16
		JOIN CDN.DaneBinarne WITH (NOLOCK) ON DAB_ID = DAO_DABId
		WHERE Twr_GIDNumer = @GidNumer AND Twr_GIDTyp = @GidTyp
	)

	SELECT 
		CASE WHEN RowNum = 1 THEN 1 ELSE 0 END AS [Default],
		[Path]
	FROM Images;
END
