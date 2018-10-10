SELECT 
	fn_DeploymentSummary_1.PackageID, 
	fn_DeploymentSummary_1.SoftwareName as Name, 
	fn_DeploymentSummary_1.CollectionID, 
    fn_DeploymentSummary_1.CollectionName, 
    CASE 
		WHEN fn_DeploymentSummary_1.DeploymentIntent = 1 THEN 'Required' 
		WHEN fn_DeploymentSummary_1.DeploymentIntent = 2 THEN 'Available' 
	END AS 'Deployment Type',
	fn_DeploymentSummary_1.DeploymentID, 
    v_Package_1.PackageID AS 'Boot Image Package ID', 
	v_Package_1.Name AS 'Boot Image Package Name', 
	v_Package_1.PkgSourcePath AS 'Boot Image PkgSourcePath'
FROM 
	dbo.fn_DeploymentSummary(1033) AS fn_DeploymentSummary_1 INNER JOIN
    v_Package ON fn_DeploymentSummary_1.PackageID = v_Package.PackageID INNER JOIN
    v_TaskSequencePackageReferences ON fn_DeploymentSummary_1.PackageID = v_TaskSequencePackageReferences.PackageID INNER JOIN
    v_Package AS v_Package_1 ON v_TaskSequencePackageReferences.RefPackageID = v_Package_1.PackageID
WHERE 
	(v_Package.PackageType = 4 and v_Package_1.PackageType = 258)
ORDER BY
	Name 
