#requires -Version 3.0
<#
.DESCRIPTION
    Get ConfigMgr Collection Members
.PARAMETER CollectionID
.PARAMETER ServerName
.PARAMETER SiteCode
.PARAMETER Ping
.PARAMETER Grid
#>

[CmdletBinding()]
param (
    [parameter(Mandatory=$True, ValueFromPipeline=$True, HelpMessage="Collection ID")]
        [ValidateNotNullOrEmpty()]
        [string] $CollectionID,
    [parameter(Mandatory=$True, HelpMessage="Site Database Server Name")]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName,
    [parameter(Mandatory=$True, HelpMessage="ConfigMgr Site Code")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode,
    [parameter(Mandatory=$False, HelpMessage="Query if computer is online")]
        [switch] $Ping,
    [parameter(Mandatory=$False, HelpMessage="Display results in gridview")]
        [switch] $Grid
)
$qtext = @"
SELECT DISTINCT 
  dbo.v_ClientCollectionMembers.Name AS ComputerName, 
  dbo.v_ClientCollectionMembers.ResourceID, 
  dbo.v_ClientCollectionMembers.CollectionID, 
  dbo.v_ClientCollectionMembers.IsClient, 
  dbo.v_ClientCollectionMembers.Domain, 
  dbo.v_ClientCollectionMembers.SiteCode, 
  dbo.v_Collection.Name AS CollectionName
FROM dbo.v_ClientCollectionMembers INNER JOIN
  dbo.v_Collection ON 
  dbo.v_ClientCollectionMembers.CollectionID = dbo.v_Collection.CollectionID
WHERE dbo.v_ClientCollectionMembers.CollectionID = '$CollectionID' 
ORDER BY ComputerName
"@

$QueryTimeout = 120
$ConnectionTimeout = 30
#Action of connecting to the Database and executing the query and returning results if there were any.
$conn = New-Object System.Data.SqlClient.SQLConnection
$ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerName,$DatabaseName,$ConnectionTimeout
$conn.ConnectionString = $ConnectionString
try {
    $conn.Open()
    Write-Verbose "connection opened successfully"
}
catch {
    Write-Error $_.Exception.Message
    break
}
$cmd = New-Object System.Data.SqlClient.SqlCommand($qtext,$conn)
$cmd.CommandTimeout = $QueryTimeout
$ds = New-Object System.Data.DataSet
$da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
[void]$da.Fill($ds)
$conn.Close()
$rowcount = $($ds.Tables).Rows.Count
if ($rowcount -gt 0) {
    Write-Host "$rowcount rows returned" -ForegroundColor Green
    if ($Grid) {
        $($ds.Tables).Rows | Out-GridView -Title "Collection Members: $CollectionID"
    }
    else {
        $($ds.Tables).Rows |
            Foreach-Object {
                if ($Ping) {
                    if (Test-NetConnection -ComputerName $_.ComputerName -InformationLevel Quiet) {
                        $Online = $True
                    }
                    else {
                        $Online = $False
                    }
                    $data = [ordered]@{
                        ComputerName = $_.ComputerName
                        ResourceID   = $_.ResourceID
                        IsClient	 = $_.IsClient
                        Domain       = $_.Domain
                        SiteCode     = $_.SiteCode
                        IsOnline     = $Online
                    }
                }
                else {
                    $data = [ordered]@{
                        ComputerName = $_.ComputerName
                        ResourceID   = $_.ResourceID
                        IsClient	 = $_.IsClient
                        Domain       = $_.Domain
                        SiteCode     = $_.SiteCode
                    }
                }
                New-Object PSObject -Property $data
            } # foreach-object
    } # if-else
}
