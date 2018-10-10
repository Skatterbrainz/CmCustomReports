#requires -Version 3
<#
.DESCRIPTION
    Export custom query results from ConfigMgr database
.PARAMETER ServerName
    SQL Server hostname which supports the CM database
.PARAMETER SiteCode
    ConfigMgr Site Code
.PARAMETER InputType
    List: File, Folder, Select
.PARAMETER QueryFile
    SQL query statement file(s) having a .sql extension
.PARAMETER QueryFilePath
    Path to folder which contains .sql query files
    Default is the .\Queries folder within the module directory
.PARAMETER OutputType
    List: Pipeline, Csv, Excel, Grid
    Pipeline returns results to the powershell pipeline for serial processing
    Csv saves results to .CSV file(s)
    Excel saves results to .CSV files(s) and converts them to Excel .xlsx files
    Grid displays results using powershell gridview
.PARAMETER OutputPath
    Folder where .csv or .xlsx files will be saved
.NOTES
    1.0.0 - DS - Initial release
.EXAMPLE
    Run-CmCustomReport -ServerName 'cm01.contoso.local' -SiteCode 'P01'
.EXAMPLE
    Run-CmCustomReport -ServerName 'cm01.contoso.local' -SiteCode 'P01' -InputType Folder -OutputType Csv -OutputPath "c:\reports"
.EXAMPLE
    Run-CmCustomReport -ServerName 'cm01.contoso.local' -SiteCode 'P01' -QueryFile $qfiles -OutputType Excel -OutputPath "c:\reports"
#>

