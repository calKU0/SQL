select id=1
,CDN.NumerDokumentuTRN(trn_gidtyp,trn_spityp,trn_trntyp,trn_trnnumer,trn_trnrok,trn_trnseria) as [Dokument],
format(dateadd(day, Convert(int,Atr_Wartosc), '18001228'), 'dd.MM.yyyy') as [Data]
from CDN.TraNag with(nolock)
join CDN.Atrybuty on Atr_ObiNumer = TrN_GIDNumer
join CDN.AtrybutyKlasy on ATk_ID = Atr_AtKId
where TrN_GIDTyp=2033
and Atr_Wartosc like'%2%' 
and trn_trntyp = 3
and AtK_id = 375
order by Atr_Wartosc desc
