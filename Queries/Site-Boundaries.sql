SELECT        
	dbo.vSMS_Boundary.BoundaryID, 
    dbo.vSMS_Boundary.DisplayName, 
	dbo.vSMS_Boundary.Value,
    dbo.v_BoundarySiteSystems.SiteSystemName,
    'Boundary Type' =
		case
			when dbo.vSMS_Boundary.BoundaryType = 0 Then 'IP Subnet'
			when dbo.vSMS_Boundary.BoundaryType = 1 Then 'Active Directory Site'
			when dbo.vSMS_Boundary.BoundaryType = 2 Then 'IPV6 Prefix'
			when dbo.vSMS_Boundary.BoundaryType = 3 Then 'IP Range'
		end,
	dbo.vSMS_Boundary.GroupCount
FROM            
	dbo.vSMS_Boundary INNER JOIN
	dbo.v_BoundarySiteSystems ON dbo.vSMS_Boundary.BoundaryID = dbo.v_BoundarySiteSystems.BoundaryID
ORDER BY 
	dbo.vSMS_Boundary.DisplayName
