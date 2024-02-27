select  Dst_TrNTyp, Dst_TrnNumer, Dst_GIDNumer,
			dost.trs_magnumer,RzNetto
			,isnull(TwZ_RzeczywistaNetto,0) as [Zasoby RzeczywistaNetto]
			,KsNetto
			,isnull(TwZ_KsiegowaNetto,0) as [Zasoby KsiegowaNetto]
			,CDN.NumerDokumentu(trn_Gidtyp,trn_SpiTyp,trn_trntyp,trn_trnnumer,trn_trnrok,trn_trnseria,trn_trnmiesiac) as Numer
			,trn_trnnumer
			,trn_trnrok
			

	from (
		select Dst_GIDTyp, Dst_GIDFirma, Dst_GIDNumer, Dst_GIDLp,
				Dst_TwrTyp, Dst_TwrFirma, Dst_TwrNumer, Dst_TwrLp, Dst_Ean, Dst_DataW,
				Dst_TrNTyp, Dst_TrNFirma, Dst_TrNNumer, Dst_TrNLp, Dst_SubTrNLp,
		isnull(Sum(cdn.TrsKsiegowa(TrS_KosztKsiegowy, Trs_Ilosc, TrS_GIDTyp, TrS_GIDNumer, TrS_GIDLp, TrS_SubGIDLp, TrS_SubZwrLp, TrN_Stan, TrN_ZmodyfikowanoZasob)),0) as KsNetto,
		isnull(Sum(cdn.TrsRzeczywista(TrS_KosztRzeczywisty, Trs_Ilosc, TrS_GIDTyp, TrS_GIDNumer, TrS_GIDLp, TrS_SubGIDLp, TrS_SubZwrLp, TrN_Stan)),0) as RzNetto,
		isnull(Sum(CDN.TrsIlosc(Trs_Ilosc, TrS_GIDTyp, TrS_GIDNumer, TrS_GIDLp, TrS_SubGIDLp, TrS_SubZwrLp, TrN_Stan)),0) as ILSPR
		,Trs_MagNumer,trs_magtyp,trs_magfirma,trs_maglp

		from cdn.dostawy with(nolock)
		left outer join cdn.traselem with(nolock) on dst_gidnumer=trs_dstnumer
		left outer join cdn.tranag with(nolock) on trs_GIDNUmer = Trn_GidNumer
		group by  Dst_GIDTyp, Dst_GIDFirma, Dst_GIDNumer, Dst_GIDLp,
				Dst_TwrTyp, Dst_TwrFirma, Dst_TwrNumer, Dst_TwrLp, Dst_Ean, Dst_DataW,
				trs_magtyp, trs_magfirma, trs_magnumer, isnull(trs_maglp,0),
				Dst_TrNTyp, Dst_TrNFirma, Dst_TrNNumer, Dst_TrNLp, Dst_SubTrNLp,trs_maglp--,trn_gidnumer,trn_Gidtyp,TrN_SpiTyp,TrN_TrNTyp,TrN_TrNNumer,TrN_TrNRok,TrN_TrNSeria,TrN_TrNMiesiac
	) as dost
	left outer join cdn.magselem with(nolock) on Dost.Trs_MagNumer=MaS_MagNumer and Dst_GIDNumer=MaS_DstNumer
	left outer join cdn.magnag with(nolock) on MaS_GIDNumer=MaN_GIDNumer
	left outer join CDN.TwrZasoby with(nolock) on Dost.Trs_MagNumer=TwZ_MagNumer and Dst_GIDNumer=TwZ_DstNumer
	left outer join CDN.TraSElem as DokZaklDst with(nolock) on Dst_TrnTyp=DokZaklDst.TrS_GIDTyp and Dst_TrnNumer=DokZaklDst.TrS_GIDNumer and Dst_TrnLp=DokZaklDst.TrS_GIDLp and Dst_SubTrnLp=DokZaklDst.TrS_SubGIDLp 
	left outer join cdn.tranag with(nolock) on dost.dst_trntyp = trn_gidtyp and dost.dst_trnnumer = trn_gidnumer
	--where Dst_GIDNumer in (1)-- MO¯NA ZAWÊZIÆ DO DOSTAWY
	group by Dst_TrNTyp, Dst_TrnNumer,
			Dst_GIDTyp, Dst_GIDFirma, Dst_GIDNumer, Dst_GIDLp,
			Dst_TwrTyp, Dst_TwrFirma, Dst_TwrNumer, Dst_TwrLp, Dst_Ean, Dst_DataW,
			KsNetto, RzNetto, ILSPR, DokZaklDst.TrS_TrNTStamp,
			dost.trs_magtyp, dost.trs_magfirma, dost.trs_magnumer, dost.trs_maglp,
			TwZ_Ilosc, TwZ_IlSpr, TwZ_IlMag, TwZ_DstNumer, TwZ_KsiegowaNetto, TwZ_RzeczywistaNetto,trn_gidnumer,trn_Gidtyp,TrN_SpiTyp,TrN_TrNTyp,TrN_TrNNumer,TrN_TrNRok,TrN_TrNSeria,TrN_TrNMiesiac,trn_data2
	having  --TwZ_DstNumer is not null and--warunek dla istniej¹cych zasobów
			ILSPR>=0 --warunek dla zasobów, które wg histori maj¹ iloœæ TwZ_IlSpr>=0
/*			and isnull(SUM(CDN.MasIlosc(MaS_Ilosc, MaN_TrNTyp, MaN_Stan)),0)>=0 --warunek dla zasobów, które wg histori maj¹ iloœæ TwZ_IlMag>=0
			and isnull(sum(case when isnull(MaS_SubZrdLp,0)=0 then CDN.MasIlosc(MaS_Ilosc, MaN_TrNTyp, MaN_Stan) else 0 end),0)+IlSpr>=0 --warunek dla zasobów, które wg histori maj¹ iloœæ TwZ_Ilosc>=0
			and KsNetto>=0 --warunek dla wartoœci TwZ_KsiegowaNetto>=0
			and RzNetto>=0 --warunek dla wartoœci TwZ_RzeczywistaNetto>=0
*/	and (
		--	ILSPR<>isnull(TwZ_IlSpr,0) OR
		--	isnull(SUM(CDN.MasIlosc(MaS_Ilosc, MaN_TrNTyp, MaN_Stan)),0)<>isnull(TwZ_IlMag,0) OR
		--	isnull(sum(case when isnull(MaS_SubZrdLp,0)=0 then CDN.MasIlosc(MaS_Ilosc, MaN_TrNTyp, MaN_Stan) else 0 end),0)+IlSpr<>isnull(TwZ_Ilosc,0) OR
			KsNetto<>isnull(TwZ_KsiegowaNetto,0) OR
			RzNetto<>isnull(TwZ_RzeczywistaNetto,0)
	)
	order by 11 desc,10 desc