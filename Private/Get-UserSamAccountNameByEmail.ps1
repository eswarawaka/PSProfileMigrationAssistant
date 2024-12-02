<#
.SYNOPSIS
Retrieves the SamAccountName of a user based on their email address in the current logon domain.

.DESCRIPTION
This function queries Active Directory to find the SamAccountName of a user by their email address.
It automatically detects the user's current logon domain and uses it to construct the LDAP search path.
If the user is not found or the function is executed outside of a domain environment, an appropriate error message is returned.

.PARAMETER EmailAddress
The email address of the user whose SamAccountName needs to be retrieved.

.EXAMPLE
Get-UserSamAccountNameByEmail -EmailAddress "user@example.com"
This command retrieves the SamAccountName for the user with the email "user@example.com"
in the domain of the currently logged-on user.

.EXAMPLE
Get-UserSamAccountNameByEmail -EmailAddress "user@example.com" -PrimaryCatalog GC://dc=test,dc=europe,dc=com
This command retrieves the SamAccountName for the user with the email "user@example.com"
in the domain of the currently logged-on user,if not found it will check the Primary catalog provided.

.NOTES
- This function requires the script to be run in a domain environment.
- The function automatically uses the current user's logon domain for the search.
- It supports searching for one user at a time.

.OUTPUTS
[string]
Returns the SamAccountName of the user if found.

.ERRORS
- If the user is not found in the domain, an error is returned.
- If the script is run outside of a domain environment, an error is returned.

#>
Function Get-UserSamAccountNameByEmail {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$EmailAddress,

        [Parameter(Mandatory = $true)]
        [string]$PrimaryCatalog,

        [Parameter(Mandatory = $false)]
        [string]$SecondaryCatalog
    )

    # Helper function to perform AD search
    function Search-AD {
        Param(
            [string]$SearchRoot
        )

        Try {
            $searcher = New-Object System.DirectoryServices.DirectorySearcher
            $searcher.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry($SearchRoot)
            $searcher.PageSize = 1000
            $searcher.Filter = "(&(objectCategory=User)(mail=$EmailAddress))"
            $searcher.SearchScope = "Subtree"

            $result = $searcher.FindOne()

            if ($null -ne $result) {
                $samaccountname = $result.Properties["samaccountname"][0]              
                return $samaccountname
                 
            } else {
                return $null
            }
        } Catch {
            Write-Warning "Error accessing AD on $SearchRoot : $_"
            return $null
        }
    }

    # Search primary catalog
    $domain = Search-AD -SearchRoot $PrimaryCatalog
    if ($domain) {
        return $domain
    } elseif ($SecondaryCatalog) {
        # If not found in primary and secondary catalog is provided, search secondary catalog
        $domain = Search-AD -SearchRoot $SecondaryCatalog
        if ($domain) {
            return $domain
        }
    }

    # If user is not found in primary and either no secondary or not found in secondary
    Write-Error "User `$SamAccountName` not found in the primary domain. If you have a secondary catalog, please make sure to enter it to check there as well."
    return $null
}