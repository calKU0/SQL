select 
Twr_GIDNumer
,cdn.twrkarty.Twr_Kod
,twj_objetoscL as [Objêtoœæ Gaska]
,TwJ_WymJm as [Jednostka Gaska]
,twj_objetosc as [Objêtoœæ ExpertWMS]
,twj_objetoscjm as [jednostka WMS]
,twj_twrid as [id wms]
from cdn.twrkarty 
join cdn.twrjm on Twr_GIDNumer=TwJ_TwrNumer	
join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_towary] on [ExpertWMS_Gaska_Produkcja].[dbo].[wms_towary].twr_kod = cdn.twrkarty.Twr_Kod
join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_towaryjm] on twr_id = TwJ_twrId
where TwJ_ObjetoscL <> twj_objetosc
and TwJ_JmZ = twj_kod
order by Twr_GIDNumer
