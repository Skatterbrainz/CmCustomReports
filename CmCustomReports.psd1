﻿#
# Module manifest for module 'CmCustomReports'
#
# Generated by: David M. Stein
#
# Generated on: 10/9/2018
#

@{

# Script module or binary module file associated with this manifest.
RootModule = '.\CmCustomReports.psm1'

# Version number of this module.
ModuleVersion = '1.0'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = 'df4bf1a1-3dca-455b-b96f-d74cf8b0b611'

# Author of this module
Author = 'David M. Stein'

# Company or vendor of this module
CompanyName = ''

# Copyright statement for this module
Copyright = '2018 David M. Stein'

# Description of the functionality provided by this module
Description = 'ConfigMgr Custom Reports'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
PowerShellHostVersion = '3.0'

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    'Run-CmCustomQuery'
)

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
FileList = @(
    '.\Queries\Clients-Inventory-BiosVersions.sql', 
    '.\Queries\Clients-Inventory-ADSites.sql', 
    '.\Queries\Clients-Inventory-General.sql', 
    '.\Queries\Clients-Inventory-IPGateways.sql', 
    '.\Queries\Clients-Inventory-Memory.sql', 
    '.\Queries\Clients-Inventory-Models.sql', 
    '.\Queries\Clients-Inventory-OldHwData.sql', 
    '.\Queries\Clients-Inventory-OsVersions.sql', 
    '.\Queries\Clients-Inventory-Processors.sql', 
    '.\Queries\Clients-Inventory-TopUsers.sql', 
    '.\Queries\Clients-Inventory-TPMStatus.sql', 
    '.\Queries\Clients-Inventory-WuVersions.sql', 
    '.\Queries\Site-DPServers.sql', 
    '.\Queries\Site-DPStatus.sql', 
    '.\Queries\Software-Deployments-Summary.sql', 
    '.\Queries\Software-OfficeProducts-Detailed.sql', 
    '.\Queries\Software-OfficeProducts-PlatformVersion.sql', 
    '.\Queries\Software-OfficeProducts-Summary.sql', 
    '.\Queries\Software-OfficeProducts-Versions.sql', 
    '.\Queries\Software-OneDrive-Detailed.sql', 
    '.\Queries\Software-OneDrive-Totals.sql', 
    '.\Queries\Software-Products-Top100installs.sql'
)

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('cmcustomreports','configmgr','sccm','systemcenter','sql','report')

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/Skatterbrainz/CmCustomReports'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = @'
1.0.0 - DS - Initial release
'@

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

