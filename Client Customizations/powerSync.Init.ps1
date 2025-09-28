#==============================================================================#
# (c) 2024 coolOrange s.r.l.                                                   #
#                                                                              #
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#==============================================================================#

# Import all modules in the powerAPS folder
foreach ($module in Get-Childitem "C:\ProgramData\coolOrange\powerAPS" -Name -Filter "*.psm1") {
    Import-Module "C:\ProgramData\coolOrange\powerAPS\$module" -Force -Global
}

function ApsTokenIsValid() {
    # Re-import all modules in the powerAPS folder, in case anything changed in the scripts
    foreach ($module in Get-Childitem "C:\ProgramData\coolOrange\powerAPS" -Name -Filter "*.psm1") {
        Import-Module "C:\ProgramData\coolOrange\powerAPS\$module" -Force -Global
    }

    # Check if the APS connection is already established
    if ($global:ApsConnection) {
        return $true
    }

    $missingRoles = GetMissingRoles @(77, 76)
    if ($missingRoles) {
        [System.Windows.MessageBox]::Show(
            "The current user does not have the required permissions: $missingRoles!", 
            "powerSync: Permission error", 
            "OK", 
            "Error")
        return $false
    }


    $settings = GetVaultApsAuthenticationSettings
    if ($settings -is [powerSync.Error]) {
        ShowPowerSyncErrorMessage -err $settings
        return $false
    }

    # Get the Vault user email and use it as the default username
    $vaultLogin = [Autodesk.Connectivity.WebServicesTools.AutodeskAccount]::Login([IntPtr]::Zero)


    # Connect to APS
    return Connect-APS -ClientID $settings.ClientID -CallbackURL $settings.CallbackUrl -ClientSecret $settings.ClientSecret
}
