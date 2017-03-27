Function Update-VMTag {
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

    Begin {
        # Importing data from CSV
        $CSV = Import-CSV -Delimiter ',' -Path $cfg.data
    }

    Process {

        Foreach ($V in $VM) {
            
            # Determine input and convert to UniversalVirtualMachineImpl object
            Switch ($V.GetType().Name) {
                "string" {$V = Get-VM $V -Server $Server -ErrorAction SilentlyContinue}
                "UniversalVirtualMachineImpl" {$V = $V}
            }

            # Test if VM exists
            If ($V) {

                Write-Verbose "[$($Server.Name)] Processing VM: $($V.Name)"
                Write-Host "Processing VM: $($V.Name)" -ForegroundColor Blue

                Foreach ($cat in $cfg.category) {

                    Write-Verbose "[$($Server.Name)] Processing category: $cat"
                    Write-Host "`tProcessing category: $cat" -ForegroundColor Blue

                    # Get the tag actually assigned to the VM
                    $TagAssignment = Get-TagAssignment -Server $Server -Entity $V -Category $Cat -ErrorAction SilentlyContinue

                    # Get the target tag from the CSV
                    $CSVTarget = $CSV | Where-Object {$_.VM -eq $V.Name}
                    $TagTarget = Get-Tag -Server $Server -Category $Cat -Name $CSVTarget.$Cat

                    # Test if the VM as a tag assigned to. If not remediate.
                    If (-not $TagAssignment) {
                        Write-Verbose "[$($Server.Name)][$($V.Name)] VM has no tag from category $Cat, Assigning Tag $($TagTarget.Name)"
                        Write-Host "`t`tVM has no tag from category $Cat, Assigning Tag $($TagTarget.Name)" -ForegroundColor Blue
                        If ($pscmdlet.ShouldProcess($V,"Assigning tag $($TagTarget.Name)")) {
                            New-TagAssignment -Server $Server -Entity $V -Tag $TagTarget 
                        }
                    } else {
                        # Test if the tag assigned to the VM is the right one. If not, remediate.
                        If ($TagAssignment.Tag -ne $TagTarget) {
                            Write-Verbose "[$($Server.Name)][$($V.Name)] Not the right Tag. Assigning Tag $($TagTarget.Name)"
                            Write-Host "`t`tNot the right Tag. Assigning Tag $($TagTarget.Name)" -ForegroundColor Blue
                            If ($pscmdlet.ShouldProcess($V,"Modifying tag assignment from $($TagAssignment.Tag.Name) to $($TagTarget.Name)")) {
                                Remove-TagAssignment -TagAssignment $TagAssignment -Confirm:$false 
                                New-TagAssignment -Server $Server -Entity $V -Tag $TagTarget 
                            }
                        } else {
                            Write-Verbose "[$($Server.Name)][$($V.Name)] Nothing to do..."
                            Write-Host "`t`tNothing to do..." -ForegroundColor Blue
                        }
                    }

                    Write-Host "`r"
                }

                Write-Host "`r"
            }
        }
    }
}