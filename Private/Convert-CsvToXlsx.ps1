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
