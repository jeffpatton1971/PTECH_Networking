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
    $FirewallRule = ConvertTo-Rule -FwRule (Get-FirewallRule -Name $Name -ErrorAction SilentlyContinue)

    if (!($FirewallRule))
    {
        Write-Verbose "Get: Firewall Rule does not exist"
        $getTargetResourceResult.Ensure = 'Absent'
        return $getTargetResourceResult
        }
    
    $getTargetResourceResult.DisplayName = $FirewallRule.Name
    $getTargetResourceResult.DisplayGroup = $FirewallRule.Grouping
    $getTargetResourceResult.Access = $FirewallRule.Access
    $getTargetResourceResult.State = $FirewallRule.State
    $getTargetResourceResult.Profile = $FirewallRule.GetProfiles()
    $getTargetResourceResult.Direction = $FirewallRule.Direction
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
		# Name of the Firewall Rule
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        # Localized, user-facing name of the Firewall Rule being created        
        [ValidateNotNullOrEmpty()]
        [String]$DisplayName = $Name,
        
        # Name of the Firewall Group where we want to put the Firewall Rules        
        [ValidateNotNullOrEmpty()]
        [String]$DisplayGroup = $DefaultDisplayGroup,

        # Ensure the presence/absence of the resource
        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present",

        # Permit or Block the supplied configuration 
        [Parameter(Mandatory)]
        [ValidateSet("NotConfigured", "Allow", "Block")]
        [String]$Access = "Allow",

        # Enable or disable the supplied configuration        
        [ValidateSet("Enabled", "Disabled")]
        [String]$State = "Enabled",

        # Specifies one or more profiles to which the rule is assigned        
        [ValidateSet("Any", "Public", "Private", "Domain")]
        [String[]]$Profile = ("Any"),

        # Direction of the connection        
        [ValidateSet("Inbound", "Outbound")]
        [String]$Direction,

        # Specific Port used for filter. Specified by port number, range, or keyword        
        [ValidateNotNullOrEmpty()]
        [String[]]$RemotePort,

        # Local Port used for the filter        
        [ValidateNotNullOrEmpty()]
        [String[]]$LocalPort,

        # Specific Protocol for filter. Specified by name, number, or range        
        [ValidateNotNullOrEmpty()]
        [String]$Protocol,

        # Documentation for the Rule       
        [String]$Description,

        # Path and file name of the program for which the rule is applied        
        [ValidateNotNullOrEmpty()]
        [String]$ApplicationPath,

        # Specifies the short name of a Windows service to which the firewall rule applies        
        [ValidateNotNullOrEmpty()]
        [String]$Service
	)
    
    Write-Verbose "SET: Find firewall rules with specified parameters for Name = $Name, DisplayGroup = $DisplayGroup"
    $firewallRules = Get-FirewallRule -Name $Name |Where-Object {$_.Grouping -eq $DisplayGroup}

    [PTECH.Networking.Firewall.Rule]$Rule = New-Object PTECH.Networking.Firewall.Rule($Name)
    $Rule.DisplayGroup = $DisplayGroup

    switch ($Access)
    {
        'Block'
        {
            $Rule.Access = $NET_FW_ACTION_BLOCK
            }
        'Allow'
        {
            $Rule.Access = $NET_FW_ACTION_ALLOW
            }
        default
        {
            $Rule.Access = 'Not Configured'
            }
        }

    if ($State -eq 'Enabled')
    {
        $Rule.State = $true
        }
    else
    {
        $Rule.State = $false
        }

    $Rule.Profile = $Profile
    
    switch ($Direction)
    {
        'Inbound'
        {
            $Rule.Direction = $NET_FW_RULE_DIR_IN
            }
        'Outbound'
        {
            $Rule.Direction = $NET_FW_RULE_DIR_OUT
            }
        }

    $Rule.RemotePort = $RemotePort
    $Rule.LocalPort = $LocalPort
    $Rule.Protocol = $Protocol
    $Rule.Description = $Description
    $Rule.ApplicationPath = $ApplicationPath
    $Rule.Service = $Service

    $exists = ($firewallRules -ne $null)

    if ($Ensure -eq 'Present')
    {
        Write-Verbose "SET: We want the firewall rule to exist since Ensure is set to $Ensure"
        if ($exists)
        {
            Write-Verbose "SET: We want the firewall rule to exist and it does exist. Check for valid properties"
            foreach ($FirewallRule in $firewallRules)
            {
                $oRule = ConvertTo-Rule -FwRule $FirewallRule
                Write-Verbose "SET: Check each defined parameter against the existing firewall rule - $($firewallRule.Name)"
                if(Test-FirewallRule -FirewallRule1 $oRule -FirewallRule2 $Rule) # test function for each property return $false on first mismatch
                {
                    }
                else
                {
                    Write-Verbose "SET: Removing existing firewall rule [$Name] to recreate one based on desired configuration"
                    Remove-FirewallRule -Name $Name

                    # Set the Firewall rule based on specified parameters
                    New-FirewallRule -Rule $Rule
                    }
                }
            }
        else
        {
            Write-Verbose "SET: Removing existing firewall rule [$Name] to recreate one based on desired configuration"

            # Set the Firewall rule based on specified parameters
            New-FirewallRule -Rule $Rule
            }
        }
    elseif ($Ensure -eq 'Absent')
    {
        Write-Verbose "SET: We do not want the firewall rule to exist"
        if ($exists)
        {
            Write-Verbose "SET: We do not want the firewall rule to exist, but it does. Removing the Rule(s)"
            foreach ($firewallRule in $firewallRules)
            {
                # Remove the firewall rule
                Remove-FirewallRule -Name $FirewallRule.Name
                }
            }
        else
        {
            Write-Verbose "SET: We do not want the firewall rule to exist, and it does not"
            }
        }
}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		# Name of the Firewall Rule
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        # Localized, user-facing name of the Firewall Rule being created        
        [ValidateNotNullOrEmpty()]
        [String]$DisplayName = $Name,
        
        # Name of the Firewall Group where we want to put the Firewall Rules        
        [ValidateNotNullOrEmpty()]
        [String]$DisplayGroup,

        # Ensure the presence/absence of the resource
        [ValidateSet("Present", "Absent")]
        [String]$Ensure = "Present",

        # Permit or Block the supplied configuration 
        [Parameter(Mandatory)]
        [ValidateSet("NotConfigured", "Allow", "Block")]
        [String]$Access,

        # Enable or disable the supplied configuration        
        [ValidateSet("Enabled", "Disabled")]
        [String]$State,

        # Specifies one or more profiles to which the rule is assigned        
        [ValidateSet("Any", "Public", "Private", "Domain")]
        [String[]]$Profile,

        # Direction of the connection        
        [ValidateSet("Inbound", "Outbound")]
        [String]$Direction,

        # Specific Port used for filter. Specified by port number, range, or keyword        
        [ValidateNotNullOrEmpty()]
        [String[]]$RemotePort,

        # Local Port used for the filter        
        [ValidateNotNullOrEmpty()]
        [String[]]$LocalPort,

        # Specific Protocol for filter. Specified by name, number, or range        
        [ValidateNotNullOrEmpty()]
        [String]$Protocol,

        # Documentation for the Rule        
        [String]$Description,

        # Path and file name of the program for which the rule is applied        
        [ValidateNotNullOrEmpty()]
        [String]$ApplicationPath,

        # Specifies the short name of a Windows service to which the firewall rule applies        
        [ValidateNotNullOrEmpty()]
        [String]$Service
	)
    
    Write-Verbose "TEST: Find rules with specified parameters"
    $FirewallRules = Get-FirewallRule -Name $fwRule.Name |Where-Object {$_.Grouping -eq $DisplayGroup}

    [PTECH.Networking.Firewall.Rule]$Rule = New-Object PTECH.Networking.Firewall.Rule($Name)
    $Rule.DisplayGroup = $DisplayGroup

    switch ($Access)
    {
        'Block'
        {
            $Rule.Access = $NET_FW_ACTION_BLOCK
            }
        'Allow'
        {
            $Rule.Access = $NET_FW_ACTION_ALLOW
            }
        default
        {
            $Rule.Access = 'Not Configured'
            }
        }

    if ($State -eq 'Enabled')
    {
        $Rule.State = $true
        }
    else
    {
        $Rule.State = $false
        }

    $Rule.Profile = $Profile
    
    switch ($Direction)
    {
        'Inbound'
        {
            $Rule.Direction = $NET_FW_RULE_DIR_IN
            }
        'Outbound'
        {
            $Rule.Direction = $NET_FW_RULE_DIR_OUT
            }
        }

    $Rule.RemotePort = $RemotePort
    $Rule.LocalPort = $LocalPort
    $Rule.Protocol = $Protocol
    $Rule.Description = $Description
    $Rule.ApplicationPath = $ApplicationPath
    $Rule.Service = $Service

    if (!$firewallRules)
    {
        Write-Verbose "TEST: Get-FirewallRules returned NULL"
        
        # Returns whether complies with $Ensure
        $returnValue = ($false -eq ($Ensure -eq "Present"))

        Write-Verbose "TEST: Returning $returnValue"
        
        return $returnValue
    }
    
    $exists = $true
    $valid = $true
    foreach ($firewallRule in $firewallRules)
    {
        Write-Verbose "TEST: Check each defined parameter against the existing Firewall Rule - $($firewallRule.Name)"
        $oRule = ConvertTo-Rule -FwRule $firewallRule
        if (Test-FirewallRule -FirewallRule1 $oRule -FirewallRule2 $Rule)
        {
            }
        else
        {
            $valid = $false
            }
        }

    # Returns whether or not $exists complies with $Ensure
    $returnValue = ($valid -and $exists -eq ($Ensure -eq "Present"))

    Write-Verbose "TEST: Returning $returnValue"
    
    return $returnValue
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