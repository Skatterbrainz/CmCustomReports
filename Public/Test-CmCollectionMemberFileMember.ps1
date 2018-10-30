[CmdletBinding()]
param (
    [parameter(Mandatory=$False, HelpMessage="ConfigMgr Collection ID")]
        [string] $CollectionID = "",
    [parameter(Mandatory=$True, HelpMessage="Input File")]
        [ValidateScript({
            if (-Not($_ | Test-Path)) {
                throw "File does not exist"
            }
            if (-Not($_ | Test-Path -PathType Leaf)) {
                throw "Must be a file, not a folder"
            }
            if ($_ -notmatch "(\.txt)") {
                throw "Must be a TXT file"
            }
            return $True
        })]
        [System.IO.FileInfo] $InputFile,
    [parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string] $ServerName = "cm01.contoso.local",
    [parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode = "P01",
    [switch] $DeepInspect,
    [switch] $ShowReverse
)
$Time1 = Get-Date

if ($CollectionID -eq "") {
    $members = .\Get-CmCollectionMember.ps1 -Choose -ServerName $ServerName -SiteCode $SiteCode
}
else {
    $members = .\Get-CmCollectionMember.ps1 -CollectionID $CollectionID -ServerName $ServerName -SiteCode $SiteCode
}
$memberNames = $members | Select -ExpandProperty ComputerName
$computerlist = Get-Content -Path $InputFile
$ccount = 0
$tcount = $computerlist.Count

foreach ($cn in $computerlist) {
    if ($DeepInspect) {
        try {
            Write-Verbose "connecting to: $cn (deep)"
            $x = Test-NetConnection -ComputerName $cn -WarningAction SilentlyContinue
            if ($x.PingSucceeded) {
                $stat = "ONLINE"
            }
            elseif ($x.RemoteAddress) {
                $stat = "OFFLINE"
            }
            else {
                $stat = "NO DNS"
            }
        }
        catch {
            $stat = "ERROR"
        }
    }
    else {
        Write-Verbose "connecting to: $cn"
        if (Test-NetConnection -ComputerName $cn -InformationLevel Quiet) {
            $stat = "ONLINE"
        }
        else {
            $stat = "OFFLINE"
        }
    }
    if ($memberNames -notcontains $cn) {
        $ismember = $False
        Write-Verbose "$cn is not in collection"
    }
    else {
        $ismember = $True
        Write-Verbose "$cn is ONLINE"
    }
    $data = [ordered]@{
        Computer = $cn
        IsOnline = $stat
        IsMember = $ismember
    }
    New-Object -TypeName PSObject -Property $data
} # foreach

if ($ShowReverse) {
    foreach ($m in $members) {
        if ($computerlist -notcontains $m) {
            Write-Host "$m is not in file"
        }
    }
}
