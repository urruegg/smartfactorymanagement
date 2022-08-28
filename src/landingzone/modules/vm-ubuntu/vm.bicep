param subnetId string

@secure()
param publicKey string

param vm_admin_name string

param vm_name string

param location string = resourceGroup().location

param resourcegroup_name string = resourceGroup().name

param tag_application string

param vm_size string = 'Standard_D8S_v3'

resource linux_publicip 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'pip-${vm_name}'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: toLower('${resourcegroup_name}linux')
    }
  }
}

resource linux_nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'nic-${vm_name}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: linux_publicip.id
          }
        }
      }
    ]
  }
}

resource linux_ubuntu_vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: vm_name
  location: location
  tags: {
    role: 'vm-ubuntu'
    application: tag_application
  }
  properties: {
    osProfile: {
      computerName: vm_name
      adminUsername: vm_admin_name
      linuxConfiguration: {
        ssh: {
          publicKeys: [
            {
              path: '/home/${vm_admin_name}/.ssh/authorized_keys'
              keyData: publicKey
            }
          ]
        }
        disablePasswordAuthentication: true
      }
    }
    hardwareProfile: {
      vmSize: vm_size
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: 32
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts'
        version: 'latest'
      }
      dataDisks: [
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: linux_nic.id
        }
      ]
    }
  }
}
