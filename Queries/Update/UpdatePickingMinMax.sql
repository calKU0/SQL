DECLARE @IleMiesiecyPickingMin int = 1;
DECLARE @IleMiesiecyPickingMax int = 3;


UPDATE [ExpertWMS_Gaska_Produkcja].dbo.TwrStanyMaksymalne

SET TSM_PickingMin = isnull(ceiling(case when 
       PickingMin.ilosc is null then (SprzedazRok.ilosc/12)* @IleMiesiecyPickingMin
       else
             case when PickingMin.ilosc<(SprzedazRok.ilosc/12)* @IleMiesiecyPickingMin
                    then (SprzedazRok.ilosc/12)* @IleMiesiecyPickingMin
                    else  PickingMin.ilosc end
       end),0)
,TSM_PickingMax = isnull(ceiling(case when 
       PickingMax.ilosc is null then (SprzedazRok.ilosc/12)* @IleMiesiecyPickingMax
       else
             case when PickingMax.ilosc<(SprzedazRok.ilosc/12)* @IleMiesiecyPickingMax
                    then (SprzedazRok.ilosc/12)* @IleMiesiecyPickingMax
                    else  PickingMax.ilosc end
       end),0)
FROM CDN.TwrKARTY WITH (NOLOCK) 
LEFT JOIN (  
    SELECT TrE_TwrNumer, count(trn_gidnumer) as licznik, SUM(TrS_Ilosc) AS ilosc  
    FROM CDN.TraNag WITH (NOLOCK)  
    JOIN CDN.traelem WITH (NOLOCK) ON TrN_GIDTyp = TrE_GIDTyp AND TrN_GIDNumer = TrE_GIDNumer  
    JOIN CDN.traselem WITH (NOLOCK) ON TrE_GIDTyp = TrS_GIDTyp AND TrE_GIDNumer = TrS_GIDNumer AND TrE_GIDLp = TrS_GIDLp  
    WHERE trn_gidTyp IN (2033, 2034, 2041, 2042, 2001, 2009, 2037, 2045, 2005, 2013)  AND TrS_MagNumer = 1  AND TrS_Ilosc <> 0  
    AND DATEADD(DAY, trn_data2, CONVERT(DATE, '18001228', 104)) BETWEEN DATEADD(YEAR, -1, GETDATE()) AND DATEADD(MONTH, @IleMiesiecyPickingMin, DATEADD(YEAR, -1, GETDATE())) 
    GROUP BY TrE_TwrNumer  
) PickingMin ON Twr_GIDNumer = PickingMin.TrE_TwrNumer
LEFT JOIN (  
    SELECT TrE_TwrNumer, count(trn_gidnumer) as licznik, SUM(TrS_Ilosc) AS ilosc  
    FROM CDN.TraNag WITH (NOLOCK)  
    JOIN CDN.traelem WITH (NOLOCK) ON TrN_GIDTyp = TrE_GIDTyp AND TrN_GIDNumer = TrE_GIDNumer  
    JOIN CDN.traselem WITH (NOLOCK) ON TrE_GIDTyp = TrS_GIDTyp AND TrE_GIDNumer = TrS_GIDNumer AND TrE_GIDLp = TrS_GIDLp  
    WHERE trn_gidTyp IN (2033, 2034, 2041, 2042, 2001, 2009, 2037, 2045, 2005, 2013)  AND TrS_MagNumer = 1  AND TrS_Ilosc <> 0  
    AND DATEADD(DAY, trn_data2, CONVERT(DATE, '18001228', 104)) BETWEEN DATEADD(YEAR, -1, GETDATE()) AND DATEADD(MONTH, @IleMiesiecyPickingMax, DATEADD(YEAR, -1, GETDATE())) 
    GROUP BY TrE_TwrNumer  
) PickingMax ON Twr_GIDNumer = PickingMax.TrE_TwrNumer
LEFT JOIN (  
    SELECT TrE_TwrNumer, count(trn_gidnumer) as licznik, SUM(TrS_Ilosc) AS ilosc  
    FROM CDN.TraNag WITH (NOLOCK)  
    JOIN CDN.traelem WITH (NOLOCK) ON TrN_GIDTyp = TrE_GIDTyp AND TrN_GIDNumer = TrE_GIDNumer  
    JOIN CDN.traselem WITH (NOLOCK) ON TrE_GIDTyp = TrS_GIDTyp AND TrE_GIDNumer = TrS_GIDNumer AND TrE_GIDLp = TrS_GIDLp  
    WHERE trn_gidTyp IN (2033, 2034, 2041, 2042, 2001, 2009, 2037, 2045, 2005, 2013)  AND TrS_MagNumer = 1  AND TrS_Ilosc <> 0  
    AND DATEADD(DAY, trn_data2, CONVERT(DATE, '18001228', 104)) BETWEEN DATEADD(YEAR, -1, GETDATE()) AND GETDATE() 
    GROUP BY TrE_TwrNumer  
) SprzedazRok ON Twr_GIDNumer = SprzedazRok.TrE_TwrNumer

join [ExpertWMS_Gaska_Produkcja].dbo.wms_exp_towaryp on etp_sysid = Twr_GIDNumer
join [ExpertWMS_Gaska_Produkcja].dbo.twrstanymaksymalne on etp_twrid = TSM_TwrNumer
