<#
.SYNOPSIS
  Instead of manually googling or searching on the NIST website for vulnerability information and fixes this script will gather
  the key information needed from the NIST Rest API. When run it will ask for the CVE number you want to search for and will write
  to the screen the details and clickable url for Vendor links.
.DESCRIPTION
  Using the CVE number and the NIST API this script will query for resolution links. 
.PARAMETER <Parameter_Name>
  There are no required Parameters in this version.
.INPUTS
  CVE number
.OUTPUTS
  CVE Number
  Description
  Versions the vulnerability applies to
  Vendor or 3rd party name
  url of vendor links and references to data and fixes
.NOTES
  Version:        1.0
  Author:         Scott Lichty
  Creation Date:  09/08/2021
  Purpose/Change: Initial script development
.EXAMPLE
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param ()

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#----------------------------------------------------------[Declarations]----------------------------------------------------------

$cve = Read-Host "Enter cve number"
$url = "https://services.nvd.nist.gov/rest/json/cve/1.0/$cve"

#-----------------------------------------------------------[Functions]------------------------------------------------------------


Function Get-cve {
  Param ()
  Begin {
    Write-Host ''
    Write-Host 'Gahering information from NIST API...' -ForegroundColor Yellow
  }
  Process {
    Try {
      $results = Invoke-RestMethod -Uri $url
      $base = $results.result.CVE_Items
      $resultsId = $base.cve.cve_data_meta.id
      $resultsDesc = $base.cve.description.description_data.value
      $resultsRef = $base.cve.references.reference_data
      $resultsId 
      Write-Host " "
      $resultsDesc
      Write-Host " "
      $tests = $base.configurations.nodes.cpe_match
      $tests | ForEach-Object {
        Write-Host "cpe23uri: "  $_.cpe23uri
        Write-Host "Version From : " $_.versionStartIncluding
        Write-Host "Version To: " $_.versionEndIncluding
      }

      $resultsRef = $base.cve.references.reference_data
      $resultsRef | ForEach-Object {
        Write-Host "Tags: " $_.tags
        Write-Host "url: "$_.url
            Do {
                Write-Host "Open Google?" -ForegroundColor Yellow
                $result = Read-Host "   ( y / n / q ) " 
            } Until ($result -eq "y" -or $result -eq "n" -or $result -eq "q")
            if ($result -eq "y") {
                Start-Process "chrome.exe" $_.url
            }
            elseif ($result -eq "q") {
                break
            }
        Write-Host " "
      }

      pause
    }
    Catch {
      Write-Host -BackgroundColor Red "Error: $($_.Exception)"
      Break
    }
  }
  End {
    If ($?) {
      Write-Host 'Completed Successfully.'
      Write-Host ' '
    }
  }
}


#-----------------------------------------------------------[Execution]------------------------------------------------------------
Get-cve