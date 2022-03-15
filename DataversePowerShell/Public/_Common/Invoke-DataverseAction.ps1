<#
    .Synopsis
    Invokes a Action as decribed here https://docs.microsoft.com/en-us/powerapps/developer/data-platform/webapi/use-web-api-actions

#>
function Invoke-DataverseAction {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]
        $Action,
      
        [Hashtable]
        $Body
    )

    $AccessToken = $DataverseSession.AuthSession.AccessToken
    $Url = "$($DataverseSession.ServiceUrl)"

    $headers = @{
        "Content-Type"     = "application/json"
        Authorization      = "Bearer $($AccessToken)"
        "OData-MaxVersion" = "4.0"  
        "OData-Version"    = "4.0"
        "Prefer"           = "return=representation"
    }
 
    $RequestUrl = "$Url/$Action"

    Write-Verbose "Request uri '$RequestUrl'"

    Invoke-RestMethod -Uri $RequestUrl -Headers $headers -Method Post -Body $($Body | ConvertTo-Json)

}