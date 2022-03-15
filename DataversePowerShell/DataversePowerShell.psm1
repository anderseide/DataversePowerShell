<#

A bunch of scripts used for Managing Opptys, Orders, Quotes and Invoices in Dynamics 365 Sales

#>

#region Module Variables and setup

Write-Debug -Message "PowerShell Module MSAL.PS is required. Trying to import"
#Requires -Modules MSAL.PS
Import-Module -Name "MSAL.PS"

Write-Verbose "Creating module variables"
$DataverseSession = [ordered]@{
    ServiceUrl = $null
    ClientId = $null
    ClientSecret = $null
    Scopes = @()
    AuthSession = $null
}
New-Variable -Name DataverseSession -Value $DataverseSession -Scope Script -Force


#endregion

#region import public and private functions

$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

try {
    foreach ($Scope in 'Public','Private') {
        Get-ChildItem (Join-Path -Path $ScriptPath -ChildPath $Scope) -Filter *.ps1 -Recurse | ForEach-Object {
            . $_.FullName
            if ($Scope -eq 'Public') {
                Export-ModuleMember -Function $_.BaseName -ErrorAction Stop
            }
        }
    }
}
catch {
    Write-Error ("{0}: {1}" -f $_.BaseName,$_.Exception.Message)
    exit 1
}
#endregion