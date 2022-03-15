#region Get-DataverseTable

function Get-DataverseTableRow {
  [CmdletBinding()]
  Param (
      [Parameter(Mandatory)]
      [string]
      $Table,
      
      [Parameter(ParameterSetName = "SingleRow")]
      [string]
      $RowId,

      [Hashtable]
      $QueryParameter,

      [switch]
      $RawReturn = $false
  )

  $AccessToken = $DataverseSession.AuthSession.AccessToken
  $Url = "$($DataverseSession.ServiceUrl)"

  $headers = @{
      Accept = "application/json"
      Authorization = "Bearer $($AccessToken)"
  }

  if ($PSCmdlet.ParameterSetName -eq "SingleRow") {
      Write-Debug -Message  "Setting Request URL to Single Row"
      $RequestUrl = "$Url/$Table($RowId)"
      Write-Debug -Message  "Request URL '$RequestUrl'"
      $RawReturn = $true
  } else {
      Write-Debug -Message  "Setting Request URL to get the whole table"
      $RequestUrl = "$Url/$Table"
      Write-Debug -Message  "Request URL '$RequestUrl'"
  }

  if ($QueryParameter) {
      $RequestUrl = New-HttpQueryString -Uri $RequestUrl -QueryParameter $QueryParameter
  }

  $Result = Invoke-RestMethod -Uri $RequestUrl -Headers $headers -Method Get

  if ($RawReturn) {
      return $Result
  } else {
      return $Result.value
  }

}

#endregion