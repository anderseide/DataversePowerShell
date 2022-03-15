function Set-DataverseSalesOrder {
    [CmdletBinding()]
    param (
        # Unique ID for the Sales Order (GUID)
        [string]
        $SalesOrderId,

        [ValidateSet("CancelOrder", "FulfillOrder")]
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
            "CancelOrder" {
                break
            }

            "FulfillOrder" {
                break
            }
        }
        
    }
    
}