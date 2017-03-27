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

# Mandatory tag's category thas has to be assign to VMs
$cfg.category = @(
    'Datacenter',
    'Replication'
)

# CSV File name and folder
$cfg.data = '.\Data\Tags.csv'