SELECT 
	SiteCode,
	SiteName,
	ReportingSiteCode,
	[Version],
	[Type],
	[Status],
	RequestedStatus,
	BuildNumber,
	ServerName,
	InstallDir,
	TimeZoneInfo
FROM 
	dbo.v_Site
ORDER BY
	SiteCode
