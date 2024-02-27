Select distinct
                             
Ope_ZakazNazwa,
Ope_ZakazOpis,
Operatorzy_z_zakazami = STUFF(
                 (SELECT distinct ',' + OPE_Nazwisko FROM cdn.OpeKarty with(nolock)
                           left join CDN.OpeZakazy with(nolock) on Ope_GIDNumer=OpZ_OpeNumer
                           where Opz_ProcID = Ope_ZakazID 
                            and Ope_Zablokowane = 0
                           FOR XML PATH ('')), 1, 1, ''
               ),


Operatorzy_bez_zakazow = STUFF(
                 (SELECT distinct ',' +  OPE_Nazwisko FROM cdn.OpeKarty with(nolock)
							where ope_gidnumer not in (select ope_gidnumer FROM cdn.OpeKarty with(nolock) 
							left join CDN.OpeZakazy with(nolock) on Ope_GIDNumer=OpZ_OpeNumer
                            where Opz_ProcID = Ope_ZakazID)
							and Ope_Zablokowane = 0

							FOR XML PATH ('')), 1, 1, ''
               )

from dbo.OpeZakazyOpis with(nolock)
