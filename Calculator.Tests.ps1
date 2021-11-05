Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$DebugPreference = 'SilentlyContinue'
$InformationPreference = 'Continue'

Describe "Calculator" {

    BeforeAll {

        . "$PSScriptRoot\common.ps1"

        $deps = @{
            'Interop.UIAutomationClient' = '10.19041.0';
            'FlaUI.Core' = '3.2.0';
            'FlaUI.UIA3' =  '3.2.0'
        }

        Add-NuGetDependencies -NugetPackages $deps

        $uia = New-Object FlaUI.UIA3.UIA3Automation
        $cf = $uia.ConditionFactory
        $btnCondition = $cf.ByControlType('Button')

        $aut = [Diagnostics.Process]::Start('calc')
        $aut.WaitForInputIdle(5000) | Out-Null
        Start-Sleep -s 2

        # Retrieve the correct PID as this changes during application startup
        $autPid = ((Get-Process).where{ $_.MainWindowTitle -eq 'Calculator' })[0].Id

        $desktop = $uia.GetDesktop()
        $mw = $desktop.FindFirstDescendant($cf.ByProcessId($autPid))

    }

    Context 'Can calculate' {

        It 'Solves 5 + 9' {

            (Get-AutomationButton -BaseAutomationElement $mw -Name '5').Click()
            (Get-AutomationButton -BaseAutomationElement $mw -Name 'Add').Click()
            (Get-AutomationButton -BaseAutomationElement $mw -Name '9').Click()
            (Get-AutomationButton -BaseAutomationElement $mw -Name 'Equals').Click()

            $result = (Get-AutomationTextBox -BaseAutomationElement $mw -Name 'Result').Text.Trim()
            $result | Should -Be 14

        }

        It 'Solves 14 - 9' {

            (Get-AutomationButton -BaseAutomationElement $mw -Name '1').Click()
            (Get-AutomationButton -BaseAutomationElement $mw -Name '4').Click()
            (Get-AutomationButton -BaseAutomationElement $mw -Name 'Subtract').Click()
            (Get-AutomationButton -BaseAutomationElement $mw -Name '9').Click()
            (Get-AutomationButton -BaseAutomationElement $mw -Name 'Equals').Click()

            $result = (Get-AutomationTextBox -BaseAutomationElement $mw -Name 'Result').Text.Trim()
            $result | Should -Be 5

        }

        It 'Solves 5 * 9' {

            (Get-AutomationButton -BaseAutomationElement $mw -Name '5').Click()
            (Get-AutomationButton -BaseAutomationElement $mw -Name 'Multiply').Click()
            (Get-AutomationButton -BaseAutomationElement $mw -Name '9').Click()
            (Get-AutomationButton -BaseAutomationElement $mw -Name 'Equals').Click()

            $result = (Get-AutomationTextBox -BaseAutomationElement $mw -Name 'Result').Text.Trim()
            $result | Should -Be 45

        }

        It 'Solves 45 / 9' {

            (Get-AutomationButton -BaseAutomationElement $mw -Name '4').Click()
            (Get-AutomationButton -BaseAutomationElement $mw -Name '5').Click()
            (Get-AutomationButton -BaseAutomationElement $mw -Name 'Divide').Click()
            (Get-AutomationButton -BaseAutomationElement $mw -Name '9').Click()
            (Get-AutomationButton -BaseAutomationElement $mw -Name 'Equals').Click()

            $result = (Get-AutomationTextBox -BaseAutomationElement $mw -Name 'Result').Text.Trim()
            $result | Should -Be 5

        }

    }

    AfterAll {
        $uia.Dispose()
        $aut.Dispose()
        Stop-Process -Force -Id $autPid
    }
}