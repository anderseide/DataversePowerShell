# Microsoft Datavese PowerShell Module

Just a work in progress PowerShell module that wraps operations against the Microsoft Dataverse Web API.

Feel free to use it without any kind of wananty.

# Commands

The following commands are available in this module

## General

* Connect-Dataverse
* Get-DataveseTableRow
* Invoke-DataverseAction
* New-DataverseTableRow

## Dynamics 365 Sales speific

* New-DataverseOpportunity
* Set-DataverseQuote
* Get-DataverseSalesOrder
* Get-DataverseSalesOrderDetails
* New-DataverseSalesOrder

# How to use

1. Download the DataversePowerShell folder in this repo
2. Import the module by running the following command

Not that the scrips are not signed

```powershell
Import-Module -Name .\DataversePowerShell.psm1
```
