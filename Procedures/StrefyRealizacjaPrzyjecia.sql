USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [dbo].[StrefyRealizacjaPrzyjęcia]    Script Date: 2024.06.18 10:34:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[StrefyRealizacjaPrzyjęcia] 

AS
BEGIN

	SET NOCOUNT ON;

declare @data int = dbo.wms_data2int(getdate())

;WITH Przyjecia AS (
    SELECT 
		convert(varchar,isnull(count(distinct pon_id),0)) + '/' + convert(varchar,isnull(sum(CASE WHEN WRE.WREAL_DOK IS NOT NULL THEN 1 ELSE 0 END),0)) as [Ilosc] 
		,cast(isnull(stuff((select distinct ','+ope_user from 
											[ExpertWMS_Gaska_Produkcja].[dbo].[wms_operatorzy] with(nolock)
											join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecrnag] with(nolock) on prn_pontyp=pon_typ and 
																	   ((prn_opeid=ope_id and prn_stan=1)       
																	   or (prn_opeid=ope_id and convert(date, convert(datetime,prn_datazat,104))=convert(date, convert(datetime,getdate(),104))        
																	   and DATEADD(second, prn_czaszat, CAST('00:00:00' AS TIME))  
																	   between CONVERT(TIME, DATEADD(second,-30,getdate()))  and CONVERT(TIME, DATEADD(second,0,getdate()))))for xml path('')),1,1,''),'') as varchar(100)) as [Zalogowani]

		,isnull((select count(distinct prn_opeid) from  [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecrnag] rr with(nolock) where rr.prn_pontyp=a.pon_typ and (
																	   rr.prn_stan=1 or  (convert(date, convert(datetime,rr.prn_datazat,104))=convert(date, convert(datetime,getdate(),104))        
																	   and DATEADD(second, rr.prn_czaszat, CAST('00:00:00' AS TIME))  
																	   between CONVERT(TIME, DATEADD(second,-30,getdate()))  and CONVERT(TIME, DATEADD(second,0,getdate()))))),0) as [Ope]
		,a.pon_typ as [Typ]
    FROM [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecnag] a with(nolock)
    LEFT JOIN (select DISTINCT(XX.pon_nrdokobcy) AS REAL_DOK from [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecnag] XX with(nolock) WHERE XX.pon_status<>1 AND XX.pon_zrdid<>0) RE ON RE.REAL_DOK = A.pon_nrdokobcy
    LEFT JOIN (select DISTINCT(XXX.pon_id) AS WREAL_DOK
               from [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecnag] XXX with(nolock) 
               join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecrnag] with (nolock) on prn_pontyp = XXX.pon_typ and prn_ponid = XXX.pon_id
               WHERE (XXX.pon_status = 1 or prn_stan = 1) 
              ) WRE ON WRE.WREAL_DOK = A.pon_id
    JOIN [ExpertWMS_Gaska_Produkcja].[dbo].[wms_exp_polecpowiaz] with (nolock) on epp_typ = pon_typ and epp_numer = pon_id
    WHERE pon_status IN (1,2) and pon_typ in (2130005,2110501,2110003)
	GROUP BY left(A.pon_nrdok,9), a.pon_typ
)

Select 
'Przyjęcia' as [Typ]
,Ilosc as [IL. DOK/R]
,Zalogowani as [Zalogowani]
,Ope as [Operatorzy]
from Przyjecia
where typ = 2110003

UNION ALL

Select 
'Przyjęcia korekty' as [Typ]
,Ilosc as [IL. DOK/R]
,Zalogowani as [Zalogowani]
,Ope as [Operatorzy]
from Przyjecia
where typ = 2110501

UNION ALL

Select 
'Zatowarowania' as [Typ]
,Ilosc as [IL. DOK/R]
,Zalogowani as [Zalogowani]
,Ope as [Operatorzy]
from Przyjecia
where typ = 2130005



END