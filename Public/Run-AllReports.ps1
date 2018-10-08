param (
  [string] $QPath = ".\queries",
  [string] $OutputPath = ".\reports"
)
Get-ChildItem -Path $QPath -Filter "*.sql" | 
    Select-Object -ExpandProperty Fullname |
        ForEach-Object { .\Run-CmCustomReport.ps1 -QueryFile $_ -Output Csv -OutputPath $OutputPath -Verbose }
