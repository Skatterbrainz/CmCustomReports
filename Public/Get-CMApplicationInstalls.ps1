<#
.DESCRIPTION
    Query all software product installations in ConfigMgr database
.PARAMETER ProductName
    Full or Partial name of product to filter on
.PARAMETER ProductVersion
    Optional: 
.PARAMETER ServerName
    ConfigMgr SQL Server host name (FQDN)
.PARAMETER
    ConfigMgr Site Code
.EXAMPLE
    .\Get-CMApplicationInstalls.ps1 -ServerName "cm01.contoso.local" -SiteCode "P01" -ProductName "Visual C++ 2013 x64"
.EXAMPLE
    .\Get-CMApplicationInstalls.ps1 -ServerName "cm01.contoso.local" -SiteCode "P01" -ProductName "Visual C++ 2013 x64" -ProductVersion "16.0"
.NOTES
    1.0.0 - DS - Initial release
#>
[CmdletBinding()]
param (
    [parameter(Mandatory=$True, HelpMessage="Product Name to query")]
        [ValidateNotNullOrEmpty()]
        [string] $ProductName,
    [parameter(Mandatory=$False, HelpMessage="Product Version to include in query")]
        [string] $ProductVersion = "",
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr DB Server Name")]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName,
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr Site Code")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode
)
$DatabaseName = "CM_$SiteCode"
$QueryTimeout = 120
$ConnectionTimeout = 30

$query = @"
SELECT DISTINCT 
dbo.v_R_System.Name0 AS [ComputerName], 
dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductName0 AS [ProductName],
dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductVersion0 AS [ProductVersion],
dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.Publisher0 AS [Publisher],
dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductCode0 AS [ProductCode] 
FROM dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED INNER JOIN
dbo.v_R_System ON dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ResourceID = dbo.v_R_System.ResourceID
WHERE (dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductName0 like `'$ProductName`%`')
"@
if (![string]::IsNullOrEmpty($ProductVersion)) {
    $Query += " AND (ProductVersion0 like `'$ProductVersion`%`')"
}

try {
    $conn = New-Object System.Data.SqlClient.SQLConnection
    $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerName,$DatabaseName,$ConnectionTimeout
    $conn.ConnectionString = $ConnectionString
    $conn.Open()
    $cmd = New-Object System.Data.SqlClient.SqlCommand($Query,$conn)
    $cmd.CommandTimeout = $QueryTimeout
    $ds = New-Object System.Data.DataSet
    $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    [void]$da.Fill($ds)
    foreach ($row in $($ds.Tables).Rows) {
        $props = [ordered]@{
            ComputerName   = $row.ComputerName | Out-String
            ProductName    = $row.ProductName | Out-String
            ProductVersion = $row.ProductVersion | Out-String
            Publisher      = $row.Publisher | Out-String
            ProductCode    = $row.ProductCode | Out-String
        }
        New-Object -TypeName PSObject -Property $props
    }
}
catch {
    Write-Error $Error[0].Exception.Message
}
finally {
    $conn.Close()
}
