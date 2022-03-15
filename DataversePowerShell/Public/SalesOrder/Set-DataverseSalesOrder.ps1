function Set-DataverseSalesOrder {
    [CmdletBinding()]
    param (
        # Unique ID for the Sales Order (GUID)
        [string]
        $SalesOrderId,

        [ValidateSet("ActiveNew", "CancelOrderRejected", "FulfillOrderComplete", "FulfillOrderPartial")]
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
            "ActiveNew" {
                $Body = @{
                    statecode = 0
                    statuscode = 1
                }
                  
                Update-DataverseTableRow -Table "salesorders" -RowId $SalesOrderId -Body $Body
                break
            }
            "CancelOrderRejected" {
                $Action = "CancelSalesOrder"
                $Body = @{
                    "Status"     = 100000000
                    "OrderClose" = @{
                        "@odata.type" = "#Microsoft.Dynamics.CRM.orderclose"
                        actualend            = $ActualEndDate
                        description          = $Description
                        "salesorderid@odata.bind" = "/salesorders($SalesOrderId)"
                    }
                }
                Invoke-DataverseAction -Action $Action -Body $Body
                break
            }

            "FulfillOrderComplete" {
                $Action = "salesorders/Microsoft.Dynamics.CRM.FulfillSalesOrder"
                $Body = @{
                    "Status"     = 100001
                    "OrderClose" = @{
                        "@odata.type" = "#Microsoft.Dynamics.CRM.orderclose"
                        actualend            = $ActualEndDate
                        description          = $Description
                        "salesorderid@odata.bind" = "/salesorders($SalesOrderId)"
                    }
                }
                Invoke-DataverseAction -Action $Action -Body $Body
                break
            }

            "FulfillOrderPartial" {
                $Action = "salesorders/Microsoft.Dynamics.CRM.FulfillSalesOrder"
                $Body = @{
                    "Status"     = 100002
                    "OrderClose" = @{
                        "@odata.type" = "#Microsoft.Dynamics.CRM.orderclose"
                        actualend            = $ActualEndDate
                        description          = $Description
                        "salesorderid@odata.bind" = "/salesorders($SalesOrderId)"
                    }
                }
                Invoke-DataverseAction -Action $Action -Body $Body
                break
            }
        }
        
    }
    
}