<#
.SYNOPSIS
    Reimport custom XML file to OCS 
.DESCRIPTION
    1. Prompt user for device name
	2. Find XML file according to input
	3. Upload XML file
.NOTES
    Author: fs
    Last edit: 11_12_2024 fs
    Version:
        1.0 - basic functionality
#>

Clear-Host

function Prompt {
    param( [string] $text )
    do { $response = Read-Host $text } while ([string]::IsNullOrWhiteSpace($response)) 
    return $response
}

$root = "X:\informatika\1-1 POSTAVKE i DOKUMENTACIJA\2-UPUTSTVA\OCS\XML_import_na_OCS_2.8"
$archive = "$($root)\XML_reimport"

$num = 1

$host.ui.RawUI.WindowTitle = "XML reimport" 
$devices = New-Object System.Collections.Generic.List[string]

do {
    Write-Host "`n$('-' * 10)* $($num). uredaj *$('-' * 10)"
	$response = Prompt "Hostname"
    $file = Get-ChildItem -Path $archive -Recurse | Where-Object { $_.name -match $response}
    if ($null -eq $file) {
        Write-Host "XML uredaja $($response) ne postoji."
    } else {
        Write-Host "XML pronaden: $($file.FullName)"
        $num++
	    $devices.Add($file)
    }
    Write-Host "$('-' * 33)"
	$continue = Read-Host "`nDodati jos uredaja? (ENTER/n)"
} while ($continue -ne "n")

if ($devices.count -gt 0) {
    $devices | ForEach-Object {
        Write-Host ""
        Invoke-Expression "powershell.exe -noprofile -executionpolicy bypass -file `"$($root)\ocsinventory-powershell-injector.ps1`" -info -v -f `"$($archive)\$($_)`" -url http://192.168.20.19/ocsinventory"
        Write-Host ""
    }
    Start-Sleep -s 1
    exit
} else { exit }