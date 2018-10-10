SELECT 
	Computer, Drive, Size, FreeSpace, PctFree
FROM 
	(SELECT 
		dbo.v_R_System.Name0 AS Computer, 
		dbo.v_GS_LOGICAL_DISK.DeviceID0 AS Drive, 
		dbo.v_GS_LOGICAL_DISK.Size0 AS Size, 
		dbo.v_GS_LOGICAL_DISK.FreeSpace0 AS FreeSpace, 
		CONVERT(integer, ROUND(CONVERT(decimal, dbo.v_GS_LOGICAL_DISK.FreeSpace0) / dbo.v_GS_LOGICAL_DISK.Size0, 2) * 100) AS PctFree
	FROM 
		dbo.v_GS_LOGICAL_DISK INNER JOIN
		dbo.v_R_System ON dbo.v_GS_LOGICAL_DISK.ResourceID = dbo.v_R_System.ResourceID
	WHERE 
		(dbo.v_GS_LOGICAL_DISK.DeviceID0 = 'C:')) AS T1
WHERE 
	(PctFree < 20)
ORDER BY 
	PctFree
