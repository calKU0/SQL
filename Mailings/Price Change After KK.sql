DECLARE @tableHTML  NVARCHAR(MAX) ;
DECLARE @Tresc  NVARCHAR(MAX) ;

SET @tableHTML =
	N'<H2>Podwy¿ka ceny po KK</H2>' +
	N'<table border="1">' +
	N'<tr><th>Kod</th><th>Nazwa</th><th>Numer MMW</th><th>Cena z MMW</th><th>Numer PW</th><th>Cena z PW</th><th>Roznica PLN</th><th>Roznica %</th></tr>' +
	CAST (( SELECT
td = TrE_TwrKod,'',
td = TrE_TwrNazwa,'',
td = MMW.NumerDok,'',
td = convert(decimal(15,2),MMW.Cena),'',
td = PW.NumerDok,'',
td = convert(decimal(15,2),PW.Cena),'',
td = convert(decimal(15,2),TrS_KosztKsiegowy / MMW.TrE_Ilosc),'',
td = convert(decimal (4,2), 100 * ((PW.Cena - MMW.Cena) / ((PW.Cena + MMW.Cena) / 2)))

from cdn.TraNag KKNag with(nolock)
join cdn.TraElem KKEle with(nolock) on TrN_GIDNumer = TrE_GIDNumer
join cdn.TraSElem with(nolock) on TrE_GIDNumer=TrS_GIDNumer AND TrE_GIDLp=TrS_GIDLp
join (select cdn.NumerDokumentu(TrN_GIDTyp, TrN_SpiTyp, TrN_TrNTyp, TrN_TrNNumer, TrN_TrNRok, TrN_TrNSeria, TrN_TrNMiesiac) as NumerDok, TrN_GIDNumer, TrE_WartoscPoRabacie/TrE_Ilosc as Cena, TrE_Ilosc from cdn.TraNag PW with(nolock) join cdn.TraElem with(nolock) on trn_gidnumer = TrE_GIDNumer where TrN_GIDTyp=1617 and TrN_KosztUstalono = 1) PW on PW.Trn_GIDNumer = KKNag.TrN_ZwrNumer
join (select cdn.NumerDokumentu(TrN_GIDTyp, TrN_SpiTyp, TrN_TrNTyp, TrN_TrNNumer, TrN_TrNRok, TrN_TrNSeria, TrN_TrNMiesiac) as NumerDok, TrE_GIDNumer, TrE_WartoscPoRabacie/TrE_Ilosc as Cena, TrE_Ilosc , TrE_TwrNumer from cdn.TraElem MMW with(nolock) join cdn.TraNag with(nolock) on TrN_GIDNumer = TrE_GIDNumer where TrE_GIDTyp = 1603) MMW on MMW.TrE_GIDNumer = TrS_ZwrNumer and KKEle.TrE_TwrNumer = MMW.TrE_TwrNumer

where TrS_GIDTyp=2003 and TrS_ZwrTyp = 1603 and TrN_Data2 >= DATEDIFF(DD,'18001228',GETDATE()-30)

	FOR XML PATH('tr'), TYPE 
	) AS NVARCHAR(MAX) ) +
	N'</table>';

	EXEC msdb.dbo.sp_send_dbmail
	@profile_name = 'GASKA',
	@recipients='it@gaska.com.pl',
	@subject = 'Podwyzka cen po KK',
	@body = @tableHTML,
	@body_format = 'HTML' ;