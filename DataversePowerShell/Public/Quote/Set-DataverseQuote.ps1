function Set-DataverseQuote {
    [CmdletBinding()]
    param (
        # Unique ID for the quote (GUID)
        [string]
        $QuoteId,

        [ValidateSet("Draft", "Active", "Won", "WonCreateOrder", "ClosedLost", "ClosedCanceled", "ClosedRevised", "ClosedRevisedNew")]
        [string]
        $State, 
        
        # Description
        [string]
        $Description,

        # Actual end date
        [string]
        $ActualEndDate = $(Get-Date -Format "yyyy-MM-dd")
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
        switch ($State) {
            "Draft" {
                $Body = @{
                    "statecode" = 0
                }
                  
                Update-DataverseTableRow -Table "quotes" -RowId $Quoteid -Body $Body
                break
            }
            "Active" {
                $Body = @{
                    "statecode" = 1
                }
                  
                Update-DataverseTableRow -Table "quotes" -RowId $Quoteid -Body $Body
                break
            }
            "Won" {
                $Quote = Get-DataverseTableRow -Table "quotes" -RowId $QuoteId
                $Action = "WinQuote"
                $Body = @{
                    "Status"     = 4
                    "QuoteClose" = @{
                        subject              = "Quote Won (Won) - $($Quote.quotenumber)"
                        actualend            = $ActualEndDate
                        description          = $Description
                        quotenumber          = $Quote.quotenumber
                        revision             = $Quote.revisionnumber
                        "quoteid@odata.bind" = "/quotes($QuoteId)"
                    }
                }
                Invoke-DataverseAction -Action $Action -Body $Body
                break
            }
            "WonCreateOrder" {
                
                $Quote = Get-DataverseTableRow -Table "quotes" -RowId $QuoteId
                $Action = "ConvertQuoteToSalesOrder"
                $Body = @{
                    QuoteId               = $Quote.quoteid
                    QuoteCloseStatus      = 4
                    QuoteCloseSubject     = "Quote Won (Won) - $($Quote.quotenumber)"
                    QuoteCloseDescription = $Description
                    QuoteCloseDate        = $ActualEndDate
                    ColumnSet             = @{
                        AllColumns = $true
                    }
                    ProcessInstanceId     = @{
                        "@odata.type"                   = "Microsoft.Dynamics.CRM.businessprocessflowinstance"
                        "businessprocessflowinstanceid" = "00000000-0000-0000-0000-000000000000"
                    }
                }
                Invoke-DataverseAction -Action $Action -Body $Body
                break
            }
            "ClosedLost" {
                $Quote = Get-DataverseTableRow -Table "quotes" -RowId $QuoteId
                $Action = "CloseQuote"
                $Body = @{
                    "Status"     = 5
                    "QuoteClose" = @{
                        subject              = "Quote Closed ({0}) - {1}"
                        actualend            = $ActualEndDate
                        description          = $Description
                        quotenumber          = $Quote.quotenumber
                        revision             = $Quote.revisionnumber
                        "quoteid@odata.bind" = "/quotes($QuoteId)"
                    }
                }
                Invoke-DataverseAction -Action $Action -Body $Body
                break
            }
            "ClosedCanceled" {
                $Quote = Get-DataverseTableRow -Table "quotes" -RowId $QuoteId
                $Action = "CloseQuote"
                $Body = @{
                    "Status"     = 6
                    "QuoteClose" = @{
                        subject              = "Quote Closed ({0}) - {1}"
                        actualend            = $ActualEndDate
                        quotenumber          = $Quote.quotenumber
                        revision             = $Quote.revisionnumber
                        description          = $Description
                        "quoteid@odata.bind" = "/quotes($QuoteId)"
                    }
                }
                Invoke-DataverseAction -Action $Action -Body $Body
                break
            }
            "ClosedRevised" {
                $Quote = Get-DataverseTableRow -Table "quotes" -RowId $QuoteId
                $Action = "CloseQuote"
                $Body = @{
                    "Status"     = 7
                    "QuoteClose" = @{
                        subject              = "Quote Closed ({0}) - {1}"
                        actualend            = $ActualEndDate
                        description          = $Description
                        quotenumber          = $Quote.quotenumber
                        revision             = $Quote.revisionnumber
                        "quoteid@odata.bind" = "/quotes($QuoteId)"
                    }
                }
                Invoke-DataverseAction -Action $Action -Body $Body
                break
            }
            "ClosedRevisedNew" {
                $Quote = Get-DataverseTableRow -Table "quotes" -RowId $QuoteId
                $Action = "CloseQuote"
                $Body = @{
                    "Status"     = 7
                    "QuoteClose" = @{
                        subject              = "Quote Closed ({0}) - {1}"
                        actualend            = $ActualEndDate
                        description          = $Description
                        quotenumber          = $Quote.quotenumber
                        revision             = $Quote.revisionnumber
                        "quoteid@odata.bind" = "/quotes($QuoteId)"
                    }
                }
                Invoke-DataverseAction -Action $Action -Body $Body

                $Action = "ReviseQuote"
                $Body = @{
                    QuoteId = "{$($QuoteId)}"
                    ColumnSet = @{
                        AllColumns = $true
                    }
                }
                Invoke-DataverseAction -Action $Action -Body $Body
                break
            }
        }
        
    }
    
}