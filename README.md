# CmCustomReports
Configuration Manager Custom Ad Hoc Reporting

## Example

Process all queries in sub-folder "queries" and output Excel results to sub-folder "reports":

``` powershell
Import-Module CmCustomReports
Run-CmCustomQuery -ServerName "cm01.contoso.local" -SiteCode "P01" -InputType Folder -QueryFilePath ".\queries\" -OutputType Excel -OutputPath ".\reports\" -Verbose
```
