BEGIN TRANSACTION UpdateOperatora

DECLARE @opeNumer int
DECLARE @kntNumer int

DECLARE Cursor_UpdateOperatora CURSOR FOR
	Select Knt_GidNumer, (SELECT TOP 1 Ope_GidNumer from cdn.OpeKarty b WHERE KtO_PrcNumer = Ope_PrcNumer and Ope_Ident like('%_Z'))
	from cdn.KntKarty
	join cdn.KntRejony on Knt_GIDNumer=KnR_KntNumer	
	join cdn.Rejony on REJ_Id=KnR_Rejon
	join cdn.KntOpiekun on REJ_Id=KtO_KntNumer and KtO_KntTyp=948
	join cdn.KntAplikacje on Knt_GIDNumer=KAp_KntNumer and KAp_KntTyp=32
	join cdn.OpeKarty on Ope_GIDNumer=KAp_OpeONumer
	where KtO_Glowny = 1
	and REJ_Nazwa <> 'RQ'
	and Ope_PrcNumer <> KtO_PrcNumer
	and Ope_PrcNumer <> 8
	and Knt_Archiwalny = 0
OPEN Cursor_UpdateOperatora
FETCH NEXT FROM Cursor_UpdateOperatora
INTO @kntNumer, @opeNumer
	
WHILE @@FETCH_STATUS = 0 
BEGIN
	UPDATE CDN.KntAplikacje SET KAp_OpeONumer = @opeNumer WHERE KAp_KntNumer = @kntNumer
	FETCH NEXT FROM Cursor_UpdateOperatora
	INTO @kntNumer, @opeNumer
END
CLOSE Cursor_UpdateOperatora
DEALLOCATE Cursor_UpdateOperatora