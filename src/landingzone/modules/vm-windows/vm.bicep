param subnetId string
param vm_admin_name string
param vm_name string
@secure()
param vm_admin_password string
param location string = resourceGroup().location
param resourcegroup_name string = resourceGroup().name
param tag_application string
param vm_size string = 'Standard_F16s_v2'

resource win_publicip 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'pip-${vm_name}'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: toLower('${resourcegroup_name}win')
    }
  }
}

resource win_nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
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
            id: win_publicip.id
          }
        }
      }
    ]
  }
}

resource win_vm_windows 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: vm_name
  location: location
  tags: {
    role: 'vm-windows'
    application: tag_application
  }
  properties: {
    osProfile: {
      computerName: vm_name
      adminUsername: vm_admin_name
      adminPassword: vm_admin_password
    }
    hardwareProfile: {
      vmSize: vm_size
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: 'win10-21h2-pro'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: win_nic.id
        }
      ]
    }
  }
}
