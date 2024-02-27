  SELECT
  TWr_kod, 
  Twr_nazwa, 
  (SELECT TOP 1 ISNULL(b.[dane_twrwyszuk],'') FROM dbo.b2b_dane_wyszukiwania b with (nolock) WHERE a.[dane_twrid]=b.[dane_twrid] GROUP BY b.[dane_twrwyszuk] ORDER BY COUNT(b.[dane_twrwyszuk]) DESC) as [Najczêœciej wyszukiwana fraza], 
  count(distinct [dane_kntilosc]) as [Iloœæ klikniêæ ró¿nych knt],
  [ostatni_dostawca],
  [dane_twrid]
  FROM dbo.b2b_dane_wyszukiwania a with (nolock)
  LEFT JOIN cdn.twrkarty US with (nolock) ON twr_gidnumer=dane_twrid
  LEFT JOIN cdn.Atrybuty WITH (NOLOCK) ON Twr_GIDNumer=Atr_ObiNumer AND Atr_OBITyp=16 AND Atr_OBILp = 0
  LEFT JOIN cdn.AtrybutyKlasy WITH (NOLOCK) ON  AtK_ID=Atr_AtkId
  LEFT JOIN [dbo].[Dane_Do_kolumn] WITH (NOLOCK) ON dane_gid = twr_gidnumer
  WHERE twr_archiwalny=0
  AND Twr_WCenniku=1 
  AND Twr_Kod NOT IN (SELECT Twr_Kod FROM cdn.TwrKarty SS WITH (NOLOCK) LEFT JOIN cdn.Atrybuty WITH (NOLOCK) ON Twr_GIDNumer=Atr_ObiNumer AND Atr_OBITyp=16 AND Atr_OBILp = 0 LEFT JOIN cdn.AtrybutyKlasy WITH (NOLOCK) ON  AtK_ID=Atr_AtkId WHERE AtK_ID = 452 AND Atr_Wartosc = 'TAK' AND SS.twr_kod  = US.Twr_kod)
  group by TWr_kod,Twr_nazwa,[ostatni_dostawca],[dane_twrid]
  order by count(distinct [dane_kntilosc]) DESC