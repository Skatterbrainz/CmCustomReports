SELECT DISTINCT 
	dbo.v_R_System.Name0 AS Computer, 
	dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductName0 AS ProductName, 
	dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductVersion0 AS Version, 
	dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.InstalledLocation0 AS InstallPath, 
	CASE 
		WHEN (RTRIM(ProductVersion0) = '16.0.9126.2282') THEN 'S1803 09' 
		WHEN (RTRIM(ProductVersion0) = '16.0.9126.2275') THEN 'S1803 07' 
		WHEN (RTRIM(ProductVersion0) = '16.0.9001.2171') THEN 'M1801 02' 
		WHEN (RTRIM(ProductVersion0) = '16.0.9126.2259') THEN 'S1803 08' 
		WHEN (RTRIM(ProductVersion0) = '16.0.10730.20102') THEN 'M1808 09' 
		WHEN (RTRIM(ProductVersion0) = '16.0.10730.20138') THEN 'M1809 09' 
		WHEN (RTRIM(ProductVersion0) = '16.0.10730.20127') THEN 'M1808 08' 
		WHEN (RTRIM(ProductVersion0) = '16.0.10325.20082') THEN 'M1807 07' 
		WHEN (RTRIM(ProductVersion0) = '16.0.10827.20138') THEN 'M1809 09' 
		ELSE '' END AS Build, 
	CASE 
		WHEN (v_GS_INSTALLED_SOFTWARE_CATEGORIZED.InstalledLocation0 LIKE '%x86%') THEN '32' 
		ELSE '64' END AS Pkg, 
	dbo.vWorkstationStatus.LastHardwareScan as LastHwInv, 
	DATEDIFF(dd, dbo.vWorkstationStatus.LastHardwareScan, GETDATE()) AS InvAge
FROM            
	dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED INNER JOIN
	dbo.v_R_System ON dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ResourceID = dbo.v_R_System.ResourceID LEFT OUTER JOIN
	dbo.vWorkstationStatus ON dbo.v_R_System.ResourceID = dbo.vWorkstationStatus.ResourceID
WHERE        
	dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductName0 LIKE 'Microsoft Office Professional Plus %'
	OR
	dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductName0 LIKE 'Microsoft Office Project %'
	OR
	dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductName0 LIKE 'Microsoft Project Professional %'
	OR
	dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductName0 LIKE 'Microsoft Project Standard %'
	OR 
	dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductName0 LIKE 'Microsoft Office Visio %'
	OR
	dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductName0 LIKE 'Microsoft Visio Professional %'
	OR
	dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductName0 LIKE 'Microsoft Visio Standard %'
ORDER BY 
	Computer, ProductName
