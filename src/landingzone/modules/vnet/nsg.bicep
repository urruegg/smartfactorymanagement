param location string = resourceGroup().location
param nsgNamePrefix string
param allow_ssh_and_rdp_via_public_ip bool = true

var default_rules = [
  // Inbound Rules
  {
    name: 'allow_http_inbound'
    properties: {
      description: 'Allow ssh from current local ip'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '80'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 315
      direction: 'Inbound'
    }
  }
  {
    name: 'allow_https_inbound'
    properties: {
      description: 'Allow ssh from current local ip'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 415
      direction: 'Inbound'
    }
  }
  {
    name: 'allow_vnet_inbound'
    properties: {
      description: 'allow all traffic between subnets'
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 3500
      direction: 'Inbound'
    }
  }
  {
    name: 'deny_catchall_inbound'
    properties: {
      description: 'Deny all inbound traffic'
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Deny'
      priority: 4000
      direction: 'Inbound'
    }
  }
  // Outbound Rules
  {
    name: 'allow_http_outbound'
    properties: {
      description: 'Allow ssh from current local ip'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '80'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 315
      direction: 'Outbound'
    }
  }
  {
    name: 'allow_https_outbound'
    properties: {
      description: 'Allow ssh from current local ip'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 415
      direction: 'Outbound'
    }
  }
  {
    name: 'allow_vnet_outbound'
    properties: {
      description: 'allow all traffic between subnets'
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 3500
      direction: 'Outbound'
    }
  }
  {
    name: 'deny_catchall_outbound'
    properties: {
      description: 'Deny all outbound traffic'
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: '*'
      access: 'Deny'
      priority: 4000
      direction: 'Outbound'
    }
  }
]

// Conditionally add ssh and rdp to be able to deactivate afterwards
var nsg_rules = concat(default_rules, allow_ssh_and_rdp_via_public_ip ? [
  // Inbound Rules
  {
    name: 'allow_ssh_inbound'
    properties: {
      description: 'Allow ssh from current local ip'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '22'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 115
      direction: 'Inbound'
    }
  }
  {
    name: 'allow_rdp_inbound'
    properties: {
      description: 'Allow ssh from current local ip'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '3389'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 215
      direction: 'Inbound'
    }
  }
  // Outbound Rules
  {
    name: 'allow_ssh_outbound'
    properties: {
      description: 'Allow ssh from current local ip'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '22'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 115
      direction: 'Outbound'
    }
  }
  {
    name: 'allow_rdp_outbound'
    properties: {
      description: 'Allow ssh from current local ip'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '3389'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 215
      direction: 'Outbound'
    }
  }
] : [])

resource default_nsg 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: 'nsg-${nsgNamePrefix}'
  location: location
  tags: {}
  properties: {
    securityRules: nsg_rules
  }
}

output nsgId string = default_nsg.id
