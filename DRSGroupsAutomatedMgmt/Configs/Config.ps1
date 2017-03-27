$cfg = @{}

$cfg.vcenter = @{
    vc = 'vcenter01.okcomputer.lab'
}

$cfg.scope = @{
    datacenter = 'vLAB'
    cluster    = 'vCLUSTER'
    host       = '*'
    vm         = '*'
}

$cfg.TagCategory = 'Datacenter'

$cfg.TagDRSGroup = @(
    @{'DC01' = 'VM-DC01'},
    @{'DC02' = 'VM-DC02'}
)