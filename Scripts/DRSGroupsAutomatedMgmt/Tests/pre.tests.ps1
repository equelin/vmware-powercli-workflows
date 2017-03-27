# Importing config file
. "$PSScriptRoot\..\Configs\Config.ps1"

$Clusters = Get-Datacenter $cfg.scope.datacenter | Get-Cluster $cfg.Scope.cluster
$VMS = Get-Datacenter $cfg.scope.datacenter | Get-Cluster $cfg.Scope.cluster | Get-VM $cfg.scope.vm

Describe 'Testing vSphere Infrastructure' {
    Context 'Tags' {

        Foreach ($Category in $cfg.TagCategory) {

            it "Category $Category exists" {
                (Get-TagCategory -Name $Category).Count | Should Be 1
            }

            it "Category $Category has a single Cardinality " {
                (Get-TagCategory -Name $Category).Cardinality | Should Be 'Single'
            }
        }        
    }

    Context 'VMs' {

        Foreach ($VM in $VMS) {
            it "VM $VM is associated with a tag from all mandatory categories" {
                ($VM | Get-TagAssignment -Category $cfg.TagCategory).Count | Should Be ($cfg.TagCategory.Count)
            }  
        }
    }

    Context 'DRSVMGroups' {

        Foreach ($DRSVMGroup in $cfg.TagDRSGroup.Values) {
            it "Group $($DRSVMGroup) exists" {
                (Get-DrsVMGroup -Cluster (Get-Cluster $Clusters) -Name $DRSVMGroup).Name | Should Be $DRSVMGroup
            }  
        }
    }    
}