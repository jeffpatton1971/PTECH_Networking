function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Name,

		[parameter(Mandatory = $true)]
		[ValidateSet("NotConfigured","Allow","Block")]
		[System.String]
		$Access
	)

	#Write-Verbose "Use this cmdlet to deliver information about command processing."

	#Write-Debug "Use this cmdlet to write debug information while troubleshooting."


	<#
	$returnValue = @{
		Name = [System.String]
		DisplayName = [System.String]
		DisplayGroup = [System.String]
		Ensure = [System.String]
		Access = [System.String]
		State = [System.String]
		Profile = [System.String]
		Direction = [System.String]
		RemotePort = [System.String]
		LocalPort = [System.String]
		Protocol = [System.String]
		Description = [System.String]
		ApplicationPath = [System.String]
		Service = [System.String]
	}

	$returnValue
	#>
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

