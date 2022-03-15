#region New-DataverseTableRow

function New-DataverseTableRow {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]
        $Table,
      
        [Hashtable]
        $QueryParameter = $null,

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
 
    $RequestUrl = "$Url/$Table"

    if ($QueryParameter) {
        $RequestUrl = New-HttpQueryString -Uri $RequestUrl -QueryParameter $QueryParameter
    }

    Write-Verbose "Request uri '$RequestUrl'"

    Invoke-RestMethod -Uri $RequestUrl -Headers $headers -Method Post -Body $($Body | ConvertTo-Json)

}

#endregion