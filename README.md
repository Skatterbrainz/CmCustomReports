# CmCustomReports
Configuration Manager Custom Ad Hoc Reporting

## Example

Process all queries in sub-folder "queries" and output Excel results to sub-folder "reports":

``` .\Run-CmCustomQuery.ps1 -ServerName "cm01.contoso.local" -SiteCode "P01" -InputType Folder -QueryFilePath ".\queries\" -OutputType Excel -OutputPath ".\reports\" -Verbose
```
