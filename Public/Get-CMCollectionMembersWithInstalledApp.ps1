[CmdletBinding()]
param (
    [parameter(Mandatory=$True, HelpMessage="Product Name")]
        [ValidateNotNullOrEmpty()]
        [string] $CollectionID,
    [parameter(Mandatory=$True, HelpMessage="Product Name")]
        [ValidateNotNullOrEmpty()]
        [string] $ProductName,
    [parameter(Mandatory=$False, HelpMessage="Product Version")]
        [string] $ProductVersion = "",
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr DB Server Name")]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName,
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr Site Code")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode
)

$DatabaseName = "CM_$SiteCode"

$query = @"
SELECT DISTINCT 
	dbo.v_R_System.Name0 AS ComputerName, 
	dbo.v_GS_INSTALLED_SOFTWARE.ProductName0 AS ProductName, 
	dbo.v_GS_INSTALLED_SOFTWARE.ProductVersion0 AS ProductVersion
FROM 
	dbo.v_GS_INSTALLED_SOFTWARE INNER JOIN
    dbo.v_R_System ON dbo.v_GS_INSTALLED_SOFTWARE.ResourceID = dbo.v_R_System.ResourceID
WHERE
	Name0 IN (
		SELECT DISTINCT [Name] FROM dbo.v_ClientCollectionMembers WHERE CollectionID = '$CollectionID'
	)
	AND ((dbo.v_GS_INSTALLED_SOFTWARE.ProductName0 LIKE '`%$ProductName`%'))
"@

if ($ProductVersion -ne "") {
    $query += "AND (dbo.v_GS_INSTALLED_SOFTWARE.ProductVersion0 LIKE '$ProductVersion`%')"
}

Write-Verbose "query...... $query"
Write-Verbose "server..... $ServerName"
Write-Verbose "database... $DatabaseName"
#Timeout parameters
$QueryTimeout = 120
$ConnectionTimeout = 30
$conn = New-Object System.Data.SqlClient.SQLConnection
$ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerName,$DatabaseName,$ConnectionTimeout
$conn.ConnectionString = $ConnectionString
$conn.Open()
$cmd = New-Object System.Data.SqlClient.SqlCommand($Query,$conn)
$cmd.CommandTimeout = $QueryTimeout
$ds = New-Object System.Data.DataSet
$da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
[void]$da.Fill($ds)
$conn.Close()
$rows = $($ds.Tables).Rows.Count
$($ds.Tables).Rows
