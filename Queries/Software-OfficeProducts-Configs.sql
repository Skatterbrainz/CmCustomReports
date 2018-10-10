/****** Script for SelectTopNRows command from SSMS  ******/
SELECT DISTINCT
	KeyName0 AS KeyName,
	VersionToReport0 AS [Version],
	CCMManaged0 AS CCMManaged,
	OfficeMgmtCOM0 AS OMC,
	Platform0 AS InstallType,
	SharedComputerLicensing0 AS Shared,
	COUNT(*) AS Clients
FROM 
	dbo.v_HS_OFFICE365PROPLUSCONFIGURATIONS
GROUP BY
	CCMManaged0,
	KeyName0,
	OfficeMgmtCOM0,
	Platform0,
	SharedComputerLicensing0,
	VersionToReport0
ORDER BY
	VersionToReport0
