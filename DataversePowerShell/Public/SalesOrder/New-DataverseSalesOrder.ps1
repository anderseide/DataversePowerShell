#region Get-Dynamics365SalesOrder

function New-DataverseSalesOrder {
  [CmdletBinding()]
  Param (
      [Parameter(Mandatory)]
      [string]
      $Name,

      # Order Currency
      [Parameter(Mandatory)]
      [string]
      $CurrencyId,

      # Order Price List
      [Parameter(Mandatory)]
      [string]
      $PriceListId,

      # Order Customer
      [Parameter(Mandatory)]
      [string]
      $CustomerId
  )

  $Body = @{
      name = $Name
      "transactioncurrencyid@odata.bind" = "/transactioncurrencies($CurrencyId)"
      "customerid_account@odata.bind" = "/accounts($CustomerId)"
      "pricelevelid@odata.bind" = "/pricelevels($PriceListId)"
  }


  New-DataverseTableRow -Table "salesorders" -Body $Body

  return $Result
  
}

#endregion