[CmdletBinding()]
param (
  [parameter(Mandatory=$True)]
  $csvfiles
)
# $csvfiles = Get-ChildItem -path "i:\scripts\reports" -Filter "*.csv"

foreach ($csvfile in $csvfiles) {
    $csv  = $csvfile.FullName
    $xlsx = $csv -replace ".csv",".xlsx"
    Write-Verbose "reading: $csv"

    $delimiter = "," #Specify the delimiter used in the file

    # Create a new Excel workbook with one empty sheet
    $excel = New-Object -ComObject excel.application 
    $workbook = $excel.Workbooks.Add(1)
    $worksheet = $workbook.Worksheets.Item(1)

    # Build the QueryTables.Add command and reformat the data
    $TxtConnector = ("TEXT;" + $csv)
    $Connector = $worksheet.QueryTables.add($TxtConnector,$worksheet.Range("A1"))
    $query = $worksheet.QueryTables.item($Connector.name)
    $query.TextFileOtherDelimiter = $delimiter
    $query.TextFileParseType  = 1
    $query.TextFileColumnDataTypes = ,1 * $worksheet.Cells.Columns.Count
    $query.AdjustColumnWidth = 1

    # Execute & delete the import query
    $query.Refresh()
    $query.Delete()

    try {
      $Workbook.SaveAs($xlsx,51) | Out-Null
      Write-Verbose "saving: $xlsx"
    }
    catch {
      Write-Error $_.Exception.Message
    }
    $excel.Quit()
}
