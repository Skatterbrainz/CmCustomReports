SELECT DISTINCT 
	app.Manufacturer, 
	app.DisplayName, 
	app.SoftwareVersion, 
	dt.DisplayName AS DeploymentTypeName, 
	dt.PriorityInLatestApp, 
	dt.Technology,
	v_ContentInfo.ContentSource, 
	v_ContentInfo.SourceSize
FROM 
	dbo.fn_ListDeploymentTypeCIs(1033) AS dt 
	INNER JOIN
	dbo.fn_ListLatestApplicationCIs(1033) AS app ON dt.AppModelName = app.ModelName 
	LEFT OUTER JOIN
	v_ContentInfo ON dt.ContentId = v_ContentInfo.Content_UniqueID
WHERE 
	(dt.IsLatest = 1)
ORDER BY
	Manufacturer,
	DisplayName
