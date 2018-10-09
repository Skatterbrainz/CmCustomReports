SELECT DISTINCT 
    dbo.vWorkstationStatus.Name, 
	dbo.vWorkstationStatus.UserName,
	dbo.v_GS_OPERATING_SYSTEM.Caption0 AS OperatingSystem, 
    CASE 
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 10586) THEN '1511' 
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 14393) THEN '1607' 
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 15063) THEN '1703' 
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 16299) THEN '1709' 
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 17134) THEN '1803' 
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 7601) THEN 'SP1' 
		WHEN (dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 = 9600) THEN 'RTM' 
		ELSE dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 END AS OsBuild, 
    dbo.vWorkstationStatus.SystemType, 
	dbo.vWorkstationStatus.ClientVersion, 
	dbo.vWorkstationStatus.UserDomain, 
	dbo.v_R_System.AD_Site_Name0 AS ADSite, 
    dbo.v_GS_COMPUTER_SYSTEM.Model0 AS Model, 
	dbo.v_GS_SYSTEM_ENCLOSURE.SerialNumber0 AS SerialNumber, 
    CASE 
		WHEN (dbo.vWorkstationStatus.IsVirtualMachine = 1) THEN 'Y' 
		ELSE 'N' END AS IsVM, 
    dbo.vWorkstationStatus.LastHealthEvaluationResult AS LastHealthEval, 
	dbo.vWorkstationStatus.LastHardwareScan AS LastHwScan, 
	DATEDIFF(dd,dbo.vWorkstationStatus.LastHardwareScan,GETDATE()) AS InvAge,
    dbo.vWorkstationStatus.LastDDR
FROM 
	dbo.vWorkstationStatus INNER JOIN
    dbo.v_R_System ON dbo.vWorkstationStatus.ResourceID = dbo.v_R_System.ResourceID LEFT OUTER JOIN
    dbo.v_GS_SYSTEM_ENCLOSURE ON dbo.vWorkstationStatus.ResourceID = dbo.v_GS_SYSTEM_ENCLOSURE.ResourceID LEFT OUTER JOIN
    dbo.v_GS_COMPUTER_SYSTEM ON dbo.vWorkstationStatus.ResourceID = dbo.v_GS_COMPUTER_SYSTEM.ResourceID LEFT OUTER JOIN
    dbo.v_GS_OPERATING_SYSTEM ON dbo.vWorkstationStatus.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID
ORDER BY 
	dbo.vWorkstationStatus.Name
