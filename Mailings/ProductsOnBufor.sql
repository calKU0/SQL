SET NOCOUNT ON;

DECLARE @emailOpiekuna varchar(255)
DECLARE @temat varchar(255)
DECLARE @odbiorcy varchar(255)
DECLARE @tableHTML varchar(MAX)
BEGIN

	SET @tableHTML = 

	N'<h2>Towary na buforze przyjêæ ' + ltrim(convert(date, getdate())) + '</h2><br><br>' +
	N'<h3 style = color:green;>Zielony - Towary których nie ma na ¿adnej lokalizacji</h3>' +
	N'<h3 style = color:orange;>¯ó³ty - Towary które s¹ na lokalizacjach</h3>' +
	N'<table border="1">' +
	N'<tr><th>Kod</th><th>Nazwa</th><th>Iloœæ</th><th>Data ostatniego przyjêcia</th><th>Kuweta</th></tr>' +
	CAST ( ( SELECT

	case when (select count(twa_mgaid) from wms_twrzasobymag with(nolock) where twa_mgaid <> 14729 and twa_twrid = twr_id) = 0 then 'lime' else 'yellow' end AS [@bgcolor],

	td = twr_kod,'',
	td = twr_nazwa,'',
	td = convert(decimal(15,2),twa_ilosc),'',
	td = Dateadd(Second,(select top 1 pre_tstamp from wms_polecrelem where pre_twrid = twr_id and pre_mgaid = 14729 and pre_przychrozch = 1 order by pre_tstamp desc), '1990-01-01'),'',
	td = jlt_kod,''

	from wms_twrzasobymag with(nolock)
	join wms_towary with(nolock) on twr_id = twa_twrid
	join wms_jl with(nolock) on twa_jltid = jlt_id

	where twa_mgaid = 14729

	order by case when (select count(twa_mgaid) from wms_twrzasobymag with(nolock) where twa_mgaid <> 14729 and twa_twrid = twr_id) = 0 then 0 else 1 end, (select top 1 pre_tstamp from wms_polecrelem where pre_twrid = twr_id and pre_mgaid = 14729 and pre_przychrozch = 1 order by pre_tstamp) desc, jlt_kod, twr_kod

	FOR XML PATH('tr'), TYPE 
	) AS NVARCHAR(MAX) ) +
	N'</table>';

	set @temat = 'Towary na buforze przyjêæ ' + ltrim(convert(date, getdate()))
	set @odbiorcy = ''
	EXEC msdb.dbo.sp_send_dbmail
	@profile_name = 'Gaska',
	@recipients=@odbiorcy,
	@subject = @temat,
	@body = @tableHTML,
	@body_format = 'HTML';

END