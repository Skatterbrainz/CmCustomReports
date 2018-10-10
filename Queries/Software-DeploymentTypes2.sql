SELECT 
	v_Package.PackageID,
	v_Package.Name as 'Package Name',
	'Package Type' =
	Case
		when v_Package.PackageType = 0 Then 'Software Distribution Package'
		when v_Package.PackageType = 3 Then 'Driver Package'
		when v_Package.PackageType = 4 Then 'Task Sequence Package'
		when v_Package.PackageType = 5 Then 'Software Update Package'
		when v_Package.PackageType = 6 Then 'Device Setting Package'
		when v_Package.PackageType = 7 Then 'Virtual Package'
		when v_Package.PackageType = 8 Then 'Application'
		when v_Package.PackageType = 257 Then 'Image Package'
		when v_Package.PackageType = 258 Then 'Boot Image Package'
		when v_Package.PackageType = 259 Then 'Operating System Install Package'
	Else
		'Unknown'
	End,			   
	v_DeploymentSummary.SoftwareName, 
	case
		when v_DeploymentSummary.DeploymentIntent = 1 then 'Required'
		when v_DeploymentSummary.DeploymentIntent = 2 then 'Available'
	else
		'Unknown'
	end as 'Deployment Intent',
	v_Collection.CollectionID, 
	v_Collection.Name AS 'Collection Name',
	v_Collection.MemberCount, 
	v_DeploymentSummary.AssignmentID, 
    v_DeploymentSummary.ModelID
FROM 
	dbo.v_Package left JOIN
	v_DeploymentSummary ON v_Package.PackageID = v_DeploymentSummary.PackageID INNER JOIN
    v_Collection ON v_DeploymentSummary.CollectionID = v_Collection.CollectionID
order by 
	v_Package.Name
