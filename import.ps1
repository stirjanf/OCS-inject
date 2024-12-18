<#
.SYNOPSIS
    Imports custom XML file to OCS 
.DESCRIPTION
    1. Prompt user to input full or partial devices information until cancellation
	2. Generate XML files according to input
	3. Upload XML files
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
$archive = "$($root)\XML_arhiva"
$xml_template = "$($root)\XML_OCS_template.xml"

do { $variant = Prompt "1 = Fast import - hostname, mac, sn`n2 = Full import - sve informacije" } while ($variant -ne 1 -and $variant -ne 2)

if ($variant -eq 1) { $host.ui.RawUI.WindowTitle = "Fast import" } else { $host.ui.RawUI.WindowTitle = "Full import" }

Write-Host "`nPopuniti sljedeca polja (za prazno poslati ENTER):`n"
$num = 1
$devices = New-Object System.Collections.Generic.List[PSCustomObject]

do {
    Write-Host "`n$('-' * 10)* $($num). uredaj *$('-' * 10)"
	$name = Prompt "> HOSTNAME"
	$sn = Read-Host "> SERIJSKI"
	if ([string]::IsNullOrWhiteSpace($sn)) { $sn = $name }
	$mac = Read-Host "> MAC"
	if ([string]::IsNullOrWhiteSpace($mac)) { $mac = $name }
	if ($variant -eq 2) {
		$tag 		= Read-Host "> TAG"
		$location 	= Read-Host "> LOKACIJA"
		$invbr 		= Read-Host "> INVBR"
		$rbr 		= Read-Host "> BROJ RACUNA"
		$user 		= Read-Host "> KORISNIK"
		$network 	= Read-Host "> LANONLY"    
		$domain 	= Read-Host "> DOMENA"  
		$other 		= Read-Host "> RAZNO"
		$counter 	= Read-Host "> BROJAC"
		$security 	= Read-Host "> SECURITY"
		$poticaj 	= Read-Host "> POTICAJ"  
	}
	Write-Host "$('-' * 33)"
	$continue = Read-Host "`nDodati jos uredaja? (ENTER/n)"
    $num++
	$devices.Add(@{ 
		name     = $name
		sn       = $sn
		mac      = $mac
		tag      = $tag
		location = $location
		invbr    = $invbr
		rbr      = $rbr
		user     = $user
		network  = $network
		domain   = $domain
		other    = $other
		counter  = $counter
		security = $security
		poticaj  = $poticaj 
	})
} while ($continue -ne "n")

if ($devices.count -gt 0) {
	$devices | ForEach-Object {
		[xml] $xml = Get-Content -Path $xml_template
		$xml.REQUEST.DEVICEID = "$($_.name)-$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss')"
		$xml.REQUEST.CONTENT.BIOS.SSN = "$($_.sn)_M"
		$xml.REQUEST.CONTENT.NETWORKS.MACADDR = "$($_.mac)_M"
		$xml.REQUEST.CONTENT.HARDWARE.NAME = "$($_.name)"
		$xml.REQUEST.CONTENT.ACCOUNTINFO[0].KEYVALUE = "$($_.tag)"
		$xml.REQUEST.CONTENT.ACCOUNTINFO[1].KEYVALUE = "$($_.location)"
		$xml.REQUEST.CONTENT.ACCOUNTINFO[2].KEYVALUE = "$($_.invbr)"
		$xml.REQUEST.CONTENT.ACCOUNTINFO[3].KEYVALUE = "$($_.rbr)"
		$xml.REQUEST.CONTENT.ACCOUNTINFO[4].KEYVALUE = "$($_.user)"
		$xml.REQUEST.CONTENT.ACCOUNTINFO[5].KEYVALUE = "$($_.domain)"
		$xml.REQUEST.CONTENT.ACCOUNTINFO[6].KEYVALUE = "$($_.network)"
		$xml.REQUEST.CONTENT.ACCOUNTINFO[9].KEYVALUE = "$($_.other)"
		$xml.REQUEST.CONTENT.ACCOUNTINFO[10].KEYVALUE = "$($_.counter)"
		$xml.REQUEST.CONTENT.ACCOUNTINFO[11].KEYVALUE = "$($_.security)"
		$xml.REQUEST.CONTENT.ACCOUNTINFO[12].KEYVALUE = "$($_.poticaj)"
		$xml.Save("$($archive)\XML_OCS_$($_.name).xml")
		Write-Host ""
		Invoke-Expression "powershell.exe -noprofile -executionpolicy bypass -file `"$($root)\ocsinventory-powershell-injector.ps1`" -info -v -f `"$($archive)\XML_OCS_$($_.name).xml`" -url $url"
		Write-Host ""
	}
	Start-Sleep -s 1
	exit
} else { exit }
