USE [CDNXL_GASKA]
GO
/****** Object:  Trigger [CDN].[Gaska_TraNag_BlokadaAntiMoneyLaundering]    Script Date: 2025-04-01 15:07:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER TRIGGER [CDN].[Gaska_TraNag_BlokadaAntiMoneyLaundering]
   ON  [CDN].[TraNag]
   AFTER UPDATE
AS 
BEGIN
	IF UPDATE(TrN_Stan) 
	BEGIN
		IF EXISTS(select * from inserted i
					join cdn.TraVat on i.TrN_GIDNumer = TrV_GIDNumer
					where (TrV_NettoP*((TRV_StawkaPod+100)/100) >= 100000/isnull((SELECT WaE_KursL / WaE_KursM FROM cdn.WalNag with (nolock) JOIN cdn.WalElem with (nolock) on WaN_Symbol=WaE_Symbol where WaN_Symbol = TrN_Waluta and WaE_Lp = 1 order by WaE_KursTS desc OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY),1) or TrV_NettoR*((TRV_StawkaPod+100)/100) >= 100000/isnull((SELECT WaE_KursL / WaE_KursM FROM cdn.WalNag with (nolock) JOIN cdn.WalElem with (nolock) on WaN_Symbol=WaE_Symbol where WaN_Symbol = TrN_Waluta and WaE_Lp = 1 order by WaE_KursTS desc OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY),1))
					and TrN_GIDTyp not in (1490, 2036, 1616, 1617)
					and (TrN_FormaNazwa = 'Gotówka' or TrN_FormaNazwa = 'Za pobraniem')
		)
		BEGIN
			declare @kom1 varchar(1000)
			set @kom1='#CDN_BLAD/# #CDN_1=Nie można potwerdzić faktury. Powód: Płatność gotówką na kwotę powyżej 10tys PLN brutto '  + '#CDN_2=(Blokada założona przez dział IT) /# #CDN_3=Brak/#'
			RAISERROR(@kom1,16,1)
			rollback tran
			return
		END
	END
END
