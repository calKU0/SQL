USE [CDNXL_TESTOWA_2023]
GO
/****** Object:  Trigger [CDN].[ProdZlecenia_DeleteHandler]    Script Date: 2023.07.05 09:22:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [CDN].[Gaska_ProdZlec_DomyœlnyKontrahent]
  ON [CDN].[ProdZlecenia]
  FOR insert
AS
SET NOCOUNT ON
IF (select PZL_KntNumer from inserted) = 0
	begin
		update cdn.prodzlecenia
		set
		PZL_KnDNumer = 19458,
		PZL_KnDTyp = 32,
		PZL_KntNumer = 19458,
		PZL_KntTyp = 32
		where PZL_Id = (select pzl_id from inserted)
	end
SET NOCOUNT OFF