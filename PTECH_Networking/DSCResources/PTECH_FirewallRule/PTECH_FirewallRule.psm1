# Default Display Group for the Firewall cmdlets
$DefaultDisplayGroup = "DSC_FirewallRule"

# Constants used by HNetCfg.FwPolicy2

# Direction
$NET_FW_RULE_DIR_IN = 1
$NET_FW_RULE_DIR_OUT = 2

# Action
$NET_FW_ACTION_BLOCK = 0
$NET_FW_ACTION_ALLOW = 1

# Protocol
$NET_FW_IP_PROTOCOL_TCP = 6
$NET_FW_IP_PROTOCOL_UDP = 17

# Profiles
$NET_FW_PROFILE2_DOMAIN = 1
$NET_FW_PROFILE2_PRIVATE = 2
$NET_FW_PROFILE2_PUBLIC = 4
$NET_FW_PROFILE2_ANY = 2147483647

function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
        # Name of the Firewall Rule
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,
                      
        # Permit or Block the supplied configuration 
        [Parameter(Mandatory)]
        [ValidateSet("NotConfigured", "Allow", "Block")]
        [String]$Access
	)

    $getTargetResourceResult = @{}

    $getTargetResourceResult.Name = $Name
    $getTargetResourceResult.Ensure = 'Present'

    Write-Verbose "Get: Get Rules for the specified Name [$Name]"
    $FirewallRule = Get-FirewallRule -Name $Name -ErrorAction SilentlyContinue

    if (!($FirewallRule))
    {
        Write-Verbose "Get: Firewall Rule does not exist"
        $getTargetResourceResult.Ensure = 'Absent'
        return $getTargetResourceResult
        }
    
    $getTargetResourceResult.DisplayName = $FirewallRule.Name
    $getTargetResourceResult.DisplayGroup = $FirewallRule.Grouping

    switch ($FirewallRule.Action)
    {
        $NET_FW_ACTION_BLOCK
        {
            $getTargetResourceResult.Access = 'Block'
            }
        $NET_FW_ACTION_ALLOW
        {
            $getTargetResourceResult.Access = 'Allow'
            }
        default
        {
            $getTargetResourceResult.Access = 'Not Configured'
            }
        }
    
    if ($FirewallRule.Enabled)
    {
        $getTargetResourceResult.State = 'Enabled'
        }
    else
    {
        $getTargetResourceResult.State = 'Disabled'
        }

    $getTargetResourceResult.Profile = Get-FirewallProfile -Profile $FirewallRule.Profiles

    switch ($FirewallRule.Direction)
    {
        $NET_FW_RULE_DIR_IN
        {
            $getTargetResourceResult.Direction = 'Inbound'
            }
        $NET_FW_RULE_DIR_OUT
        {
            $getTargetResourceResult.Direction = 'Outbound'
            }
        }

    $getTargetResourceResult.RemotePort = $FirewallRule.RemotePorts
    $getTargetResourceResult.LocalPort = $FirewallRule.LocalPorts
    $getTargetResourceResult.Protocol = $FirewallRule.Protocol
    $getTargetResourceResult.Description = $firewallRule.Description
    $getTargetResourceResult.ApplicationPath = $FirewallRule.ApplicationName
    $getTargetResourceResult.Service = $FirewallRule.serviceName

    return $getTargetResourceResult;
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Name,

		[System.String]
		$DisplayName,

		[System.String]
		$DisplayGroup,

		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure,

		[parameter(Mandatory = $true)]
		[ValidateSet("NotConfigured","Allow","Block")]
		[System.String]
		$Access,

		[ValidateSet("Enabled","Disabled")]
		[System.String]
		$State,

		[ValidateSet("Any","Public","Private","Domain")]
		[System.String]
		$Profile,

		[ValidateSet("Inbound","Outbound")]
		[System.String]
		$Direction,

		[System.String]
		$RemotePort,

		[System.String]
		$LocalPort,

		[System.String]
		$Protocol,

		[System.String]
		$Description,

		[System.String]
		$ApplicationPath,

		[System.String]
		$Service
	)

	#Write-Verbose "Use this cmdlet to deliver information about command processing."

	#Write-Debug "Use this cmdlet to write debug information while troubleshooting."

	#Include this line if the resource requires a system reboot.
	#$global:DSCMachineStatus = 1


}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Name,

		[System.String]
		$DisplayName,

		[System.String]
		$DisplayGroup,

		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure,

		[parameter(Mandatory = $true)]
		[ValidateSet("NotConfigured","Allow","Block")]
		[System.String]
		$Access,

		[ValidateSet("Enabled","Disabled")]
		[System.String]
		$State,

		[ValidateSet("Any","Public","Private","Domain")]
		[System.String]
		$Profile,

		[ValidateSet("Inbound","Outbound")]
		[System.String]
		$Direction,

		[System.String]
		$RemotePort,

		[System.String]
		$LocalPort,

		[System.String]
		$Protocol,

		[System.String]
		$Description,

		[System.String]
		$ApplicationPath,

		[System.String]
		$Service
	)

	#Write-Verbose "Use this cmdlet to deliver information about command processing."

	#Write-Debug "Use this cmdlet to write debug information while troubleshooting."


	<#
	$result = [System.Boolean]
	
	$result
	#>
}


Export-ModuleMember -Function *-TargetResource


Function Get-FirewallRule
{
    [CmdletBinding()]
    param
    (
    [string]$Name
    )
    Begin
    {
        $FwPolicy = New-Object -ComObject HNetCfg.FwPolicy2
        $CurrentProfiles = $FwPolicy.CurrentProfileTypes
        if ($Name)
        {
            $RuleObjects = $FwPolicy.Rules |Where-Object {$_.Name -eq $Name}
            }
        else
        {
            $RuleObjects = $FwPolicy.Rules
            }
        }
    Process
    {
        $RuleObjects
        }
    End
    {
        }
    }
Function Get-FirewallProfile
{
    <#
    http://stackoverflow.com/questions/2648052/using-powershells-bitwise-operators
    #>
    Param
    (
    $Profile
    )
    Begin
    {
        # Profiles
        $NET_FW_PROFILE2_DOMAIN = 1
        $NET_FW_PROFILE2_PRIVATE = 2
        $NET_FW_PROFILE2_PUBLIC = 4
        $NET_FW_PROFILE2_ANY = 2147483647
        
        $Profiles = @{1 = 'Domain'; 2 = 'Private'; 4 = 'Public'}
        }
    Process
    {
        if ($Profile -ne $NET_FW_PROFILE2_ALL)
        {
            Return $Profiles.Keys |Where-Object {$_ -band $Profile} |ForEach-Object {$Profiles.Item($_)}
            }
        else
        {
            Return "Any"
            }
        }
    End
    {
        }
    }