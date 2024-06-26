USE [CDNXL_TESTOWA_B2B]
GO
/****** Object:  UserDefinedFunction [dbo].[ZwrocDzienRoboczy]    Script Date: 03.04.2024 15:56:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [dbo].[ZwrocDzienRoboczy]
(
	@Date date
)
RETURNS date
AS
BEGIN
	-- Declare
	DECLARE @WorkDay INT = DATEDIFF(SECOND, '1990-01-01',@Date)
	,@IsWorking INT = 0
	,@StartPeriod INT
	,@EndPeriod INT

	--Logic
	WHILE @IsWorking=1
	BEGIN
		   SET @StartPeriod = (SELECT min(POK_OkresOd) FROM [CDN].[ProdOkresy] where POK_Dostepny=0
		   and @WorkDay between POK_OkresOd and POK_OkresDo);
       
		   SET @EndPeriod = (SELECT max(POK_OkresDo) FROM [CDN].[ProdOkresy] where POK_Dostepny=0
		   and @WorkDay between POK_OkresOd and POK_OkresDo);

		   SET @IsWorking = case when @WorkDay between @StartPeriod and @EndPeriod then 1 else 0 end;

		   SET @WorkDay = case when @WorkDay between @StartPeriod and @EndPeriod then DATEDIFF(SECOND, '1990-01-01', DateAdd(day,CDN.NastepnyDzienRoboczy(DATEDIFF(DD,'18001228',DATEADD(SECOND, @WorkDay, '1990-01-01')) + 1),'18001228')) else DATEDIFF(SECOND, '1990-01-01', DateAdd(day,CDN.NastepnyDzienRoboczy(DATEDIFF(DD,'18001228',DATEADD(SECOND, @WorkDay, '1990-01-01'))),'18001228')) end ;
	END;

	-- Return
	RETURN convert(date,Dateadd(Second, @WorkDay, '1990-01-01'))
END