[CmdletBinding()]
function Run-CmCustomReport {
    param (
        [parameter(Mandatory=$True, HelpMessage="SQL Server Hostname")]
            [ValidateNotNullOrEmpty()]
            [string] $ServerName,
        [parameter(Mandatory=$True, HelpMessage="ConfigMgr Site Code")]
            [ValidateNotNullOrEmpty()]
            [string] $SiteCode,
        [parameter(Mandatory=$False, HelpMessage="Query input type")]
            [ValidateSet('Select','File','Folder')]
            [string] $InputType = 'Select',
        [parameter(Mandatory=$False, HelpMessage="Query File names")]
            [string[]] $QueryFile = "",
        [parameter(Mandatory=$False, HelpMessage="Path to Query files")]
            [string] $QueryFilePath = "",
        [parameter(Mandatory=$False, HelpMessage="Output type")]
            [ValidateSet('Pipeline','Csv','Excel','Grid')]
            [string] $OutputType = 'Pipeline',
        [parameter(Mandatory=$False, HelpMessage="Output folder for result files")]
            [string] $OutputPath = $PWD
    )
    $ModuleData = Get-Module CmCustomReport
    $ModuleVer  = $ModuleData.Version -join '.'
    $ModulePath = $ModuleData.Path -replace 'CmCustomReport.psm1', ''
   
    Write-Verbose "module version.. $ModuleVer"
    Write-Verbose "servername...... $ServerName"
    Write-Verbose "sitecode........ $SiteCode"
    
    if ([string]::IsNullOrEmpty($QueryFilePath)) {
        $QueryFilePath = Join-Path -Path $ModulePath -ChildPath "Queries"
    }
    $OutputPath = $(Get-Item -Path $OutputPath).FullName
    Write-Verbose "inputType....... $InputType"
    Write-Verbose "outputType...... $OutputType"
    Write-Verbose "outputPath...... $OutputPath"
    Write-Verbose "queryFile....... $QueryFile"
    Write-Verbose "queryFilePath... $QueryFilePath"
    
    switch ($InputType) {
        'File' {
            foreach ($qf in QueryFile) {
                if (!(Test-Path $qf)) {
                    Write-Warning "$qf not found!"
                    $stop = $True
                    break
                }
            }
            if (!$stop) {
                Write-Verbose "$($QueryFile.count) files were validated"
                $qfiles = $QueryFile
            }
            break
        }
        'Folder' {
            if (!(Test-Path $QueryFilePath)) {
                Write-Warning "$QuerFilePath not found!"
                $stop = $True
                break
            }
            else {
                $qfiles = Get-ChildItem -Path $QueryFilePath -Filter "*.sql" | Sort-Object Name
                Write-Verbose "$($qfiles.count) query files were found"
            }
            break
        }
        default {
            $qfiles = Get-ChildItem -Path $QueryFilePath -Filter "*.sql" | Sort-Object Name
            if ($qfiles.count -lt 1) {
                Write-Warning "$QueryFilePath contains no .sql files"
                break
            }
            Write-Verbose "$($qfiles.count) query files were found"
            if (('Csv','Excel') -contains $OutputType) {
                Write-Verbose "file output = allow multiple input query files"
                $qfiles = $qfiles | Select -ExpandProperty Name | Out-GridView -Title "Select Queries to Run" -OutputMode Multiple
            }
            else {
                Write-Verbose "pipeline output = allow single input query file"
                $qfiles = $qfiles | Select -ExpandProperty Name | Out-GridView -Title "Select Query to Run" -OutputMode Single
            }
            if (!($qfiles.Count -gt 0)) {
                Write-Warning "No queries were selected (exit)"
                $stop = $True
            }
            else {
                Write-Verbose "$($qfiles.Count) query files were selected"
            }
            break
        }
    } # switch
    
    if ($stop) { break }
    
    Write-Verbose "opening database connection"
    $QueryTimeout = 120
    $ConnectionTimeout = 30
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
    
    foreach ($qfile in $qfiles) {
        $f = Get-Item -Path (Join-Path -Path $QueryFilePath -ChildPath $qfile)
        $QueryFile  = $f.FullName
        $QueryName  = $f.BaseName -replace '.sql',''
        $OutputFile = Join-Path -Path $OutputPath -ChildPath "$QueryName.csv"
        $ExcelFile  = $OutputFile -replace '.csv','.xlsx'
        Write-Verbose "query file...... $QueryFile"
        Write-Verbose "query name...... $QueryName"
        Write-Verbose "output file..... $OutputFile"
        Write-Verbose "excel file...... $ExcelFile"
        $qtext = Get-Content -Path $QueryFile
        if (![string]::IsNullOrEmpty($qtext)) {
            Write-Verbose "QUERY... $qtext"
            $cmd = New-Object System.Data.SqlClient.SqlCommand($qtext,$conn)
            $cmd.CommandTimeout = $QueryTimeout
            $ds = New-Object System.Data.DataSet
            $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
            [void]$da.Fill($ds)
            $rowcount = $($ds.Tables).Rows.Count
            if ($rowcount -gt 0) {
                Write-Host "$rowcount rows returned" -ForegroundColor Green
                switch ($OutputType) {
                    'Pipeline' {
                        $($ds.Tables).Rows
                        break
                    }
                    'Csv' {
                        Write-Verbose "report file..... $OutputFile"
                        $($ds.Tables).Rows | Export-Csv -NoTypeInformation -Path $OutputFile
                        Write-Host "Exported to: $csvfile" -ForegroundColor Green
                        break
                    }
                    'Excel' {
                        Write-Verbose "excel file...... $ExcelFile"
                        $($ds.Tables).Rows | Export-Csv -NoTypeInformation -Path $OutputFile
                        $exitcode = ConvertTo-Excel -CsvFile $OutputFile -XlFile $ExcelFile
                        Write-Verbose "exit code....... $exitcode"
                        Write-Host "Exported to: $ExcelFile" -ForegroundColor Green
                        break
                    }
                    default {
                        $($ds.Tables).Rows | Out-GridView -Title "Query Results: $QueryName"
                        break
                    }
                } # switchs
            }
            else {
                Write-Host "no results were returned from query" -ForegroundColor Cyan
            }
        } # if
        else {
            Write-Warning "$QueryFile is empty. Review file to confirm."
        }
    } # foreach
    
    Write-Verbose "closing database connection"
    $conn.Close()
    Write-Verbose "done!"
} # function

Export-ModuleMember -Function Run-CmCustomReport