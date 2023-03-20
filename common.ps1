function Add-FileToAppDomain {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, HelpMessage = 'The base path to load files from.')]
        [ValidateNotNull()]
        [string] $BasePath,
        [parameter(Mandatory = $true, HelpMessage = 'The file to load into the AppDomain.')]
        [ValidateNotNull()]
        [string] $File
    )

    if (-not (Test-Path "$BasePath" -PathType Container))
    {
        Throw "[!] Can't find or access folder ${BasePath}."
    }

    $FileToLoad = Join-Path "${BasePath}" "$File"

    if (-not (Test-Path "$FileToLoad" -PathType Leaf))
    {
        Throw "[!] Can't find or access file ${FileToLoad}."
    }

    if ( -Not ([appdomain]::currentdomain.getassemblies() |Where-Object Location -Like ${FileToLoad})) {
        try {
            [System.Reflection.Assembly]::LoadFrom($FileToLoad) | Out-Null
            $clientVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($FileToLoad).ProductVersion
            Write-Debug "[+] File ${File} loaded with version ${clientVersion} from ${BasePath}."
        } catch {
            Resolve-Exception -ExceptionObject $PSitem
        }
    }
}

function Add-NuGetDependencies {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, HelpMessage = 'The Nuget packages to load.')]
        [Hashtable] $NugetPackages
    )

    $CurrentFileName = Split-Path $PSScriptRoot -Leaf
    $memstream = [IO.MemoryStream]::new([byte[]][char[]]$CurrentFileName)
    $CurrentFileNameHash = (Get-FileHash -InputStream $memstream -Algorithm SHA1).Hash

    # Get a unique temporary directory to store all the NuGet packages we need later
    $TempWorkDir = Join-Path "$($env:TEMP)" "$CurrentFileNameHash"

    if (-not (Test-Path "$TempWorkDir" -PathType Container))
    {
        New-Item -Path "$($env:TEMP)" -Name "$CurrentFileNameHash" -ItemType Directory
    }

    foreach ($dep in $NugetPackages.Keys) {
        $version = $NugetPackages[$dep]
        $destinationPath = Join-Path "$TempWorkDir" "${dep}.${version}"
        if (-not (Test-Path "$destinationPath" -PathType Container))
        {
            Install-Package -Name $dep -RequiredVersion $version -Destination "$TempWorkDir" -SkipDependencies -ProviderName NuGet -Source nuget.org -Force
            Write-Information "[+] Install package ${dep} with version ${version} into folder ${TempWorkDir}"
        }

        # Prioritise version 4.8 over 4.5
        $BasePath = Join-Path (Join-Path "$destinationPath" "lib") "net48"
        if (-not (Test-Path "$BasePath" -PathType Container)) {
            $BasePath = Join-Path (Join-Path "$destinationPath" "lib") "net45"
        }

        Add-FileToAppDomain -BasePath $BasePath -File "${dep}.dll"
    }
}

function Get-AutomationButton {
    param (
        [parameter(Mandatory = $true, HelpMessage = 'The base automation element')]
        [FlaUI.Core.AutomationElements.AutomationElement] $BaseAutomationElement,
        [parameter(Mandatory = $true, HelpMessage = 'The name of the button to get')]
        [string] $Name
    )

    return $BaseAutomationElement.FindFirstDescendant($btnCondition.And($cf.ByName($Name)))
}

function Get-AutomationTextBox {
    param (
        [parameter(Mandatory = $true, HelpMessage = 'The base automation element')]
        [FlaUI.Core.AutomationElements.AutomationElement] $BaseAutomationElement,
        [parameter(Mandatory = $true, HelpMessage = 'The name of the textbox to get')]
        [string] $Name
    )

    $fae = $mw.FindFirstDescendant($cf.ByName($Name)).FrameworkAutomationElement
    return [FlaUI.Core.AutomationElements.TextBox]::new($fae)
}