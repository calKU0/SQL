select distinct
twr_kod as [Name]
,case when knt_akronim = 'JEDNORAZOWY' then '' else Knt_Nazwa1 end as [Producer]
,isnull(STUFF(
                 (SELECT distinct ', ' + AtK_Nazwa + ': ' + Atr_Wartosc from cdn.TwrKarty US with(nolock)
				 join cdn.Atrybuty with(nolock) on Twr_GIDNumer=Atr_ObiNumer and Atr_OBITyp=16 and Atr_OBILp = 0
				 join cdn.AtrybutyKlasy with(nolock) on  AtK_ID=Atr_AtkId
				 join cdn.AtrKompletyLinki with (nolock) on AtK_ID=AKl_AtKId
				 --left join cdn.TwrOpisy with(nolock) on Twr_GIDNumer=TwO_TwrNumer
					where US.Twr_Kod = SS.twr_kod
					and AKl_AKpID = 2

                           FOR XML PATH ('')), 1, 1, ''
               ),'') as [Description]
,twr_waga as [Weight]
,'https://www.b2b.gaska.com.pl/img/produkty/' + LTRIM(Twr_GIDNumer) + '/' + LTRIM(DAB_ID) + '_' + DAB_Nazwa + '.' + DAB_Rozszerzenie as [Image link]

from cdn.twrkarty SS WITH(NOLOCK)
join cdn.KntKarty WITH(NOLOCK) on Twr_PrdNumer = Knt_GIDNumer
join CDN.DaneObiekty with (nolock) on Twr_GIDNumer=DAO_ObiNumer and DAO_ObiTyp=16
join CDN.DaneBinarne with (nolock) on DAB_ID=DAO_DABId
join cdn.twrgrupy KK with(nolock) on Twr_GIDTyp=TwG_GIDTyp AND Twr_GIDNumer=TwG_GIDNumer and TwG_GIDTyp=16
where CDN.TwrGrupaPelnaNazwa(Twg_GRONumer) like '1.2 TECHNIKA ZBIORU ZIELONKEK I OKOPOW./PRZETRZ¥SACZE/%'
and Twr_Archiwalny = 0

