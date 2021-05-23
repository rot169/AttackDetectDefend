#########################################################
# disable_office_test.ps1
#
# Written by Andy Smith / @rot169
#
# Run with admin privileges to update the registry for all users in HKEY_USERS
# to disallow user access to the Office Test registry key, which would otherwise
# be open to abuse as a method of persistence. Check out the associated YouTube
# video for details: https://www.youtube.com/watch?v=9BB58-tlsCQ
#
# This has NOT been robustly tested, use at your own risk, etc
#

# Mount HKEY_USERS
New-PSDrive HKU Registry HKEY_USERS

# Remove any local machine Office test key (and it's contents)
Remove-Item -Path "HKLM:\Software\Microsoft\Office Test" -ErrorAction SilentlyContinue

# Get a list of all HKEY_USER SIDs that arent 'special' and loop through them
Get-ChildItem -Path "REGISTRY::HKEY_USERS" |
    Select-String "S-1-[0-9]+-[0-9]+-[0-9]+-[0-9]+-[0-9]+-[0-9]+$" |% {$_.Matches } | % {$_.Value} | % {

	# Remove any existing Office test key (and it's contents)
	Remove-Item -Path "HKU:\$_\Software\Microsoft\Office Test" -ErrorAction SilentlyContinue

	# Create a fresh Office Test key
	New-Item -Path "HKU:\$_\Software\Microsoft\Office Test"

	# Grab the current permissions for this new key
	$acl = Get-ACL "HKU:\$_\Software\Microsoft\Office Test"

	# Change ownership to system
	$system = New-Object System.Security.Principal.NTAccount("$ENV:computername", "$ENV:username")
	$acl.SetOwner($system)

	# Remove inheritance - and all other permissions along with it
	$acl.SetAccessRuleProtection($true,$false)

	# Write the ACL changes to the registry
	Set-ACL "HKU:\$_\Software\Microsoft\Office Test" -AclObject $acl
}

