select distinct
KP_KodKreskowyWewnetrzny
,(select max(KP_DataSkanu))
from dbo.kontrolapakowania with(nolock)
where KP_DataSkanu between '2022-07-01' and '2022-08-01'
and datepart(hour,KP_DataSkanu) between 15 and 16
group by KP_KodKreskowyWewnetrzny



