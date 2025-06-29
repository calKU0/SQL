USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [kkur].[WMSPobierzAtrybutyDokumentu]    Script Date: 2025-04-07 14:16:52 ******/
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
	
	declare @Dropshipping int = (select case when TrN_SposobDostawy = 'Fedex Dropshipping' then 1 else 0 end
	from cdn.tranag tn1 with (nolock) where TrN_GIDNumer = @GidNumer and TrN_GIDTyp = @GidTyp)

	declare @WartoscTowaruWPaczce decimal(15,2) =
				(select round(sum(TrE_KsiegowaNetto),-3) 
				from cdn.TraElem with (nolock)				
				where TrE_GIDNumer = @GidNumer and TrE_GIDTyp = @GidTyp)

	declare @Pobranie decimal(15,2) = (select isnull(sum(KwotyPobran.Pobranie),0)
	from
	(
		select tn1.trn_gidnumer as [GidNumer]
		-- Musimy tu wymusić żeby zwracało 1 gdy jest dropshipping, ponieważ dropshipping ma forme płatności 'Przelew', a nie za pobraniem
		,case when isnull((select case when @Dropshipping = 1 then 1 else [CzyTraktowacJakoPobranie] end from [KontrolaPakowaniaFormyPlatnosci] with (nolock) where [Forma] = TrP_FormaNazwa),1) = 1
		then
			--Czy sposób dostawy to dropshipping Fedex, jeśli tak to kwota pobrania z atrybutu
				case when @Dropshipping = 1
					then 
					(
						select isnull(CONVERT(DECIMAL(18, 2),REPLACE(REPLACE(Atr_Wartosc, ' ', ''), ',', '.')),0)
						from cdn.Atrybuty with (nolock) 
                        where Atr_AtkId = 253 -- Dropshipping kwota pobrania
						and Atr_OBITyp in ( 2033, 2041 ,2037 ,2045 ,2001 ,2009, 2005 ,2013 ,2034 ,2042 ,2035,2043 ,2039, 2047, 1520, 1528, 1521 ,1529 ,1489 ,1497 ,1600,1603,1604 ,2036, 2044 ,1617 ,1616 ,2003 ,2004 ,1490 ,1498 ,1312 ,1824 ,1320 ,1832, 1624, 1625, 2000, 2002, 2008, 2010, 1828, 1836, 1968) AND Atr_OBILp=0 and Atr_OBISubLp = 0
						and Atr_ObiNumer = tn1.TrN_GIDNumer
					)

					else
					-- Czy dokument znajduje sie w tabeli TF, jesli tak to kwota z TF
						case when exists
						(select [ZestawienieElem_ID]
						FROM [dbo].[ZestawieniaNag_PA_TF] with (nolock)
						join [dbo].[ZestawieniaElem_PA_TF] with (nolock) on [ZestawienieElem_ID] = [ZestawienieNag_ID]
						where [Dokument_Numer] = tn1.trn_gidnumer)
						then
							-- dokument znajduje sie w tabeli TF ale sprawdzam czy nie bylo juz w jakiejs paczce pobrania do tego TF
							case when exists
							(
								select KP_DokumentHandlowy
								from dbo.KontrolaPakowania with (nolock)
								join cdn.tranag tn2 with (nolock) on [KP_DokumentHandlowy] = tn2.trn_gidnumer
								join [dbo].[ZestawieniaElem_PA_TF] with (nolock) on [Dokument_Numer] = tn2.trn_gidnumer
								join [dbo].[ZestawieniaNag_PA_TF] with (nolock) on [ZestawienieElem_ID] = [ZestawienieNag_ID]
								where ZestawienieNag_ID in (select ZestawienieNag_ID FROM [dbo].[ZestawieniaNag_PA_TF] with (nolock) join [dbo].[ZestawieniaElem_PA_TF] with (nolock) on [ZestawienieElem_ID] = [ZestawienieNag_ID] where [Dokument_Numer] = tn1.trn_gidnumer)
								and KP_Pobranie > 0
							)
							then 0
							else
								-- tylko dokument z TF z atrybutem Transakcja trójstronna ustawionym na TAK
								isnull((select sum([Kwota_Pobrania])
								FROM [dbo].[ZestawieniaNag_PA_TF] with (nolock)
								join [dbo].[ZestawieniaElem_PA_TF] with (nolock) on [ZestawienieElem_ID] = [ZestawienieNag_ID]
								where [Dokument_Numer] = tn1.trn_gidnumer
								and isnull((select atr_wartosc
								from cdn.atrybuty with (nolock)
								join cdn.atrybutyklasy with (nolock) on AtK_ID=Atr_AtkId
								where tn1.TrN_GIDTyp=Atr_ObiTyp AND tn1.TrN_GIDNumer=Atr_ObiNumer
								and AtK_ID=252 -- atrybut Transakcja trójstronna
								),'NIE') = 'TAK'
								),0)
							end

						else
							-- Jesli dokument ma atrybut Transakcja trojstronna to kwota z tego atrybutu
							case when isnull((select atr_wartosc
							from cdn.atrybuty with (nolock)
							join cdn.atrybutyklasy with (nolock) on AtK_ID=Atr_AtkId
							where tn1.TrN_GIDTyp=Atr_ObiTyp AND tn1.TrN_GIDNumer=Atr_ObiNumer
							and AtK_ID=252 -- atrybut Transakcja trójstronna
							),'NIE') = 'TAK'
							then
								isnull((select atr_wartosc
								from cdn.atrybuty with (nolock)
								join cdn.atrybutyklasy with (nolock) on AtK_ID=Atr_AtkId
								where tn1.TrN_GIDTyp=Atr_ObiTyp AND tn1.TrN_GIDNumer=Atr_ObiNumer
								and AtK_ID=253 -- atrybut Kwota pobrania dla transakcji trójstronnej
								),0)
							else
								-- Trp_Pozostaje
								sum(distinct TrP_Pozostaje)
							end
						end
					end
			else 0 end as [Pobranie]

		from cdn.tranag tn1 with (nolock)
		left join cdn.traplat with (nolock) on tn1.TrN_GIDTyp=TrP_GIDTyp AND tn1.TrN_GIDNumer=TrP_GIDNumer

		where TrN_GIDNumer = @GidNumer and TrN_GIDTyp = @GidTyp

		group by TrP_FormaNazwa, tn1.TrN_GIDNumer, tn1.TrN_GIDTyp
		) as [KwotyPobran]);


	WITH TraNagInfo AS (
    SELECT KnA_Telefon1 AS Telefon, KnA_EMail AS Mail, TrN_Waluta as [Waluta]
    FROM cdn.TraNag
    JOIN cdn.KntAdresy ON TrN_AdWNumer = KnA_GIDNumer AND TrN_AdWTyp = KnA_GIDTyp
    WHERE TrN_GIDNumer = @GidNumer AND TrN_GIDTyp = @GidTyp)

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
	
	SELECT 'Telefon' as [Klasa], 'TEXT' as [Typ], FORMAT(GETUTCDATE(), 'yyyy-MM-ddTHH:mm:ss.fffZ') AS [Value] FROM TraNagInfo
	UNION ALL SELECT 'Mail', 'TEXT', FORMAT(GETUTCDATE(), 'yyyy-MM-ddTHH:mm:ss.fffZ') FROM TraNagInfo
	UNION ALL SELECT 'COD', 'DECIMAL', @Pobranie
	UNION ALL SELECT 'COD waluta', 'TEXT', Waluta FROM TraNagInfo
	UNION ALL SELECT 'Ubezpieczenie', 'DECIMAL', @WartoscTowaruWPaczce
	UNION ALL SELECT 'Ubezpieczenie waluta', 'TEXT', 'PLN'
	--UNION ALL SELECT 'Data synchronizacji','TIME' ,FORMAT(GETUTCDATE(), 'yyyy-MM-ddTHH:mm:ss.fffZ')


END




