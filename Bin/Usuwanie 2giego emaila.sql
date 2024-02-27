Update cdn.KntKarty
set knt_Email = SUBSTRING (knt_email, 1, CHARINDEX (';', knt_email) - 1)
where Knt_Akronim = 'SAFFA'
--select knt_akronim as Akronim, Knt_EMail as mail, SUBSTRING (knt_email, 1, CHARINDEX (';', knt_email) - 1) AS skr_mail from cdn.KntKarty where Knt_Akronim = 'SAFFA'