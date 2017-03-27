#requires -modules VMware.VimAutomation.Core,VMware.VimAutomation.Storage

Function Get-StoragePolicyFromTag {
    [CmdletBinding()]
    param (
        # VM Name or Object
        [Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,HelpMessage='VM Name or Object')]
        $VM = (Get-VM -Server $Server),

        # Category
        [Parameter(Mandatory=$True)]
        [String[]]$TagCategory,

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

                # Test if the VM as a tag assigned from the mandatory category
                If ($V | Get-TagAssignment -Category $TagCategory) {
                    # get VM current storage policy
                    $VMCurrentPolicy = ($V | Get-SpbmEntityConfiguration).StoragePolicy.Name

                    # get current storage policy for all VM hardisks 
                    $DisksCurrentPolicy = @()
                    $V | Get-HardDisk | ForEach-Object {

                        $object = New-Object PSObject
                        Add-Member -InputObject $object -MemberType NoteProperty -Name HardDisk -Value $_
                        Add-Member -InputObject $object -MemberType NoteProperty -Name Policy -Value (($_ | Get-SpbmEntityConfiguration).StoragePolicy.Name)

                        $DisksCurrentPolicy += $object
                    }

                    # get target policy based on VM tag
                    $Target = Get-SpbmStoragePolicy -Server $Server | Where-Object { [string]($_.AnyOfRuleSets.AllOfRules.AnyOfTags.Name | Sort-Object) -eq [string]((($V | Get-TagAssignment -Category $TagCategory).Tag.Name) | Sort-Object)}

                    # build object
                    $object = New-Object PSObject
                    Add-Member -InputObject $object -MemberType NoteProperty -Name VM -Value $V
                    Add-Member -InputObject $object -MemberType NoteProperty -Name VMCurrentPolicy -Value $VMCurrentPolicy
                    Add-Member -InputObject $object -MemberType NoteProperty -Name DisksCurrentPolicy -Value $DisksCurrentPolicy
                    Add-Member -InputObject $object -MemberType NoteProperty -Name Target -Value $Target

                    # return result
                    $object
                } else {
                    Write-Warning -Message "[$V] VM has no tag assignement from category $TagCategory. Skip it"
                }
            } else {
                Write-Warning -Message "[$V] Can't find VM"
            }
        }
    }
}
