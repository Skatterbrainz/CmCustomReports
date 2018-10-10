SELECT     
	fn_DeploymentSummary_1.PackageID, 
	fn_DeploymentSummary_1.SoftwareName, 
	fn_DeploymentSummary_1.CollectionID, 
	fn_DeploymentSummary_1.CollectionName,           
	'Deployment Type' =
		case
            when fn_DeploymentSummary_1.DeploymentIntent = 1 then 'Required'
            when fn_DeploymentSummary_1.DeploymentIntent = 2 then 'Available'
		end,
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
			fn_DeploymentSummary_1.AssignmentID, fn_DeploymentSummary_1.CI_ID, fn_DeploymentSummary_1.DeploymentID 
FROM
	dbo.fn_DeploymentSummary(1033) AS fn_DeploymentSummary_1 INNER JOIN
	v_Package ON fn_DeploymentSummary_1.PackageID = v_Package.PackageID
