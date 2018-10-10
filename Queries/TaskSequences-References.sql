SELECT        fn_DeploymentSummary_1.PackageID, 
			  fn_DeploymentSummary_1.SoftwareName, 
			  fn_DeploymentSummary_1.CollectionID, 
              fn_DeploymentSummary_1.CollectionName, 
              CASE 
					WHEN fn_DeploymentSummary_1.DeploymentIntent = 1 THEN 'Required' 
					WHEN fn_DeploymentSummary_1.DeploymentIntent = 2 THEN 'Available' 
			  END AS 'Deployment Type',
              CASE 
					WHEN v_Package.PackageType = 0 THEN 'Software Distribution Package' 
					WHEN v_Package.PackageType = 3 THEN 'Driver Package' 
					WHEN v_Package.PackageType = 4 THEN 'Task Sequence Package' 
					WHEN v_Package.PackageType = 5 THEN 'Software Update Package' 
					WHEN v_Package.PackageType = 6 THEN 'Device Setting Package'
                    WHEN v_Package.PackageType = 7 THEN 'Virtual Package' 
					WHEN v_Package.PackageType = 8 THEN 'Application' 
					WHEN v_Package.PackageType = 257 THEN 'Image Package'
                    WHEN v_Package.PackageType = 258 THEN 'Boot Image Package' 
					WHEN v_Package.PackageType = 259 THEN 'Operating System Install Package' 
			  ELSE 
				'Unknown'
              END AS 'Package Type', 
			  fn_DeploymentSummary_1.DeploymentID, 
              v_Package_1.PackageID AS Reference_PackageID, 
			  v_Package_1.Name AS Reference_PackageName, 
			  v_Package_1.PkgSourcePath AS Reference_PkgSourcePath,               
              CASE 
					WHEN v_Package_1.PackageType = 0 THEN 'Software Distribution Package' 
					WHEN v_Package_1.PackageType = 3 THEN 'Driver Package' 
					WHEN v_Package_1.PackageType = 4 THEN 'Task Sequence Package' 
					WHEN v_Package_1.PackageType = 5 THEN 'Software Update Package' 
					WHEN v_Package_1.PackageType = 6 THEN 'Device Setting Package'
                    WHEN v_Package_1.PackageType = 7 THEN 'Virtual Package' 
					WHEN v_Package_1.PackageType = 8 THEN 'Application' 
					WHEN v_Package_1.PackageType = 257 THEN 'Image Package'
                    WHEN v_Package_1.PackageType = 258 THEN 'Boot Image Package' 
					WHEN v_Package_1.PackageType = 259 THEN 'Operating System Install Package' 
			  ELSE 
				'Unknown'
              END AS 'Reference Package Type',
			  v_Package_1.PackageType AS Reference_PackageType
FROM          dbo.fn_DeploymentSummary(1033) AS fn_DeploymentSummary_1 INNER JOIN
                         v_Package ON fn_DeploymentSummary_1.PackageID = v_Package.PackageID INNER JOIN
                         v_TaskSequencePackageReferences ON fn_DeploymentSummary_1.PackageID = v_TaskSequencePackageReferences.PackageID INNER JOIN
                         v_Package AS v_Package_1 ON v_TaskSequencePackageReferences.RefPackageID = v_Package_1.PackageID
WHERE        (v_Package.PackageType = 4)
