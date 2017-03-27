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

# Mandatory tag's categories that have to be assign to VMs
$cfg.category = @(
    'Datacenter',
    'Replication'
)

# CSV File name and folder
$cfg.data = '.\Data\Tags.csv'