#requires -Version 3
<#
.DESCRIPTION

.PARAMETER ServerName

.PARAMETER SiteCode

.PARAMETER InputType

.PARAMETER QueryFile

.PARAMETER QueryFilePath

.PARAMETER OutputType

.PARAMETER OutputPath

.NOTES

.EXAMPLE

.EXAMPLE

#>

[CmdletBinding()]
param (
    [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName,
    [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode,
    [parameter(Mandatory=$False)]
        [ValidateSet('Select','File','Folder')]
        [string] $InputType = 'Select',
    [parameter(Mandatory=$False)]
        [string] $QueryFile = "",
    [parameter(Mandatory=$False)]
        [string] $QueryFilePath = "",
    [parameter(Mandatory=$False)]
        [ValidateSet('Pipeline','Csv','Excel','Grid')]
        [string] $OutputType = 'Pipeline',
    [parameter(Mandatory=$False)]
        [string] $OutputPath = $PWD
)

Write-Verbose "servername...... $ServerName"
Write-Verbose "sitecode........ $SiteCode"

if ([string]::IsNullOrEmpty($QueryFilePath)) {
    $QueryFilePath = $PWD
}
$OutputPath = $(Get-Item -Path $OutputPath).FullName
Write-Verbose "inputType....... $InputType"
Write-Verbose "outputType...... $OutputType"
Write-Verbose "outputPath...... $OutputPath"
Write-Verbose "queryFile....... $QueryFile"
Write-Verbose "queryFilePath... $QueryFilePath"

function ConvertTo-Excel {
    param (
        [parameter(Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [string] $CsvFile,
        [parameter(Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            [string] $XlFile,
        [parameter(Mandatory=$False)]
            [string] $delimiter = ','
    )
    if (!(Test-Path $CsvFile)) {
        Write-Error "$CsvFile not found!"
        break
    }
    Write-Verbose "opening an instance of microsoft excel"
    $excel = New-Object -ComObject Excel.Application 
    Write-Verbose "adding workbook"
    $workbook  = $excel.Workbooks.Add(1)
    Write-Verbose "selectincg worksheet 1"
    $worksheet = $workbook.worksheets.Item(1)
    $TxtConnector = ("TEXT;" + $CsvFile)
    Write-Verbose "connector: $TxtConnector"
    $Connector = $worksheet.QueryTables.Add($TxtConnector,$worksheet.Range("A1"))
    $query = $worksheet.QueryTables.Item($Connector.name)
    $query.TextFileOtherDelimiter = $delimiter
    $query.TextFileParseType  = 1
    $query.TextFileColumnDataTypes = ,1 * $worksheet.Cells.Columns.Count
    $query.AdjustColumnWidth = 1
    $query.Refresh()
    $query.Delete()
    Write-Verbose "saving content to $XlFile"
    try {
        $Workbook.SaveAs($XlFile,51) | Out-Null
        Write-Verbose "saved output successfully"
        $result = 0
    }
    catch {
        Write-Verbose "error: $($_.Exception.Message)"
        $result = -1
    }
    finally {
        $excel.Quit()
    }
    Write-Output $result
}

switch ($InputType) {
    'File' {
        if (!(Test-Path $QueryFile)) {
            Write-Warning "$QueryFile not found!"
            $stop = $true
        }
        else {
            Write-Verbose "$QueryFile verified"
        }
        break
    }
    'Folder' {
        if (!(Test-Path $QueryFilePath)) {
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
            $qfiles = $qfiles | Select -ExpandProperty Name | Out-GridView -Title "Select Queries to Run" -OutputMode Multiple
        }
        else {
            $qfiles = $qfiles | Select -ExpandProperty Name | Out-GridView -Title "Select Query to Run" -OutputMode Single
        }
        if (!($qfiles.Count -gt 0)) {
            Write-Warning "No queries were selected"
            $stop = $True
        }
        else {
            Write-Verbose "$($qfiles.Count) queries were selected"
        }
        break
    }
} # switch

if ($stop) { break }

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
                    Write-Host "exported to: $csvfile" -ForegroundColor Green
                    break
                }
                'Excel' {
                    Write-Verbose "excel file...... $ExcelFile"
                    $($ds.Tables).Rows | Export-Csv -NoTypeInformation -Path $OutputFile
                    $exitcode = ConvertTo-Excel -CsvFile $OutputFile -XlFile $ExcelFile
                    Write-Verbose "exit code....... $exitcode"
                    Write-Host "exported to: $ExcelFile" -ForegroundColor Green
                    break
                }
                default {
                    Write-Verbose "grid view....... "
                    $($ds.Tables).Rows | Out-GridView -Title "Query Results: $QueryName"
                    break
                }
            } # switch
        }
        else {

        }
    } # if
    else {
        Write-Warning "$QueryFile is empty"
    }
} # foreach

Write-Verbose "closing database connection"
$conn.Close()

Write-Verbose "done!"
