param (
  [string] $SQLServerName = "cm01.contoso.local",
  [string] $SiteCode = "P01",
  [string] $QPath = ".\queries",
  [string] $OutputPath = ".\reports"
)
Get-ChildItem -Path $QPath -Filter "*.sql" | 
    Select-Object -ExpandProperty Fullname |
        ForEach-Object { .\Run-CmCustomReport.ps1 -ServerName $SQLServerName -SiteCode $SiteCode -QueryFile $_ -Output Csv -OutputPath $OutputPath -Verbose }
