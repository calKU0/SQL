update cdn.twrkarty set twr_nazwa = twr_nazwa where twr_kod in (select top 50 b.twr_kod
from [ExpertWMS_Gaska_Produkcja].[dbo].[wms_towary] b
join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_towaryjm] on b.twr_id = twj_twrid
where twj_przelicz <> 1 and twj_objetosc = 0)