select knt_akronim
,Adresy = STUFF(
                 (SELECT distinct ' ||| ' + Kna_Ulica + ' ' + Kna_Adres + ' ' + Kna_KodP + ' ' + Kna_Miasto
				 FROM cdn.KntAdresy with(nolock)
					where Knt_GIDNumer = KnA_KntNumer and KnA_KntTyp = 32
					and KnA_DataArc = 0
					
					
                           FOR XML PATH ('')), 1, 1, ''
               )
from cdn.kntkarty
order by Knt_Akronim
