<#
Add some notification if the Oppty total price is differenc than source
#>
function New-DataverseOpportunityFromQuote {
    [CmdletBinding()]
    param (
        # QuoteId
        [Parameter(Mandatory=$true)]
        [string]
        $QuoteId
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
        Write-Verbose -Message "Getting Quote"
        $Quote = Get-DataverseTableRow -Table "quotes" -RowId $QuoteId
        Write-Verbose -Message $Quote

        if ($Quote) {
            Write-Verbose -Message "Getting Quote details"
            $QuoteDetails = Get-DataverseTableRow -Table "quotedetails" -QueryParameter @{"`$filter" = "_quoteid_value eq $($Quote.quoteid)"}

            $OpportunityProducts = @()
            foreach ($Product in $QuoteDetails) {
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
                name = $Quote.name
                "transactioncurrencyid@odata.bind" = "/transactioncurrencies($($Quote._transactioncurrencyid_value))"
                "customerid_account@odata.bind" = "/accounts($($Quote._customerid_value))"
                "pricelevelid@odata.bind" = "/pricelevels($($Quote._pricelevelid_value))"
                overriddencreatedon = $Quote.createdon
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