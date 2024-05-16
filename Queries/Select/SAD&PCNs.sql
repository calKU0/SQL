select 
convert(date, DATEADD(day, SaN_DataWplywu, '18001228')) as [Data Wplywu],
'SAD-'+convert(varchar,SaN_SaNNumer)+'/'+convert(varchar,SaN_SaNRok)+'/SAD' as [Numer faktury],
SaN_NumerSAD as [Numer dokumentu],
SeK_PCN as [PCN],
(select sum(sek_kwota) as [Kwota C³o] 
from cdn.SaEKwoty clo
where sa.SeK_GIDNumer = clo.sek_gidnumer 
and sa.SeK_PCN = clo.SeK_PCN
and SeK_Rodzaj = 4 and SeK_Typ = 0
group by SeK_GIDNumer) as [C³o],

(select sum(sek_kwota) as [Kwota C³o] 
from cdn.SaEKwoty akcyza
where sa.SeK_GIDNumer = akcyza.sek_gidnumer 
and sa.SeK_PCN = akcyza.SeK_PCN
and SeK_Rodzaj = 5 and SeK_Typ = 0
group by SeK_GIDNumer) as [Akcyza],

SeK_Waluta as [Waluta],
Knt_Akronim as [Kontrahent],
Knt_Miasto as [Kontrahent Miasto],
SaN_Netto as [Netto],
SaN_VAT as [Vat],
SaN_Netto + SaN_VAT as [Brutto]

from cdn.SadNag with(nolock)
join cdn.SaEKwoty sa with(nolock) on SaN_GIDNumer=SeK_GIDNumer
join cdn.KntKarty with(nolock) on Knt_GIDNumer = SaN_PdmNumer

where
SaN_DataWplywu between 81499 and 81589
and SaN_SaNTyp=17
and SeK_Typ = 0 
and (sek_pcn like ('72%') 
or sek_pcn like('26011200%')
or sek_pcn like('7301%')
or sek_pcn like('7302%')
or sek_pcn like('730300%')
or sek_pcn like('7304%')
or sek_pcn like('7305%')
or sek_pcn like('7306%')
or sek_pcn like('7307%')
or sek_pcn like('7308%')
or sek_pcn like('730900%')
or sek_pcn like('7310%')
or sek_pcn like('7318%')
or sek_pcn like('731100%')
or sek_pcn like('7326%'))
group by SaN_DataWplywu, SaN_SaNNumer, SaN_SaNRok, SaN_NumerSAD, SeK_PCN, Knt_Akronim, SaN_Netto, Knt_Miasto, SaN_VAT, SaN_Netto, SeK_GIDNumer,SeK_Waluta
order by 2 desc