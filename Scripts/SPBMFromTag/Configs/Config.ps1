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

# Tag categories used by the Storage Policies
$cfg.TagCategory = @(
    'Datacenter',
    'Replication'
)