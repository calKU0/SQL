Select 
CDN.NumerDokumentuTRN(trn_gidtyp,trn_spityp,trn_trntyp,trn_trnnumer,trn_trnrok,trn_trnseria) as [Dokument]
,twr_kod as [Kod Towaru]
,TrS_Ilosc as [Iloœæ rozchodowa]
,TrS_KosztKsiegowy as [Wartoœæ kosztu ksiêgowa po depr.]
,TrS_KosztRzeczywisty as [Wartoœæ koszt rzeczywista przed depr.]

,STUFF((select ',' + CDN.NumerDokumentuTRN(trn_gidtyp,trn_spityp,trn_trntyp,trn_trnnumer,trn_trnrok,trn_trnseria) from cdn.Tranag with (nolock) 
join cdn.TraElem with(nolock) on TrN_GIDTyp=TrE_GIDTyp AND TrN_GIDNumer=TrE_GIDNumer
join cdn.TraSElem  b with (nolock) on TrE_GIDTyp=b.TrS_GIDTyp AND TrE_GIDNumer=b.TrS_GIDNumer AND TrE_GIDLp=b.TrS_GIDLp
where a.TrS_DstNumer=b.TrS_DstNumer and TrN_GIDTyp=2004
FOR XML PATH ('')), 1, 1, '') as [Dokumenty deprecjacji dostawy]

from cdn.TraNag with(nolock)
join cdn.TraElem with(nolock) on TrN_GIDTyp=TrE_GIDTyp AND TrN_GIDNumer=TrE_GIDNumer
join cdn.twrkarty with(nolock) on Twr_GIDNumer=TrE_TwrNumer
join cdn.TraSElem  a with (nolock) on TrE_GIDTyp=a.TrS_GIDTyp AND TrE_GIDNumer=a.TrS_GIDNumer AND TrE_GIDLp=a.TrS_GIDLp

where Trs_KosztKsiegowy != TrS_KosztRzeczywisty
and trn_gidtyp not in (1603,1604,2004)
and 1 = (case when exists (select top 1 CDN.NumerDokumentuTRN(trn_gidtyp,trn_spityp,trn_trntyp,trn_trnnumer,trn_trnrok,trn_trnseria) from cdn.Tranag with (nolock) 
join cdn.TraElem with(nolock) on TrN_GIDTyp=TrE_GIDTyp AND TrN_GIDNumer=TrE_GIDNumer
join cdn.TraSElem  b with (nolock) on TrE_GIDTyp=b.TrS_GIDTyp AND TrE_GIDNumer=b.TrS_GIDNumer AND TrE_GIDLp=b.TrS_GIDLp
where a.TrS_DstNumer=b.TrS_DstNumer and TrN_GIDTyp=2004) then 1 else 0 end)

order by Twr_Kod


