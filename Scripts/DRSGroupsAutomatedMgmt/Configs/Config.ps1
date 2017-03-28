# Initializing empty array
$cfg = @{}

# FQDN / IP of the vCenter
$cfg.vcenter = @{
    vc = 'vcenter01.example.com'
}

# Scope
$cfg.scope = @{
    datacenter = 'vLAB'
    cluster    = 'vCLUSTER'
    host       = '*'
    vm         = '*'
}

# Category where to look at tags associated to DRS VM Group
$cfg.TagCategory = 'Datacenter'

# Tag associated to DRS VM group
# 1 Tag = 1 DRS VM group
$cfg.TagDRSGroup = @(
    @{'DC01' = 'VM-DC01'},
    @{'DC02' = 'VM-DC02'}
)