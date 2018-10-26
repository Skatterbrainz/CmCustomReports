SELECT DISTINCT 
	dbo.v_R_System.Name0 AS Computer, 
	dbo.v_GS_SoftwareFile.ResourceID, 
	dbo.v_GS_SoftwareFile.FileName,
	dbo.v_GS_SoftwareFile.FilePath,
	dbo.v_GS_SoftwareFile.FileVersion AS ProductVersion, 
	CASE 
		WHEN (dbo.v_GS_SoftwareFile.FilePath LIKE '%x86%') THEN '32'
		ELSE '64' END AS Package
FROM 
	dbo.v_GS_SoftwareFile INNER JOIN
	dbo.v_R_System ON dbo.v_GS_SoftwareFile.ResourceID = dbo.v_R_System.ResourceID
WHERE 
	(dbo.v_GS_SoftwareFile.FileName IN ('WINWORD.exe','VISIO.exe','WINPROJ.exe'))
	AND 
	(dbo.v_GS_SoftwareFile.FileVersion LIKE '16.%')
	AND
	(dbo.v_GS_SoftwareFile.FilePath LIKE '%\Microsoft Office\root\Office16\')
ORDER BY
	Computer
