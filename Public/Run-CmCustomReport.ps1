#Requires -Version 3
<#
.DESCRIPTION
    Sneak in and read data from ConfigMgr SQL database
.PARAMETER QueryFile
    If Output = CSV then pipeline or individual names can be passed in
    to provide CLI automation flow
.PARAMETER ServerName
    SQL Server Hostname (FQDN)
.PARAMETER SiteCode
    ConfigMgr Site Code
.PARAMETER QPath
    Path to .sql files (default is .\queries)
.PARAMETER Output
    List: Grid, Csv, Pipeline
.PARAMETER OutputPath
    Path to where output files are saved (CSV option)
.EXAMPLE
    .\Run-CmCustomQuery.ps1
.EXAMPLE
    .\Run-CmCustomQuery.ps1 -ServerName "cm01.fabrikam.local" -SiteCode "PS1"
.EXAMPLE
    .\Run-CmCustomQuery.ps1 -Output Csv -OutputPath ".\reports\"
.EXAMPLE
    .\Run-CmCustomQuery.ps1 -Output Pipeline | ?{$_.Installs -gt 50}
.NOTES
    0.1.0 - DS - Initial release
    0.1.1 - DS - Documentation, Gridview title enhancement
    0.1.2 - DS - Display output path for CSV option at completion
    0.1.3 - DS - Command line input for query file
    0.1.4 - DS - Fixed bug in Grid view title to use $QueryName
#>

[CmdletBinding()]
param (
    [parameter(ValueFromPipeline=$True, Mandatory=$False, HelpMessage="Query Filename")]
        [string] $QueryFile = "",
    [parameter(Mandatory=$False, HelpMessage="ConfigMgr DB Server Name")]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName = "hcidalas37.hci.pvt",
    [parameter(Mandatory=$False, HelpMessage="ConfigMgr Site Code")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode = "HHQ",
    [parameter(Mandatory=$False, HelpMessage="Path to query files")]
        [ValidateNotNullOrEmpty()]
        [string] $QPath = ".\queries",
    [parameter(Mandatory=$False, HelpMessage="Output Type")]
        [ValidateSet('Grid','Csv','Pipeline')]
        [string] $Output = 'Grid',
    [parameter(Mandatory=$False, HelpMessage="Path for CSV output files")]
        [string] $OutputPath = $PWD
)

if (![string]::IsNullOrEmpty($QueryFile)) {
    Write-Verbose "validating query file"
    if (!(Test-Path $QueryFile)) {
        Write-Warning "$QueryFile not found!"
        break
    }
    else {
        $f = Get-Item -Path $QueryFile
        $QueryFile = $f.FullName
        $QueryName = $f.BaseName
    }
}
else {
    Write-Verbose "getting list of query files to display in gridview"
    $qfiles = Get-ChildItem -Path $QPath -Filter "*.sql" | Sort-Object Name
    if ($qfiles.count -lt 1) {
        Write-Warning "$QPath contains no .sql files"
        break
    }
    Write-Verbose "$($qfiles.count) query files were found"
    $QueryFile = $qfiles | Select -ExpandProperty Name | 
        Out-GridView -Title "Select Query to Run" -OutputMode Single
    if (![string]::IsNullOrEmpty($QueryFile)) {
        $f = Get-ChildItem -Path $(Join-Path -Path $QPath -ChildPath $QueryFile)
        $QueryFile = $f.FullName
        $QueryName = $f.BaseName
    }
    else {
        Write-Verbose "nothing selected. exiting now."
        break
    }
}

Write-Verbose "queryfile: $QueryFile"
Write-Verbose "queryname: $QueryName"

Write-Verbose "opening database connection"
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

Write-Verbose "reading: $QueryFile"
$qtext = Get-Content -Path $QueryFile
if (![string]::IsNullOrEmpty($qtext)) {
    if ($qtext -match '@COLLID@') {
        $qtext = $qtext.Replace('@COLLID@', $CollectionID)
        Write-Verbose "QUERY... $qtext"
    }
    else {
        Write-Verbose "QUERY... $qtext"
    }
    $cmd = New-Object System.Data.SqlClient.SqlCommand($qtext,$conn)
    $cmd.CommandTimeout = $QueryTimeout
    $ds = New-Object System.Data.DataSet
    $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    [void]$da.Fill($ds)
    $rowcount = $($ds.Tables).Rows.Count
    if ($rowcount -gt 0) {
        Write-Host "$rowcount rows returned" -ForegroundColor Green
        switch ($Output) {
            'Grid' {
                $($ds.Tables).Rows | Out-GridView -Title "Query Results: $QueryName"
                break
            }
            'Csv' {
                $csvfile = Join-Path -Path $OutputPath -ChildPath "$QueryName.csv"
                Write-Verbose "csv file... $csvfile"
                $($ds.Tables).Rows | Export-Csv -NoTypeInformation -Path $csvfile
                Write-Host "exported to: $csvfile" -ForegroundColor Green
                break
            }
            default {
                $($ds.Tables).Rows
            }
        } # switch
    }
    else {
        Write-Host "No rows were returned" -ForegroundColor Magenta
    }
}

$conn.Close()
Write-Verbose "database connection closed"
