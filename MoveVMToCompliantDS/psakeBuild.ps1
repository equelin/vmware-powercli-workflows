Include -fileNamePathToInclude "$PSScriptRoot\Functions\Move-ToCompliantDS.ps1"

properties {
    # Importing config file
    . "$PSScriptRoot\Configs\Config.ps1"
}

task default -depends Connection, Analyze, Test, Disconnection

task Connection {
    # Check for already open session to desired vCenter server
    If ($cfg.vcenter.vc -notin $global:DefaultVIServers.Name) {
        Try {
            # Attempt connection to vCenter, prompting for credentials
            Write-Verbose "No active connection found to configured vCenter '$($cfg.vcenter.vc)'. Connecting"
            Connect-VIServer -Server $cfg.vcenter.vc -ErrorAction Stop
        } Catch {
            # If unable to connect, stop
            Write-Error -Message 'Error while connecting to vCenter. Build cannot continue!' 
        }
    } 
}

task Analyze -depends Connection {
    $saResults = Invoke-ScriptAnalyzer -Path . -ExcludeRule PSAvoidGlobalVars,PSAvoidUsingWriteHost -Severity @('Error', 'Warning') -Recurse -Verbose:$false
    if ($saResults) {
        $saResults | Format-Table  
        Write-Error -Message 'One or more Script Analyzer errors/warnings where found. Build cannot continue!'        
    }
}

task Test -depends Connection {
    $testResults = Invoke-Pester -Path $PSScriptRoot -PassThru
    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'
    }
}

task Remediate -depends Connection, Analyze, Test {
    Try {
        Get-Datacenter $cfg.scope.datacenter | Get-Cluster $cfg.Scope.cluster | Get-VM $cfg.scope.vm | Move-ToCompliantDS #-Confirm:$false
    }
    Catch {
        write-Error -Message "Build failed!"
        Write-Error -Message $_
    }
}

task Disconnection -depends Connection {
    Try {
        Disconnect-VIServer $cfg.vcenter.vc -Confirm:$false
    }
    Catch {
        Write-Error -Message 'Error while disconnecting from vCenter'
    }
}

task All -depends Connection, Analyze, Test, Remediate, Disconnection {
    return $True
}