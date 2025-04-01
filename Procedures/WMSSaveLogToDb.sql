USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [kkur].[WMSZapiszLogDoTabeli]    Script Date: 2025-04-01 14:57:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [kkur].[WMSZapiszLogDoTabeli]
@EntityId int,
@EntityType int,
@Success tinyint,
@Action varchar(50),
@Error varchar(max)
AS
BEGIN	
	/*If exists (select * from kkur.ApiLogs where EntityErpId = @EntityId and EntityErpType = @EntityType and Flow = 'OUT')
	begin
		Update kkur.ApiLogs
		set Success = @Success
		,ErrorMessage = @Error
		
		where EntityId = @EntityId and EntityType = @EntityType and Flow = 'OUT'
	end
	else
	begin*/
		Insert into kkur.ApiLogs(EntityWmsId, EntityWmsType, EntityErpId, EntityErpType, Action, Success, ErrorMessage, CreatedDate, Flow) 
		VALUES (0, 0, @EntityId, @EntityType, @Action, @Success, @Error, getdate(),'OUT')
	--end
END

