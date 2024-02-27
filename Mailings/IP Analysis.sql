DECLARE @tableHTML varchar(MAX)
DECLARE @Temat varchar(255)

set @Temat = 'Logowania nowe B2B ' + ltrim(convert(date, getdate()-1))

SET @tableHTML = 

N'<h2>' + @Temat + '</h2>' +
N'<table border="1">' +
N'<tr><th>Data</th><th>Akronim</th><th>Osoba</th><th>IP</th><th>Inne logowania</th><th>VPN</th><th>Proxy</th></tr>' +
CAST ( ( SELECT distinct

td = convert(date, R_LG_Data), '',

td = R_LG_Akronim, '',
td = R_LG_Osoba, '',
td = R_LG_IP, '',

td = LTRIM(STUFF( (SELECT distinct ', ' + b.R_LG_Akronim + ' (' +

		LTRIM((select top 1 convert(date, c.R_LG_Data)
		FROM [serwer-sql].[nowe_b2b].[ldd].[RptLogowanie] c with (nolock)
		where c.R_LG_Akronim != a.R_LG_Akronim
		and c.R_LG_IP = a.R_LG_IP
		and c.R_LG_Sukces = 1
		order by c.R_LG_Data desc
		)) + ')'

FROM [serwer-sql].[nowe_b2b].[ldd].[RptLogowanie] b with (nolock)
where b.R_LG_Akronim != a.R_LG_Akronim
and b.R_LG_IP = a.R_LG_IP
and b.R_LG_Sukces = 1
and DATEDIFF(DD,'18001228',convert(date, b.R_LG_Data)) > DATEDIFF(DD,'18001228',getdate()-180)
and isnull((select atr_wartosc
from cdn.kntkarty with (nolock)
left join cdn.atrybuty with (nolock) on Knt_GIDNumer=Atr_ObiNumer and Atr_OBITyp=32 AND Atr_OBISubLp=0 and Atr_AtkId = 356 -- Nie uwzglêdniaj w analizie B2B
where knt_akronim = b.R_LG_Akronim), 'NIE') = 'NIE'
FOR XML PATH('')),
1, 1, '')),'',
td = isnull(convert(varchar,VPN),'Brak danych'), '',
td = isnull(convert(varchar, Proxy), 'Brak danych')

FROM [serwer-sql].[nowe_b2b].[ldd].[RptLogowanie] a with (nolock)
left join dbo.GaskaClientIPInfo with (nolock) on a.R_LG_IP = IPAdress

where convert(date, R_LG_Data) = convert(date, getdate()-1)

and R_LG_Sukces = 1

and a.R_LG_IP not like '192.168.0.%' and a.R_LG_IP not like '10.0.1.1' 

and LTRIM(STUFF( (SELECT distinct ', ' + b.R_LG_Akronim + ' (' +

		LTRIM((select top 1 convert(date, R_LG_Data)
		FROM [serwer-sql].[nowe_b2b].[ldd].[RptLogowanie] c with (nolock)
		where c.R_LG_Akronim != b.R_LG_Akronim
		and c.R_LG_IP = b.R_LG_IP
		and c.R_LG_Sukces = 1
		order by c.R_LG_Data desc
		)) + ')'

FROM [serwer-sql].[nowe_b2b].[ldd].[RptLogowanie] b with (nolock)
where b.R_LG_Akronim != a.R_LG_Akronim
and b.R_LG_IP = a.R_LG_IP
and b.R_LG_Sukces = 1
and DATEDIFF(DD,'18001228',convert(date, b.R_LG_Data)) > DATEDIFF(DD,'18001228',getdate()-180)
and isnull((select atr_wartosc
from cdn.kntkarty with (nolock)
left join cdn.atrybuty with (nolock) on Knt_GIDNumer=Atr_ObiNumer and Atr_OBITyp=32 AND Atr_OBISubLp=0 and Atr_AtkId = 356 -- Nie uwzglêdniaj w analizie B2B
where knt_akronim = b.R_LG_Akronim), 'NIE') = 'NIE'
FOR XML PATH('')),
1, 1, '')) is not null

order by R_LG_Akronim asc

FOR XML PATH('tr'), TYPE 
) AS NVARCHAR(MAX) ) +
N'</table>';

EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'Gaska',
@recipients='it@gaska.com.pl',
@subject = @Temat,
@body = @tableHTML,
@body_format = 'HTML'