#region Get-Dynamics365SalesOrderDetail

function Get-DataverseSalesOrderDetail {
  [CmdletBinding(DefaultParameterSetName = 'All')]
  Param (
      [Parameter(ParameterSetName = "SalesOrderId")]
      [string]
      $SalesOrderId = $null,

      [Parameter(ParameterSetName = "SalesOrderDetailId")]
      [string]
      $SalesOrderDetailId = $null
  )

  switch ($PSCmdlet.ParameterSetName) {
      "SalesOrderId" {
          Write-Debug -Message "Getting spesific sales order details for sales order with id '$SalesOrderId'"
          $QueryParameter = @{
              "`$filter" = "_salesorderid_value eq $SalesOrderId"
          }
          $Result = Get-DataverseTableRow -Table "salesorderdetails" -QueryParameter $QueryParameter
      ; Break
      }
      "SalesOrderDetailId" {
          $Result = Get-DataverseTableRow -Table "salesorderdetails" -RowId $SalesOrderDetailId
      ; Break
      }
      "All" {
          $Result = Get-DataverseTableRow -Table "salesorderdetails"
      }
  }

  return $Result
  
}

#endregion