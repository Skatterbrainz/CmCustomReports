select
	pkg.PackageID,
	pkg.Name as 'Package Name',
	'Package Type' =
		Case
			when pkg.PackageType = 0 Then 'Software Distribution Package'
			when pkg.PackageType = 3 Then 'Driver Package'
			when pkg.PackageType = 4 Then 'Task Sequence Package'
			when pkg.PackageType = 5 Then 'Software Update Package'
			when pkg.PackageType = 6 Then 'Device Setting Package'
			when pkg.PackageType = 7 Then 'Virtual Package'
			when pkg.PackageType = 8 Then 'Application'
			when pkg.PackageType = 257 Then 'Image Package'
			when pkg.PackageType = 258 Then 'Boot Image Package'
			when pkg.PackageType = 259 Then 'Operating System Install Package'
		Else
			'Unknown'
		End, 
	SUBSTRING(dp.ServerNALPath, CHARINDEX('\\', 
    dp.ServerNALPath) + 2, CHARINDEX('"]',   dp.ServerNALPath) - CHARINDEX('\\', 
    dp.ServerNALPath) - 3 ) AS 'Distribution Point',
	dp.SiteCode,
	dp.LastRefreshTime,
	stat.SourceVersion,
	stat.LastCopied,
	stat.SummaryDate,
	(select top 1 msg.InsString3
	from v_StatMsgWithInsStrings msg
	join v_StatMsgModuleNames modNames on msg.ModuleName = modNames.ModuleName
	join v_StatMsgAttributes attpkg on msg.RecordID=attpkg.RecordID and msg.Time=attpkg.AttributeTime
	join v_StatMsgAttributes attdp on msg.RecordID=attdp.RecordID and msg.Time=attdp.AttributeTime
	where attpkg.AttributeValue =pkg.PackageID and msg.MessageID='8204'
	and msg.InsString2 =  SUBSTRING(dp.ServerNALPath, CHARINDEX('\\', 
    dp.ServerNALPath) + 2, CHARINDEX('"]', dp.ServerNALPath) - CHARINDEX('\\', 
    dp.ServerNALPath) - 3 ) 
 order by 
    msg.Time desc) as '% Completed',
    stat.InstallStatus
 from v_Package pkg
	join v_DistributionPoint dp on pkg.PackageID=dp.PackageID
	join v_PackageStatusDistPointsSumm stat on dp.ServerNALPath=stat.ServerNALPath
 and 
	dp.PackageID=stat.PackageID
 where 
	stat.State!=0
 order by 
	pkg.Name, dp.SiteCode
