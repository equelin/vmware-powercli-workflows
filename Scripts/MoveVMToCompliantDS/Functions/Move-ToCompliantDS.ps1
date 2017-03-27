Function Move-ToCompliantDS {
    [CmdletBinding()]
    param (
        # VM Name or Object
        [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,HelpMessage='VM Name or Object')]
        $VM = (Get-VM -Server $Server),

        [Parameter(Mandatory=$False)]
        [Uint32]$ReservedCapacityPercent = 10,

        # If $True don't move VM on a faulty datastore
        [Parameter(Mandatory=$False)]
        [bool]$SkipFaultedDS = $True,

        # vCenter Object
        [Parameter(Mandatory=$False)]
        [VMware.VimAutomation.Types.VIServer[]]$Server = $global:DefaultVIServers
    )

    Process {
        Foreach ($V in $VM) {

            Write-Host "Processing VM: $($VM.VM.Name)" -ForegroundColor Blue
            
            # Determine input and convert to UniversalVirtualMachineImpl object
            Switch ($V.GetType().Name) {
                "string" {$V = Get-VM $V -Server $Server -ErrorAction SilentlyContinue}
                "UniversalVirtualMachineImpl" {$V = $V}
            }

            # Test if VM exists
            If ($V) {

                # Get SPBM associated to VM
                $SPBM = ($V | Get-SpbmEntityConfiguration)

                # Test if SPBM is compliant, if $False, Move VM to a compliant datastore
                If ($SPBM.ComplianceStatus -eq 'nonCompliant') {

                    $TargetDS = $SPBM.StoragePolicy | Get-SpbmCompatibleStorage 

                    If ($SkipFaultedDS) {
                        $TargetDS = $TargetDS | Where-Object {($_.ExtensionData.TriggeredAlarmState).Count -eq 0} | Sort-Object -Descending -Property FreeSpaceGB | Select-Object -First 1
                    } else {
                        $TargetDS = $TargetDS | Sort-Object -Descending -Property FreeSpaceGB | Select-Object -First 1
                    }

                    $ReservedCapacityGB = $TargetDS.CapacityGB * ( 1 / $ReservedCapacityPercent)

                    If (($TargetDS.FreeSpaceGB - $V.ProvisionedSpaceGB) -gt $ReservedCapacityGB) {

                        Write-Verbose "[$V] [$($TargetDS.Name)] Moving VM to a compliant datastore"
                        Write-Host "`tMoving VM to a compliant datastore $($TargetDS.Name)" -ForegroundColor Blue
                        $V | Move-VM -Datastore $TargetDS
                    } else {
                        Write-Verbose "[$V] [$($TargetDS.Name)] Not enough free space on the datastore"
                        Write-Host "`tNot enough free space on datastore $($TargetDS.Name)" -ForegroundColor Blue
                    }

                } else {
                    Write-Verbose "[$V] VM already on a compliant datastore"
                    Write-Host "`tVM already on a compliant datastore" -ForegroundColor Blue
                }
            }
        }
    }
}