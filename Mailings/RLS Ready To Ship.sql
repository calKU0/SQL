SET NOCOUNT ON;

DECLARE @emailOpiekuna varchar(255)
DECLARE @temat varchar(255)
DECLARE @odbiorcy varchar(255)
DECLARE @tableHTML varchar(MAX)

DECLARE LokalizacjaRLS CURSOR FORWARD_ONLY FOR
	
select prc_email

from cdn.ReklNag with (nolock)
join cdn.Atrybuty with (nolock) on RLN_Id=Atr_ObiNumer and Atr_OBITyp in (3584,3585) and Atr_OBILp = 0 and Atr_OBISubLp = 0 and Atr_AtkId = 488
join cdn.KntKarty with (nolock) on RLN_KntNumer = Knt_GIDNumer and RLN_KntTyp = Knt_GIDTyp
join cdn.rejony with (nolock) on REJ_Id=Knt_RegionCRM
join cdn.kntopiekun with (nolock) on REJ_Id=KtO_KntNumer and KtO_KntTyp=948 and KtO_Glowny = 1
join cdn.prckarty with (nolock) on Prc_GIDNumer=KtO_PrcNumer

group by prc_email
order by prc_email 

OPEN LokalizacjaRLS
FETCH NEXT FROM LokalizacjaRLS INTO @emailOpiekuna
BEGIN
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @tableHTML = 
			N'<h2>Rozpatrzone reklamacje do dos³ania klientowi</h2>' +
			N'<table border="1">' +
			N'<tr><th>Dokument</th>
			<th>Akronim</th>
			<th>Lokalizacja</th>
			<th>Opiekun</th>
			</tr>' +
			CAST ( ( SELECT

			'yellow' AS [@bgcolor],

			td = cdn.NumerDokumentu(RLN_Typ,0,RLN_Typ,RLN_Numer,RLN_Rok,RLN_Seria,RLN_Miesiac),'',

			td = Knt_Akronim, '',

			td = Atr_Wartosc,'',

			td = Prc_Imie1 + ' ' + Prc_Nazwisko

			from cdn.ReklNag
			join cdn.Atrybuty on RLN_Id=Atr_ObiNumer and Atr_OBITyp in (3584,3585) and Atr_OBILp = 0 and Atr_OBISubLp = 0 and Atr_AtkId = 488
			join cdn.KntKarty on RLN_KntNumer = Knt_GIDNumer and RLN_KntTyp = Knt_GIDTyp
			join cdn.rejony with (nolock) on REJ_Id=Knt_RegionCRM
			join cdn.kntopiekun with (nolock) on REJ_Id=KtO_KntNumer and KtO_KntTyp=948 and KtO_Glowny = 1
			join cdn.prckarty with (nolock) on Prc_GIDNumer=KtO_PrcNumer

			where Prc_EMail = @emailOpiekuna
			and convert(date, Dateadd(Second, Atr_LastMod, '1990-01-01')) = convert(date,GETDATE())

			FOR XML PATH('tr'), TYPE 
			) AS NVARCHAR(MAX) ) +
			N'</table>';

			set @temat = 'Rozpatrzone reklamacje do dos³ania klientowi'
			set @odbiorcy = 'it@gaska.com.pl' + @emailOpiekuna + ';'

			EXEC msdb.dbo.sp_send_dbmail
			@profile_name = 'Gaska',
			@recipients=@odbiorcy,
			@subject = @temat,
			@body = @tableHTML,
			@body_format = 'HTML';

		FETCH NEXT FROM LokalizacjaRLS INTO @emailOpiekuna	
	END
END
	
CLOSE LokalizacjaRLS
DEALLOCATE LokalizacjaRLS

