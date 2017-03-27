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

# Category
$cfg.TagCategory = 'Datacenter'

# Tag associated to DRS VM group
$cfg.TagDRSGroup = @(
    @{'DC01' = 'VM-DC01'},
    @{'DC02' = 'VM-DC02'}
)