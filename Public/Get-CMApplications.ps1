<#
.DESCRIPTION
    Query all installed software products in ConfigMgr database
.PARAMETER QueryFilter
    Optional: SQL filter to limit returned rows
.PARAMETER ServerName
    ConfigMgr SQL Server host name (FQDN)
.PARAMETER
    ConfigMgr Site Code
.EXAMPLE
    .\Get-CMApplications.ps1 -ServerName "cm01.contoso.local" -SiteCode "P01"
.EXAMPLE
    .\Get-CMApplications.ps1 -ServerName "cm01.contoso.local" -SiteCode "P01" -QueryFilter "Publisher0 like 'Microsoft %'"
.NOTES
    1.0.0 - DS - Initial release
#>
[CmdletBinding()]
param (
    [parameter(Mandatory=$False, HelpMessage="Optional SQL Filter")]
        [string] $QueryFilter = "",
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr DB Server Name")]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName,
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr Site Code")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode"
)
$DatabaseName = "CM_$SiteCode"
$QueryTimeout = 120
$ConnectionTimeout = 30

$query = @"
SELECT DISTINCT 
ProductName0 AS [ProductName],
ProductVersion0 AS [Version], 
Publisher0 AS [Publisher],
ProductCode0 AS [ProductCode],
InstallSource0 AS [Source],
InstalledLocation0 AS [Location] 
FROM dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED 
"@
if (![string]::IsNullOrEmpty($QueryFilter)) {
    $Query += "WHERE ($QueryFilter)"
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
            ProductName    = $row.ProductName | Out-String
            ProductVersion = $row.Version | Out-String
            Publisher      = $row.Publisher | Out-String
            ProductCode    = $row.ProductCode | Out-String
            InstallSource  = $row.Source | Out-String
            InstallPath    = $row.Location | Out-String
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
