<#
.Synopsis
	Performs the post deploy operations needed to complete the environment configuration
.Description
	Set the connection string of the API Connection to the Service Bus in the template
.Parameter ResourceGroupName
    Name of the resource group where the resources are located
.Parameter ServiceBusNamespace
    Namespace of the service bus to get keys from
.Parameter ServiceBusKey
    Optional, Name of the authorization role to get connection string from
.Parameter ApiConnection
    Optional, Name of the API Connection to set the connection string on
#>
param(
    [Parameter(Position=0,mandatory=$true)]
    [string]$ResourceGroupName,
    [Parameter(Position=1,mandatory=$true)]
    [string]$ServiceBusNamespace,
    [Parameter(Position=2,mandatory=$false)]
    [string]$ServiceBusKey = "SendOnly",
    [Parameter(Position=3,mandatory=$false)]
    [string]$ApiConnection = "servicebus"
)

$keys = Get-AzureRmServiceBusKey -ResourceGroupName $ResourceGroupName -Namespace $ServiceBusNamespace -Name $ServiceBusKey
$api = Get-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/connections -ResourceName $ApiConnection -ExpandProperties
$parameterValues = @{ "connectionString" = $keys.PrimaryConnectionString }
$api.Properties | Add-Member -MemberType NoteProperty -Name parameterValues -Value $parameterValues -Force
$api | Set-AzureRmResource -Force