DECLARE @tableHTML varchar(MAX)
DECLARE @Temat varchar(255)

declare
	@dataOd date = CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, getdate()) - 1, 0))
	,@dataDo date = CONVERT(DATE, DATEADD(dd,-DAY(getdate()), getdate()))

set @Temat = 'Korekty zatwierdzone automatycznie z poprzedniego tygodnia'

SET @tableHTML = 

N'<h2>' + @Temat + '</h2>' +
--N'<style>'+
--N'th {width:100%;color:brown;}'+
--N'</style>'+
N'<table border="1" >' +
N'<tr>
<th>Numer ZZ</th>
<th>Nr faktury</th>
<th>Nr korekty</th>
<th>Nr RLS</th>
<th>Data wystawienia korekty</th>
<th>Data zatwierdzenia korekty</th>
<th>Kod towaru</th>
<th>Iloœæ</th>
<th>Cena towaru netto</th>
<th>Wartoœæ towaru netto</th>
<th>Wartoœæ korekty netto</th>
<th>Waluta</th>
<th>Kontrahent</th>
<th>Przyczyna korekta</th>
<th>Operator wystawiaj¹cy korekte</th>
<th>Operator zatwierdzaj¹cy korekte</th>
<th>Operator wystawiaj¹cy RLS</th>
<th>Operator zatwierdzaj¹cy RLS</th>
</tr>' +
CAST ((select distinct
td = isnull('ZZ-'+ convert(varchar(10), ss.ZaN_ZamNumer)+'/' + replace(convert(varchar(10),ss.ZaN_ZamRok),'20','') +'/'+ convert(varchar(10),ss.ZaN_ZamSeria),'BRAK'),'',
td = TrN_NrKorekty,'',
td = CDN.NumerDokumentuTRN(trn_gidtyp,TrN_SpiTyp,trn_trntyp,trn_trnnumer,trn_trnrok,trn_trnseria),'',
td = isnull(CDN.NumerDokumentuTRN(rln_typ,0,0,rln_numer,rln_rok,rln_seria),''),'',
td = isnull(convert(date,DATEADD(day,TrN_Data2,'18001228')),''),'',
td = isnull(index1.Atr_Wartosc,''),'',
td = Twr_Kod,'',
td = convert(decimal(15,2),TrE_Ilosc),'',
td = convert(decimal(15,2),TrE_Cena),'',
td = TrE_KsiegowaNetto,'',
td = convert(decimal(15,2),Trv_nettoR),'',
td = TRN_waluta,'',
td = KnA_Akronim,'',
td = TrN_PrzyczynaKorekty,'',
td = wystawiajacy.Ope_Ident,'',
td = zatwierdzajacy.Ope_Ident,'',
td = isnull(wystRLS.Ope_Ident,''),'',
td = isnull(zatwRLS.Ope_Ident,''),''
from cdn.TraNag with (nolock) 
join cdn.KntAdresy with (nolock) on KnA_GIDTyp=TrN_KnATyp AND KnA_GIDNumer=TrN_KnANumer
join cdn.opekarty zatwierdzajacy with (nolock) on  zatwierdzajacy.Ope_GIDNumer=TrN_OpeNumerZ 
join cdn.opekarty wystawiajacy with (nolock) on  wystawiajacy.Ope_GIDNumer=TrN_OpeNumerW 
join cdn.TraElem with (nolock) on TrN_GIDNumer=TrE_GIDNumer
join cdn.TwrKarty with (nolock) on Twr_GIDNumer=TrE_TwrNumer
join cdn.TraVat with (nolock) on TrN_GIDNumer=TRV_GIDNumer
join cdn.atrybuty index1 WITH (NOLOCK) on TrN_GIDNumer=index1.Atr_ObiNumer AND TrN_GIDTyp=index1.Atr_ObiTyp and index1.Atr_AtkId = 63
--left join cdn.atrybuty index2 WITH (NOLOCK) on TrN_GIDNumer=index2.Atr_ObiNumer AND TrN_GIDTyp=index2.Atr_ObiTyp and index2.Atr_AtkId = 62
left join cdn.ReklRealizacja with (nolock) on RLR_DokNumer=TrN_GIDNumer
left join cdn.ReklElem with (nolock) on RLE_Id=RLR_RLEId
left join cdn.ReklNag with (nolock) on RLN_Id=RLE_RLNId
left join cdn.OpeKarty wystRLS with (nolock) on wystRLS.Ope_GIDNumer=RLN_OpeNumerW
left join cdn.OpeKarty zatwRLS with (nolock) on zatwRLS.Ope_GIDNumer=RLR_OpeNumer
left join cdn.ZamElem with (nolock) on TrN_ZaNNumer=ZaE_GIDNumer
left join cdn.ZamNag with (nolock) on ZaN_GIDNumer=ZaE_GIDNumer
left join cdn.ZamZamLinki with (nolock) on  ZaE_GIDTyp=ZZL_ZZGidTyp AND ZaE_GIDNumer=ZZL_ZZGidNumer AND ZaE_GIDLp=ZZL_ZZGidLp or ZaE_GIDTyp=ZZL_ZSGidTyp AND ZaE_GIDNumer=ZZL_ZSGidNumer AND ZaE_GIDLp=ZZL_ZSGidLp and ZZL_ZZGIDTyp=960
left join cdn.ZamNag ss with (nolock) on ss.ZaN_GIDNumer=ZZL_ZZGidNumer
where zatwierdzajacy.Ope_Ident = 'AUTOMAT' 
and TrE_Ilosc <> 0
and TrV_GIDTyp NOT IN(3376,3378,3379,3387,3386,2600) 
--and index1.Atr_OBITyp in (2033, 2041 ,2037 ,2045 ,2001 ,2009, 2005 ,2013 ,2034 ,2042 ,2035,2043 ,2039, 2047, 1520, 1528, 1521 ,1529 ,1489 ,1497 ,1600,1603,1604 ,2036, 2044 ,1617 ,1616 ,2003 ,2004 ,1490 ,1498 ,1312 ,1824 ,1320 ,1832, 1624, 1625, 2000, 2002, 2008, 2010, 1828, 1836, 1968) AND index1.Atr_OBILp=0 and index1.Atr_OBISubLp = 0
--and index2.Atr_OBITyp in (2033, 2041 ,2037 ,2045 ,2001 ,2009, 2005 ,2013 ,2034 ,2042 ,2035,2043 ,2039, 2047, 1520, 1528, 1521 ,1529 ,1489 ,1497 ,1600,1603,1604 ,2036, 2044 ,1617 ,1616 ,2003 ,2004 ,1490 ,1498 ,1312 ,1824 ,1320 ,1832, 1624, 1625, 2000, 2002, 2008, 2010, 1828, 1836, 1968) AND index2.Atr_OBILp=0 and index2.Atr_OBISubLp = 0
and index1.atr_wartosc between getdate()-7 and getdate() FOR XML PATH('tr'), TYPE 
) AS NVARCHAR(MAX) ) +
N'</table>';

EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'Gaska',
@recipients='',
@subject = @Temat,
@body = @tableHTML,
@body_format = 'HTML'