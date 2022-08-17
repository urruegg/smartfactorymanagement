param location string = resourceGroup().location
param baseName string
param vm_admin_name string
param allow_ssh_and_rdp_via_public_ip bool = false

@secure()
param publicKey string

@secure()
param vm_admin_password string

module vnet 'modules/vnet/vnet.bicep' = {
  name: 'vnet-${baseName}'
  params: {
    vnetNamePrefix: baseName
    location: location
    allow_ssh_and_rdp_via_public_ip: allow_ssh_and_rdp_via_public_ip
  }
}

module vm_ubuntu 'modules/vm-ubuntu/vm.bicep' = {
  name: 'vm_ubuntu_${baseName}'
  params: {
    location: location
    subnetId: vnet.outputs.vnetSubnets[0].id
    tag_application: baseName
    vm_name: 'vm_ubuntu_${baseName}'
    vm_admin_name: vm_admin_name
    publicKey: publicKey
  }
}

module vm_windows 'modules/vm-windows/vm.bicep' = {
  name: 'vm_windows_${baseName}'
  params: {
    location: location
    subnetId: vnet.outputs.vnetSubnets[0].id
    tag_application: baseName
    vm_name: 'vm_windows_${baseName}'
    vm_admin_name: vm_admin_name
    vm_admin_password: vm_admin_password
  }
}

module mysql 'modules/mysql/mysql.bicep' = {
  name: 'mysql_${baseName}'
  params: {
    primaryLocation: location
    administratorLogin: vm_admin_name
    administratorPassword: vm_admin_password
    baseName: baseName
    delegatedSubnetResourceId: vnet.outputs.vnetSubnets[1].id
    vnetIdForDNSZoneLink: vnet.outputs.vnetId
  }
}


module iothub 'modules/iothub/iothub.bicep' = {
  name: 'iothub-${baseName}'
  params: {
    baseName: baseName
    location: location
    skuName: 'S1'
    skuUnits: 1
    d2cPartitions: 4
  }
}
