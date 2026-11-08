# Script that creates users using the users.csv file
# Creates Northwood Regional staff accounts from a CSV file

# For each row in users.csv it:
# 1. Skips the person if they already have an account
# 2. Builds a First.Last username, adding a number for duplicate names
# 3. Creates the user in their department's OU
# 4. Adds them to their department's security group (creating the group if needed)


Import-Module ActiveDirectory

# --- Settings ---
$domainDN = "DC=northwood,DC=local"
$upnSuffix = "northwood.local"
$csvPath = Join-Path $PSScriptRoot "users.csv"


# Ask once for the starting password. It is never saved in this file.
$password = Read-Host "Enter the initial password for all new users" -AsSecureString

$users = Import-Csv $csvPath
$created = 0
$skipped = 0
$failed = 0

foreach ($person in $users) {
    $fullName = "$($person.FirstName) $($person.LastName)"
    $ouPath = "OU=$($person.Department),OU=Northwood,$domainDN"
    $groupName = "$($person.Department) Staff"

    try {
        # ---- 1. Skip anyone who already has an account ----
        # Match on EmployeeID first, then on the same name department OU
        # (catches accounts created by hand, which have no EmployeeID)
        $existing = Get-ADUser -Filter "EmployeeID -eq '$($person.EmployeeID)'"
        if (-not $existing) {
            $existing = Get-ADUser -Filter "Name -eq '$fullName'" -SearchBase $ouPath -SearchScope OneLevel -ErrorAction Stop
        }

        if ($existing) {
            Write-Host "SKIP  $fullName already exists ($($existing.SamAccountName))" -ForegroundColor Yellow
            $skipped++
            continue
        }

        # ---- 2. Build a unique First.Last username ----
        $base = "$($person.FirstName).$($person.LastName)".ToLower()
        $number = 1
        $suffix = ""

        do {
            $upnName = "$base$suffix"

            # The pre-Windows 2000 logon name (SamAccountName) is limited to 20 characters
            if ($upnName.Length -gt 20) {
                $username = $base.Substring(0, 20 - $suffix.Length) + $suffix
            } else {
                $username = $upnName
            }

            $taken = Get-ADUser -Filter "SamAccountName -eq '$username' -or UserPrincipalName -eq '$upnName@$upnSuffix'"

            if ($taken) {
                $number++
                $suffix = "$number"
            }
        }while ($taken)

        # Two people with the same name can't share a name inside one OU
        if ($suffix) {
            $cn = "$fullName $suffix"
        } else {
            $cn = $fullName
        }

        # ---- 3. Create the user ----
        New-ADUser `
            -Name                  $cn `
            -GivenName             $person.FirstName `
            -Surname               $person.LastName `
            -DisplayName           $fullName `
            -SamAccountName        $username `
            -UserPrincipalName     "$upnName@$upnSuffix" `
            -EmployeeID            $person.EmployeeID `
            -Title                 $person.Title `
            -Department            $person.Department `
            -Path                  $ouPath `
            -AccountPassword       $password `
            -ChangePasswordAtLogon $true `
            -Enabled               $true `
            -ErrorAction           Stop

    # ---- 4. Add them to their department group ----
    if (-not (Get-ADGroup -Filter "Name -eq '$groupName'")) {
        New-ADGroup -Name $groupName -GroupScope Global -GroupCategory Security -Path $ouPath -ErrorAction Stop
        Write-Host "GROUP  Created $groupName" -ForegroundColor Cyan
    }
    
    Add-ADGroupMember -Identity $groupname -Members $username -ErrorAction Stop

    Write-Host "CREATED $fullName -> $username ($groupName)" -ForegroundColor Green
    $created++


    }
    catch {
        Write-Host "FAILED  $fullName - $($_.Exception.Message)" -ForegroundColor Red
        $failed++
    }
}

Write-Host ""
Write-Host "Done. Created: $created Skipped: $skipped Failed: $failed"
