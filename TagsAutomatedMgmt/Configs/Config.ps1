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

$cfg.category = @(
    'Datacenter',
    'Replication'
)

$cfg.data = '.\Data\Tags.csv'