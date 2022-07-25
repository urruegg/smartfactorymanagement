@description('MySQL Server SKU')
param mySQLServerSku string = 'Standard_B1ms'

@description('Database administrator login name')
@minLength(1)
param administratorLogin string

@description('Database administrator password')
@minLength(8)
@maxLength(128)
@secure()
param administratorPassword string

@description('Location to deploy the resources')
param primaryLocation string = resourceGroup().location
param vnetIdForDNSZoneLink string
param delegatedSubnetResourceId string
param baseName string

var mySQLServerName = 'mysql-${baseName}'

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: '${baseName}.private.mysql.database.azure.com'
  location: 'global'
}

resource privateDNSZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateDNSZone.name}/${privateDNSZone.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetIdForDNSZoneLink
    }
  }
}

resource mySQLServer 'Microsoft.DBforMySQL/flexibleServers@2021-05-01' = {
  name: mySQLServerName
  location: primaryLocation
  sku: {
    name: mySQLServerSku
    tier: 'Burstable'
  }
  properties: {
    createMode: 'Default'
    version: '8.0.21'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorPassword
    storage: {
      storageSizeGB: 30
      iops: 360
      autoGrow: 'Enabled'
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    availabilityZone: ''
    highAvailability: {
      mode: 'Disabled'
    }
    network: {
      delegatedSubnetResourceId: delegatedSubnetResourceId
      privateDnsZoneResourceId: privateDNSZone.id
    }
  }
  dependsOn: [
    privateDNSZoneLink
  ]
}

output mySQLName string = mySQLServer.name
output fullyQualifiedDomainName string = mySQLServer.properties.fullyQualifiedDomainName
