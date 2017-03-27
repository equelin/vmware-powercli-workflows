
# Importing config file
. "$PSScriptRoot\..\Configs\Config.ps1"

$Category = $cfg.category
$CSV = Import-CSV -Delimiter ',' -Path $cfg.data
$VM = Get-Datacenter $cfg.scope.datacenter | Get-Cluster $cfg.scope.cluster | Get-VM

Describe 'Testing vSphere Infrastructure' {

    Context 'Categories' {

        Foreach ($cat in $Category) {
            it "Category $cat exists" {
                (Get-TagCategory -Name $cat).count | Should Be 1
            } 
            it "Category $cat has tags associated" {
                (Get-Tag -Category $cat).count | Should Not Be 0
            }   
        }
    }
}

Describe 'Testing Datas from CSV file' {

    Context 'Virtual Machines' {

        Foreach ($V in $VM) {
            it "CSV file contains virtual machines $($V.Name)" {
                ($CSV.VM -Contains $V.Name) | Should Be $True
            }
        }  
    }

    Context 'Categories' {

        Foreach ($cat in $Category) {
            it "Category $cat is present in the CSV file" {
                $CSV | Get-Member | Where-Object {$_.Name -eq $cat}
            }

            $Tags = Get-Tag -Category $cat

            Foreach ($VM in $CSV) {
                It "$($VM.VM) is associated to a valid tag from category $cat" {
                    ($Tags.Name -contains $VM.$cat) | Should Be $True
                }  
            }   
        }
    }
}



