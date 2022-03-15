#region Get-Dynamics365SalesOrder

function Get-DataverseSalesOrder {
  [CmdletBinding()]
  Param (
      [Parameter(ParameterSetName = "SalesOrderId")]
      [string]
      $SalesOrderId = $null
  )

  if ($PSCmdlet.ParameterSetName -eq "SalesOrderId") {
      Write-Debug -Message "Getting spesific sales order with id '$SalesOrderId'"
      $Result = Get-DataverseTableRow -Table "salesorders" -RowId $SalesOrderId
  } else {
      Write-Debug -Message "Getting Sales Orders from Dataverse"
      $Result = Get-DataverseTableRow -Table "salesorders"
  }

  return $Result
  
}

#endregion