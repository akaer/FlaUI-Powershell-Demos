function Add-NuGetDependencies {
    param (
        [parameter(Mandatory = $true, HelpMessage = 'The Nuget packages to load')]
        [Hashtable] $NugetPackages
    )

    Begin {
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
            }

            $FileToLoad = Join-Path (Join-Path (Join-Path "$destinationPath" "lib") "net45") "${dep}.dll"
            if (-not (Test-Path "$FileToLoad" -PathType Leaf))
            {
                Throw -Message "Can't find or open file ${FileToLoad}."
            }
            [System.Reflection.Assembly]::LoadFrom($FileToLoad) | Out-Null
        }
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