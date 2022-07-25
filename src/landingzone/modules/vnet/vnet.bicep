param location string = resourceGroup().location
param vnetNamePrefix string
param addressPrefix string = '192.168.0.0/24'
param allow_ssh_and_rdp_via_public_ip bool = true

param vnetAddressSpace object = {
  addressPrefixes: [
    '${addressPrefix}'
  ]
}

module nsg 'nsg.bicep' = {
  name: 'default-nsg'
  params: {
    location: location
    nsgNamePrefix: vnetNamePrefix
    allow_ssh_and_rdp_via_public_ip: allow_ssh_and_rdp_via_public_ip
  }
}

resource default_vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: 'vnet-${vnetNamePrefix}'
  location: location
  properties: {
    addressSpace: vnetAddressSpace
    subnets: [
      {
        properties: {
          addressPrefix: '192.168.0.0/26'
          networkSecurityGroup: {
            id: nsg.outputs.nsgId
          }
        }
        name: 'default'
      }
      {
        properties: {
          addressPrefix: '192.168.0.64/26'
          networkSecurityGroup: {
            id: nsg.outputs.nsgId
          }
          delegations: [
            {
              name: 'mysqlflexdelegation'
              properties: {
                serviceName: 'Microsoft.DBforMySQL/flexibleServers'
              }
            }
          ]
        }
        name: 'mysql'
      }
    ]
  }
}

output vnetId string = default_vnet.id
output vnetName string = default_vnet.name
output vnetSubnets array = default_vnet.properties.subnets
