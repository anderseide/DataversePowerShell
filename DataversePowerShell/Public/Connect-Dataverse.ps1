<#
.SYNOPSIS
  Connect to Microsoft Dataverse instance. 

.DESCRIPTION
  Connects the current PowerShell session to a Microsoft Dataverse instance

#>

function Connect-Dataverse {
  param(
    # Client Secret used to connect
    [Parameter(Mandatory = $true, ParameterSetName = "ClientSecret")]
    [Parameter(Mandatory = $false, ParameterSetName = "InteractiveLogon")]
    [string]
    $ClientId,

    # Client Secret used to connect
    [Parameter(Mandatory = $true, ParameterSetName = "ClientSecret")]
    [Parameter(Mandatory = $false, ParameterSetName = "InteractiveLogon")]
    [securestring]
    $ClientSecret,

    # Redirect URI used to connect
    [Parameter(Mandatory = $false, ParameterSetName = "ClientSecret")]
    [Parameter(Mandatory = $false, ParameterSetName = "InteractiveLogon")]
    [string]
    $RedirectUri,

    # Azure AD Tenant Id
    
    [Parameter(Mandatory = $true, ParameterSetName = "ClientSecret")]
    [Parameter(Mandatory = $true, ParameterSetName = "InteractiveLogon")]
    [Parameter(Mandatory)]
    [string]
    $TenantId,

    # Environment URL for the Dataverse Instance
    [Parameter(Mandatory = $true, ParameterSetName = "ClientSecret")]
    [Parameter(Mandatory = $true, ParameterSetName = "InteractiveLogon")]
    [string]
    $EnvironmentUrl,

    # Dataverse Web API Version Used. Defaults to v9.2
    [Parameter(Mandatory = $false, ParameterSetName = "ClientSecret")]
    [Parameter(Mandatory = $false, ParameterSetName = "InteractiveLogon")]
    [string]
    $ApiVersion = "v9.2",

    # Switch to manage if it's going to be interactive or not
    [Parameter(Mandatory = $false, ParameterSetName = "ClientSecret")]
    [Parameter(Mandatory = $true, ParameterSetName = "InteractiveLogon")]
    [switch]
    $Interactive
  )

  Begin {
    switch ($PSCmdlet.ParameterSetName) {
      "ClientSecret" { 
        # Nothing that needs to be done for now
      }
      "InteractiveLogon" {
        # Defaulting to the Dynamics 365 Development Tools if not set
        # https://docs.microsoft.com/en-us/dynamics365/customerengagement/on-premises/deploy/post-installation-configuration-guidelines-dynamics-365?view=op-9-1
        if ($ClientId -eq "") {
          $ClientId = "2ad88395-b77d-4561-9441-d0e40824f9bc"
          $RedirectUri = "app://5d3e90d6-aa8e-48a8-8f2c-58b45cc67315/"
        }
      }
      Default {
        Write-Error -Message "Unhandled parameter set" -ErrorAction Stop
      }
    }
  }

  Process {

    $Scopes = @(
      $EnvironmentUrl + "/.default"
    )
    Write-Host $PSCmdlet.ParameterSetName
    switch ($PSCmdlet.ParameterSetName) {
      "ClientSecret" {
        $AuthSession = Get-MsalToken `
          -ClientId $ClientId `
          -ClientSecret $ClientSecret `
          -TenantId $TenantId `
          -Scopes $Scopes
  
        $DataverseSession.AuthSession = $AuthSession
        $DataverseSession.ServiceUrl = $EnvironmentUrl + "/api/data/" + $ApiVersion
        
      }
      "InteractiveLogon" {
        $AuthSession = Get-MsalToken `
          -ClientId $ClientId `
          -RedirectUri $RedirectUri `
          -TenantId $TenantId `
          -Scopes $Scopes `
          -Interactive
  
        $DataverseSession.AuthSession = $AuthSession
        $DataverseSession.ServiceUrl = $EnvironmentUrl + "/api/data/" + $ApiVersion
        
      }
      Default {
        Write-Error -Message "Unhandled parameter set" -ErrorAction Stop
      }
    }
  }

  End {}
}
