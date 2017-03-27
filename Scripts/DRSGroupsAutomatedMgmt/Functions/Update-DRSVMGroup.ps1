Function Update-DRSVMGroup {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact="High")]
    param (
        # VM Name or Object
        [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,HelpMessage='VM Name or Object')]
        $VM = (Get-VM -Server $Server),

        # Config 
        [Parameter(Mandatory=$True)]
        $Cfg,

        # vCenter Object
        [Parameter(Mandatory=$False)]
        [VMware.VimAutomation.Types.VIServer[]]$Server = $global:DefaultVIServers
    )

    Process {

        Foreach ($V in $VM) {
            
            # Determine input and convert to UniversalVirtualMachineImpl object
            Switch ($V.GetType().Name) {
                "string" {$V = Get-VM $V -Server $Server -ErrorAction SilentlyContinue}
                "UniversalVirtualMachineImpl" {$V = $V}
            }

            # Test if VM exists
            If ($V) {

                Write-Verbose "[$($Server.Name)]-[$($VM.Name)] Processing VM: $($V.Name)"
                Write-Host "Processing VM: $($V.Name)" -ForegroundColor Blue

                $Cluster = Get-Cluster -VM $V

                # Get the tag actually assigned to the VM
                $TagAssignment = (Get-TagAssignment -Server $Server -Entity $V -Category $cfg.TagCategory -ErrorAction SilentlyContinue).Tag.Name

                $DRSVMGroupTarget = $cfg.TagDRSGroup.$TagAssignment

                Write-Verbose "[$($Server.Name)]-[$($VM.Name)] Tag assignement: $TagAssignment, DRS VM group target: $DRSVMGroupTarget"

                If ($TagAssignment -and $DRSVMGroupTarget) {

                    If ($DRSVMGroupAssignement = Get-DrsVMGroup -Cluster $Cluster -ErrorAction SilentlyContinue | Where-Object {$_.VM -contains $V.Name}) {
                        Write-Verbose "[$($Server.Name)]-[$($VM.Name)] VM is assigned to group $($DRSVMGroupAssignement.Name)"

                        If (($DRSVMGroupAssignement.Count -eq 1) -and ($DRSVMGroupAssignement.Name -eq $DRSVMGroupTarget)) {
                            Write-Verbose "[$($Server.Name)]-[$($VM.Name)] Nothing to do..."
                            Write-Host "`tNothing to do..." -ForegroundColor Blue

                        } else {

                            Write-Verbose "[$($Server.Name)]-[$($VM.Name)] Need to change group"
                            Write-Host "`tNeed to change group" -ForegroundColor Blue

                            Foreach ($DRSVMGroup in $DRSVMGroupAssignement) {
                                $ListVM =$DRSVMGroup.VM | Where-Object {$_ -ne $V.Name}
                                Write-Host "`t`tRemove VM from group $($DRSVMGroup.Name)" -ForegroundColor Blue

                                If ($pscmdlet.ShouldProcess($V.Name,"Remove VM from group $($DRSVMGroup.Name)")) {
                                    $DRSVMGroup | Set-DrsVMGroup -VM $ListVM
                                }
                            }
                            
                            $ListVM =$DRSVMGroupAssignement.VM | Where-Object {$_ -ne $V.Name}
                            Write-Host "`t`tAssign VM to group $DRSVMGroupTarget" -ForegroundColor Blue

                            If ($pscmdlet.ShouldProcess($V.Name,"Assign VM to group $DRSVMGroupTarget")) {
                                Set-DrsVMGroup -Name $DRSVMGroupTarget -Cluster $Cluster -VM $V -Append
                            }                        
                        }

                    } else {
                        Write-Verbose "[$($Server.Name)]-[$($VM.Name)] Need to assigne the VM to the DRS VM group $DRSVMGroupTarget"
                        Write-Host "`tNeed to assigne the VM to the DRS VM group $DRSVMGroupTarget" -ForegroundColor Blue
                        Write-Host "`t`tAssign VM to group $DRSVMGroupTarget" -ForegroundColor Blue

                        If ($pscmdlet.ShouldProcess($V.Name,"Assign VM to group $DRSVMGroupTarget")) {
                            Set-DrsVMGroup -Name $DRSVMGroupTarget -Cluster $Cluster -VM $V -Append
                        }
                    }
                } else {
                    Write-Warning -Message "[$($Server.Name)]-[$($VM.Name)] No valid tag assignement... Skip VM."
                }
            }
        }
    }
}