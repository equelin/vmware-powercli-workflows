
# Importing config file
. "$PSScriptRoot\..\Configs\Config.ps1"

$VMS = Get-Datacenter $cfg.scope.datacenter | Get-Cluster $cfg.Scope.cluster | Get-VM $cfg.scope.vm

Describe 'Testing vSphere Infrastructure' {

    Context 'VMs' {

        Foreach ($VM in $VMS) {
            it "VM $VM is associated to a Storage Policy" {
                ($VM | Get-SpbmEntityConfiguration).Count | Should Be 1
            }  
        }
    }
}