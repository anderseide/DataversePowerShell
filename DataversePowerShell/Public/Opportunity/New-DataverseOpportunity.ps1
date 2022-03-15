#region New-DataverseOpportunity

function New-DataverseOpportunity {
  [CmdletBinding(DefaultParameterSetName = "NewOppty")]
  Param (
    [Parameter(Mandatory = $true, ParameterSetName = "NewOppty")]
    [string]
    $Name,

    # Order Currency
    [Parameter(Mandatory = $true, ParameterSetName = "NewOppty")]
    [string]
    $CurrencyId,

    # Order Price List
    [Parameter(Mandatory = $true, ParameterSetName = "NewOppty")]
    [string]
    $PriceListId,

    # Order Customer
    [Parameter(Mandatory = $true, ParameterSetName = "NewOppty")]
    [string]
    $CustomerId,

    # Order Customer
    [Parameter(Mandatory = $true, ParameterSetName = "NewOppty")]
    [hashtable]
    $ColumnValue,

    # Copy from existing Quote
    [Parameter(Mandatory = $true, ParameterSetName = "CopyFromQuote")]
    [switch]
    $CopyFromQuote,

    # Quote ID when copying from Quote
    [Parameter(Mandatory = $true, ParameterSetName = "CopyFromQuote")]  
    [string]
    $QuoteID,

    # Copy from existing Order
    [Parameter(Mandatory = $true, ParameterSetName = "CopyFromOrder")]
    [switch]
    $CopyFromOrder,

    # Order ID when copying from Order
    [Parameter(Mandatory = $true, ParameterSetName = "CopyFromOrder")]  
    [string]
    $OrderID    
  )

  begin {
    if (!$(Test-DataverseConnected)) {
      Write-Error `
        -Message "Your connection either timed out, have been revoced or never connected" `
        -Category AuthenticationError `
        -ErrorAction Stop
    }
  }

  process {

    switch ($PSCmdlet.ParameterSetName) {
      "NewOppty" {
        $Body = @{
          name                               = $Name
          "transactioncurrencyid@odata.bind" = "/transactioncurrencies($CurrencyId)"
          "customerid_account@odata.bind"    = "/accounts($CustomerId)"
          "pricelevelid@odata.bind"          = "/pricelevels($PriceListId)"
        }
    
        $Body += $ColumnValue
      
    
    
        New-DataverseTableRow -Table "opportunities" -Body $Body
    
        return $Result
      }
      "CopyFromQuote" {
        New-DataverseOpportunityFromQuote -QuoteId $QuoteID
      }
      "CopyFromOrder" {
        New-DataverseOpportunityFromOrder -OrderId $OrderID
      }
    }
    
  }
}

#endregion