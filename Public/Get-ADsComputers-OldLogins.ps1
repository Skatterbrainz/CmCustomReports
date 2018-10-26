param (
    [parameter(Mandatory=$False)]
    [ValidateRange(1,3000)]
    [int] $DaysOld = 60,
    [switch] $Detailed
)
function Get-Pct {
    param ([int]$HowMany, [int]$TotalNumber)
    if ($HowMany -gt 0 -and $TotalNumber -gt 0) {
        Write-Output "$([math]::Round($($HowMany / $TotalNumber)*100,0))`%"
    }
}

Write-Host "getting computer accounts from active directory..." -ForegroundColor Cyan
$all = .\Get-AdsComputers.ps1
$xcount = $all.Count

$tcount = 0
$c60  = 0
$c90  = 0
$c180 = 0
$c365 = 0
$c720 = 0

foreach ($computer in $all) {
    $ll  = $($computer.LastLogon).DateTime
    $now = $(Get-Date).DateTime
    $dif = $(New-TimeSpan -Start $ll -End $now).Days
    if ($Detailed) {
        if ($dif -gt $DaysOld) {
            $data = [ordered]@{
                ComputerName = $computer.Name
                LastLogon    = $ll
            }
            $tcount++
            New-Object PSObject -Property $data
        }
    }
    else {
        if ($dif -gt 720) { $c720++ }
        elseif ($dif -gt 365) { $c365++ }
        elseif ($dif -gt 180) { $c180++ }
        elseif ($dif -gt 90) { $c90++ }
        elseif ($dif -gt 60) { $c60++ }
    }
}
if ($Detailed) {
    if ($tcount -gt 0) {
        $pct = [math]::Round($($tcount / $xcount)*100,0)
        Write-Host "$tcount of $($xcount) computers logged on more than $DaysOld days ago $(Get-Pct -HowMany $tcount -TotalNumber $xcount)" -ForegroundColor Cyan
    }
    else {
        Write-Host "$ccount of $($xcount) computers logged on more than $DaysOld days ago" -ForegroundColor Green
    }
}
else {
    $p60  = Get-Pct -HowMany  $c60 -TotalNumber $xcount
    $p90  = Get-Pct -HowMany  $c90 -TotalNumber $xcount
    $p180 = Get-Pct -HowMany $c180 -TotalNumber $xcount
    $p365 = Get-Pct -HowMany $c365 -TotalNumber $xcount
    $p720 = Get-Pct -HowMany $c720 -TotalNumber $xcount
    Write-Host "$c60 of $xcount more than 60 days ($p60)" -ForegroundColor Cyan
    Write-Host "$c90 of $xcount more than 90 days ($p90)" -ForegroundColor Cyan
    Write-Host "$c180 of $xcount more than 180 days ($p180)" -ForegroundColor Cyan
    Write-Host "$c365 of $xcount more than 365 days ($p365)" -ForegroundColor Cyan
    Write-Host "$c720 of $xcount more than 720 days ($p720)" -ForegroundColor Cyan
}
