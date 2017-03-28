# vmware-powercli-workflows

This repository purpose is to gather multiple scripts to help automating VMware vSphere infrastructures management. 

Most of the automation is build around VMware Tags. For example VMs could be added or removed from DRS groups depending of there tags. The same goes for SPBM management.

![](./Img/TagsAutomatedMgmt.gif)

List of the available scripts:
- [TagsAutomatedMgmt](#tagsautomatedmgmt)
- [DRSGroupsAutomatedMgmt](#drsgroupsautomatedmgmt)
- [SPBMFromTag](#spbmfromtag)
- [MoveVMToCompliantDS](#movevmtocompliantds)

Each sub folder is an independant script. All of them are designed with the same pattern that has been inspired by [Brandon Olin](https://github.com/devblackops) blog post https://devblackops.io/building-a-simple-release-pipeline-in-powershell-using-psake-pester-and-psdeploy/.

# Requirements

- Powershell (tested with version 5)
- Powercli (tested with version 6.5) 
- Powershell modules Pester, PSake and PSScriptAnalyzer

# How to use the scripts

1. Download the repository from GitHub
2. [Unblock the archive](https://dmitrysotnikov.wordpress.com/2010/12/30/unblocking-powergui-add-ons-and-powershell-modules/)
3. Extract the archive wherever you want
4. In each sub folder:
   1. Modify .\Configs\Config.ps1 according to your infrastructure
   2. If needed, modify .\Data\*.csv files
   3. Run the script

```Powershell
# prechecks tests only
> .\TagsAutomatedMgmt\Build.ps1

# run the full script
> .\TagsAutomatedMgmt\Build.ps1 -Task All
```

# Scripts purposes and requirements
## TagsAutomatedMgmt
### Purpose

This script will manage VM's tags affectation from a CSV file. It's useful when some mandatory tags have to be assign to VMs.
The CSV file is the source of truth for those specifics tags. Any manual modification of this tags will be overwritten by the script.

### Configuration files

Before using this script, you will need to modify those files:
- .\Configs\Config.ps1
- .\Data\Tags.csv

### Requirements

- Categories and tags have to be created before running the script
- All VM needs to be listed in the CSV file otherwise precheck test will throw an error.

### Config.ps1 highlights

```Powershell
# Mandatory tag's categories that have to be assign to VMs
# Those categories have to be created before running the script
$cfg.category = @(
    'Datacenter',
    'Replication'
)
```

## DRSGroupsAutomatedMgmt
### Purpose

This script will manage DRS VM's groups. VMs are added or removed depending on the tags associated to it.

### Configuration files

Before using this script, you will need to modify those files:
- .\Configs\Config.ps1

### Requirements

- Categories have to be created before running the script
- DRS VM groups have to be created before running the script.

### Known limitations

- VM Groups should contains at least two VMs otherwise the script will throw an error if it has to removed a VM from a group with only one VM.

### Config.ps1 highlights

```Powershell
# Category where to look at tags associated to DRS VM Group
$cfg.TagCategory = 'Datacenter'

# Tag associated to DRS VM group
# 1 Tag = 1 DRS VM group
$cfg.TagDRSGroup = @(
    @{'DC01' = 'VM-DC01'},
    @{'DC02' = 'VM-DC02'}
)
```

## SPBMFromTag
### Purpose

This script will manage Storage Policy affectation to VMs based on tags. The script will compare tags assign to the VM with tags used in SPBM rule-sets. 

### Configuration files

Before using this script, you will need to modify those files:
- .\Configs\Config.ps1

### Requirements

- SPBM should have been created first before running the script.
- SPBM Rule-Set should use the same tags than the VMs

### Config.ps1 highlights

```Powershell
# Tag categories used by the Storage Policies and VMs
$cfg.TagCategory = @(
    'Datacenter',
    'Replication'
)
```

## MoveVMToCompliantDS
### Purpose

This script will invoke a Storage vMotion to move VMs to a compliant datastore. If multiple datastore are compliants, the one with higher free space is selected.

### Configuration files

Before using this script, you will need to modify those files:
- .\Configs\Config.ps1

### Requirements

- SPBM should have been created first before running the script.

# Author

**Erwan Quélin**
- <https://github.com/equelin>
- <https://twitter.com/erwanquelin>

# Special Thanks

- [Brandon Olin](https://github.com/devblackops) for his [blog post](https://devblackops.io/building-a-simple-release-pipeline-in-powershell-using-psake-pester-and-psdeploy/) about Powershell release pipeline.
- [Luc Deckens](https://github.com/lucdekens) and [Matt Boren](https://github.com/mtboren) for the [DRSRule](https://github.com/PowerCLIGoodies/DRSRule) module used in GRSGroupsAutomatedMgmt script.