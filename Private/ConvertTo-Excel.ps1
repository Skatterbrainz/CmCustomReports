function ConvertTo-Excel {
    param (
        [parameter(Mandatory=$True, HelpMessage="CSV file path")]
            [ValidateNotNullOrEmpty()]
            [string] $CsvFile,
        [parameter(Mandatory=$True, HelpMessage="XLSX file path")]
            [ValidateNotNullOrEmpty()]
            [string] $XlFile,
        [parameter(Mandatory=$False, HelpMessage="CSV column delimiter character")]
            [string] $delimiter = ','
    )
    if (!(Test-Path $CsvFile)) {
        Write-Error "$CsvFile not found!"
        break
    }
    Write-Verbose "opening an instance of microsoft excel"
    $excel = New-Object -ComObject Excel.Application 
    $workbook  = $excel.Workbooks.Add(1)
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
