<#
Add some notification if the Oppty total price is differenc than source.
#>
function New-DataverseOpportunityFromOrder {
    [CmdletBinding()]
    param (
        # OrderId
        [Parameter(Mandatory=$true)]
        [string]
        $OrderId
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
        Write-Verbose -Message "Getting Order"
        $Order = Get-DataverseTableRow -Table "salesorders" -RowId $OrderId
        Write-Verbose -Message $Order

        if ($Order) {
            Write-Verbose -Message "Getting Order details"
            $OrderDetails = Get-DataverseTableRow -Table "salesorderdetails" -QueryParameter @{"`$filter" = "_salesorderid_value eq $($Order.salesorderid)"}

            $OpportunityProducts = @()
            foreach ($Product in $OrderDetails) {
                Write-Verbose -Message "Adding product to list of products that are going into opportunity"
                Write-Verbose $Product

                $ProductToAdd = @{
                    priceperunit = $Product.priceperunit
                    quantity = $Product.quantity
                    ispriceoverridden = $Product.ispriceoverridden
                    isproductoverridden = $Product.isproductoverridden
                    overriddencreatedon = $Product.createdon
                }

                if ($Product.isproductoverridden -eq $true) {
                    $ProductToAdd.Add("productname", $Product.productname)
                    $ProductToAdd.Add("productdescription", $Product.productdescription)
                } else {
                    $ProductToAdd.Add("uomid@odata.bind", "/uoms($($Product._uomid_value))")
                    $ProductToAdd.Add("productid@odata.bind", "/products($($Product._productid_value))")
                }

                $OpportunityProducts += $ProductToAdd
            }

            $NewOpportunityBody = @{
                name = $Order.name
                "transactioncurrencyid@odata.bind" = "/transactioncurrencies($($Order._transactioncurrencyid_value))"
                "customerid_account@odata.bind" = "/accounts($($Order._customerid_value))"
                "pricelevelid@odata.bind" = "/pricelevels($($Order._pricelevelid_value))"
                overriddencreatedon = $Order.createdon
                product_opportunities = $OpportunityProducts
            }

            $Opportunity = New-DataverseTableRow -Table "opportunities" -Body $NewOpportunityBody

            # For each product added to opportunity, request it to trigger price calc
            $OpportunityDetails = Get-DataverseTableRow -Table "opportunityproducts" -QueryParameter @{"`$filter" = "_opportunityid_value eq $($Opportunity.opportunityid)"}

            foreach ($OpptyProduct in $OpportunityDetails) {
                Get-DataverseTableRow -Table "opportunityproducts" -RowId $OpptyProduct.opportunityproductid | Out-Null
            }

            return $Opportunity
        }

        else {
            Write-Error -Message "Quote not found" -Category ObjectNotFound -ErrorAction Stop
        }
    }
    
    end {
        
    }
}