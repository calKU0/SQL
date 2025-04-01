SET NOCOUNT ON;

IF EXISTS(select * from kkur.ApiLogs where MailSent = 0 and Success = 0)
BEGIN

	DECLARE @tableHTML varchar(MAX)
	DECLARE @Temat varchar(255)

	set @Temat = 'B³êdy synchronizacji z WMS'

	SET @tableHTML = 

	N'<h2>' + @Temat + '</h2>' +
	N'<table border="1">' +
	N'<tr>
	<th>Kierunek synchronizacji</th>
	<th>ERP ID</th>
	<th>ERP Typ</th>
	<th>WMS ID</th>
	<th>WMS Typ</th>
	<th>Przyczyna b³êdu</th>	
	<th>Data wyst¹pienia</th>
	</tr>' +
	CAST ( ( SELECT

	'red' as [@bgcolor], '',
	td = case when Flow = 'IN' then 'Do ERP' else 'Do WMS' end,'',
	td = EntityErpId,'',
	td = EntityErpType,'',
	td = EntityWmsId,'',
	td = EntityWmsType,'',
	td = ErrorMessage,'',
	td = CreatedDate,''

	from kkur.ApiLogs

	where MailSent = 0 and Success = 0

	FOR XML PATH('tr'), TYPE 
	) AS NVARCHAR(MAX) ) +
	N'</table>';

	EXEC msdb.dbo.sp_send_dbmail
	@profile_name = 'Gaska',
	@recipients = '',
	@subject = @Temat,
	@body = @tableHTML,
	@body_format = 'HTML'
END

	update kkur.ApiLogs
	set MailSent = 1 
	where MailSent = 0 and Success = 0
