#region Update-DataverseTableRow

function Update-DataverseTableRow {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [string]
        $Table,

        # Row ID
        [Parameter(Mandatory)]
        [string]
        $RowId,
      
        [Hashtable]
        $QueryParameter = $null,

        [Hashtable]
        $Body
    )

    $AccessToken = $DataverseSession.AuthSession.AccessToken
    $Url = "$($DataverseSession.ServiceUrl)"

    $headers = @{
        "Content-Type"      = "application/json"
        Authorization       = "Bearer $($AccessToken)"
        "OData-MaxVersion"  = "4.0"  
        "OData-Version"     = "4.0"
        "If-Match"          = "*" 
        "Prefer"            = "return=representation"
    }
 
    $RequestUrl = "$Url/$Table($RowId)"

    if ($QueryParameter) {
        $RequestUrl = New-HttpQueryString -Uri $RequestUrl -QueryParameter $QueryParameter
    }

    Write-Verbose "Request uri '$RequestUrl'"

    Invoke-RestMethod -Uri $RequestUrl -Headers $headers -Method Patch -Body $($Body | ConvertTo-Json)

}

#endregion