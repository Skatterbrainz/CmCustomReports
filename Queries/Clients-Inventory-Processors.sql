SELECT DISTINCT
  Name0 AS ProcName, 
  DataWidth0 AS Platform, 
  COUNT(*) AS Devices
FROM 
  dbo.v_GS_PROCESSOR
GROUP BY 
  Name0, DataWidth0
ORDER BY 
  ProcName
