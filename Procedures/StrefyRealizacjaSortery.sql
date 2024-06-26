USE [CDNXL_GASKA]
GO
/****** Object:  StoredProcedure [dbo].[StrefyRealizacjaSortery]    Script Date: 2024.06.18 10:34:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[StrefyRealizacjaSortery]

AS
BEGIN

	SET NOCOUNT ON;

declare @data int = dbo.wms_data2int(getdate())
	SELECT 
	'GÓRA' as [Sorter]
	,ISNULL(sum(case when a.pon_trasa is not null then 1 else 0 end),0) as [Ilość razem]
	,ISNULL(sum(case when a.pon_trasa in (5,25,24,22) then 1 else 0 end),0) AS [DPD]
	,ISNULL(sum(case when a.pon_trasa = 21 then 1 else 0 end),0) AS [FEDEX]
	,ISNULL(sum(case when a.pon_trasa in (6,19) then 1 else 0 end),0) AS [GLS]
	,ISNULL(sum(case when a.pon_trasa = 23 then 1 else 0 end),0) AS [DPD_R]
	,ISNULL(sum(case when a.pon_trasa not in (5,6,23,21,24,25,22,19) then 1 else 0 end),0) AS [INNE]
	,isnull((select count(distinct prn_opeid) from  [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecrnag] rr with(nolock) where rr.prn_pontyp=a.pon_typ and (
																	   rr.prn_stan=1 or  (convert(date, convert(datetime,rr.prn_datazat,104))=convert(date, convert(datetime,getdate(),104))        
																	   and DATEADD(second, rr.prn_czaszat, CAST('00:00:00' AS TIME))  
																	   between CONVERT(TIME, DATEADD(second,-30,getdate()))  and CONVERT(TIME, DATEADD(second,0,getdate()))))),0) as [Ope]
	,cast(isnull(stuff((select distinct ','+ope_user from 
											[ExpertWMS_Gaska_Produkcja].[dbo].[wms_operatorzy] with(nolock)
											join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecrnag] with(nolock) on prn_pontyp=pon_typ and 
																	   ((prn_opeid=ope_id and prn_stan=1)       
																	   or (prn_opeid=ope_id and convert(date, convert(datetime,prn_datazat,104))=convert(date, convert(datetime,getdate(),104))        
																	   and DATEADD(second, prn_czaszat, CAST('00:00:00' AS TIME))  
																	   between CONVERT(TIME, DATEADD(second,-30,getdate()))  and CONVERT(TIME, DATEADD(second,0,getdate()))))for xml path('')),1,1,''),'') as varchar(100)) as [Zalogowani]

    ,null as [Czas zatwierdzenia PAK-OUT]                 
	FROM  [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecnag] a with(nolock)
	JOIN [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecelem]  with(nolock) ON a.pon_id=poe_id and a.pon_typ=poe_typ and poe_lp>0 and poe_iloscdorealiz<>poe_ilosczrealiz
	join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_exp_polecpowiaz] with (nolock) on epp_typ=pon_typ and epp_numer=pon_id

	where pon_status in (1,2) and pon_zrdid<>0 and left(A.pon_nrdok,9) like 'PAK-REG%'
	GROUP BY left(A.pon_nrdok,9), a.pon_typ
UNION ALL
	SELECT 
	'DÓŁ' as [Sorter]
	,ISNULL(sum(case when a.pon_trasa is not null then 1 else 0 end),0) as [Ilość razem]
	,ISNULL(sum(case when a.pon_trasa in (5,25,24,22) then 1 else 0 end),0) AS [DPD]
	,ISNULL(sum(case when a.pon_trasa = 21 then 1 else 0 end),0) AS [FEDEX]
	,ISNULL(sum(case when a.pon_trasa in (6,19) then 1 else 0 end),0) AS [GLS]
	,ISNULL(sum(case when a.pon_trasa = 23 then 1 else 0 end),0) AS [DPD_R]
	,ISNULL(sum(case when a.pon_trasa not in (5,6,23,21,24,25,22,19) then 1 else 0 end),0) AS [INNE]
	,isnull((select count(distinct prn_opeid) from  [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecrnag] rr with(nolock) where rr.prn_pontyp=a.pon_typ and (
																rr.prn_stan=1 or  (convert(date, convert(datetime,rr.prn_datazat,104))=convert(date, convert(datetime,getdate(),104))        
																and DATEADD(second, rr.prn_czaszat, CAST('00:00:00' AS TIME))  
																between CONVERT(TIME, DATEADD(second,-30,getdate()))  and CONVERT(TIME, DATEADD(second,0,getdate()))))),0) as [Ope]
                                                            
	,cast(isnull(stuff((select distinct ','+ope_user from 
											[ExpertWMS_Gaska_Produkcja].[dbo].[wms_operatorzy] with(nolock)
											join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecrnag] with(nolock) on prn_pontyp=pon_typ and 
																	   ((prn_opeid=ope_id and prn_stan=1)       
																	   or (prn_opeid=ope_id and convert(date, convert(datetime,prn_datazat,104))=convert(date, convert(datetime,getdate(),104))        
																	   and DATEADD(second, prn_czaszat, CAST('00:00:00' AS TIME))  
																	   between CONVERT(TIME, DATEADD(second,-30,getdate()))  and CONVERT(TIME, DATEADD(second,0,getdate()))))for xml path('')),1,1,''),'') as varchar(100)) as [Zalogowani]
	
	,ISNULL((select top 1 DATEADD(second, pon_czaszat, CAST('00:00:00' AS TIME))
	FROM [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecnag] with(nolock)
	where pon_status in (1,2) and pon_zrdid<>0 and left(pon_nrdok,9) like 'PAK-out%'
	order by pon_czaszat),convert(time, getdate())) as [Czas zatwierdzenia PAK-OUT]
	
	FROM  [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecnag] a with(nolock)
	jOIN [ExpertWMS_Gaska_Produkcja].[dbo].[wms_polecelem]  with(nolock) ON a.pon_id=poe_id and a.pon_typ=poe_typ and poe_lp>0 and poe_iloscdorealiz<>poe_ilosczrealiz
	join [ExpertWMS_Gaska_Produkcja].[dbo].[wms_exp_polecpowiaz] with (nolock) on epp_typ=pon_typ and epp_numer=pon_id

where pon_status in (1,2) and pon_zrdid<>0 and left(A.pon_nrdok,9) like 'PAK-out%'
	GROUP BY left(A.pon_nrdok,9), a.pon_typ

END
