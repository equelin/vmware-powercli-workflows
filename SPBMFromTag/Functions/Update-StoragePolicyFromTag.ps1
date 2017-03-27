#requires -modules VMware.VimAutomation.Core,VMware.VimAutomation.Storage

Function Update-StoragePolicyFromTag {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact="High")]
    param (
        # VM Name or Object
        [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,HelpMessage='Result object from Get-StoragePolicyFromTag')]
        $Object,

        # vCenter Object
        [Parameter(Mandatory=$False)]
        [VMware.VimAutomation.Types.VIServer[]]$Server = $global:DefaultVIServers
    )

    Process {
        Foreach ($VM in $Object) {

            Write-Host "Processing VM: $($VM.VM.Name)" -ForegroundColor Blue

            # remediate VM storage policy
            Write-Verbose -Message "[$($VM.VM.Name)] VM Current SP: $($VM.VMCurrentPolicy), SP Target: $($VM.Target.Name)"

            If ($VM.VMCurrentPolicy -ne $VM.Target.Name) {
                Write-Verbose -Message "[$($VM.VM.Name)] Need for remediation"
                Write-Host "`tVM SPBM need to be changed, set SPBM $($VM.Target)" -ForegroundColor Blue
                # Support for -Whatif and -Confirm
                If ($pscmdlet.ShouldProcess($VM.VM.Name,"Set storage policy")) {
                    $VM.VM | Set-SpbmEntityConfiguration -StoragePolicy $VM.Target
                }
            } else {
                Write-Verbose -Message "[$($VM.VM.Name)] No need for remediation"
                Write-Host "`tVM SPBM does not need to be changed" -ForegroundColor Blue
            }

            Foreach ($HardDisk in $VM.DisksCurrentPolicy) {

                Write-Verbose -Message "[$($VM.VM.Name)] HardDisk: $($HardDisk.HardDisk.Name), Hard Disk Current SP: $($HardDisk.Policy), SP Target: $($VM.Target.Name)"

                If ($HardDisk.Policy -ne $VM.Target.Name) {
                    Write-Verbose -Message "[$($VM.VM.Name)] Need for remediation"
                    Write-Host "`tVM hardisk $($HardDisk.HardDisk.Name) SPBM need to be changed, set SPBM $($VM.Target)" -ForegroundColor Blue
                    # Support for -Whatif and -Confirm
                    If ($pscmdlet.ShouldProcess($HardDisk.HardDisk.Name,"Set storage policy")) {
                        $HardDisk.HardDisk | Set-SpbmEntityConfiguration -StoragePolicy $VM.Target
                    }
                } else {
                    Write-Verbose -Message "[$($VM.VM.Name)] No need for remediation"
                    Write-Host "`tVM hardisk $($HardDisk.HardDisk.Name) SPBM does not need to be changed" -ForegroundColor Blue
                }
            }
            Write-Host "`n"
        }
    }
}
