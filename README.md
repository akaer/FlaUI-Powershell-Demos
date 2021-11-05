# FlaUI Powershell Demos

Here you will find some automation samples for using [FlaUI](https://github.com/FlaUI/FlaUI) within Microsoft [Powershell](https://github.com/PowerShell/PowerShell). For the sake of clarity the [Pester framework](https://github.com/pester/Pester) is used.

## Requirements

* Windows PowerShell 5.0+
* Installed [Pester Powershell module](https://github.com/pester/Pester#installation)

## Hints

The scripts are tests with Windows 10 Version 1809 (OS Build 17763.2237).

    $PSVersionTable

    Name                           Value
    ----                           -----
    PSVersion                      5.1.17763.2183
    PSEdition                      Desktop
    PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0...}
    BuildVersion                   10.0.17763.2183
    CLRVersion                     4.0.30319.42000
    WSManStackVersion              3.0
    PSRemotingProtocolVersion      2.3
    SerializationVersion           1.1.0.1



## Contribution

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **highly appreciated**.

1. Fork [this project](https://github.com/akaer/FlaUI-Powershell-Demos)
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Run Pester tests

Tests can be started by the command: ```Invoke-Pester -Output Detailed``` or by pressing F5 within VSCode or Powershell ISE.

## License

Distributed under MIT License. See [LICENSE](LICENSE.md) for more information.
