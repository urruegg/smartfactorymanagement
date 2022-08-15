# Deployment

See file "deploy.azcli" for local deployment from the azure CLI.

# Outputs

* Access the Linux Machine over SSH with *zurusesfmlinux.${location}.cloudapp.azure.com*
* Access the Windows Machine over RDP with *zurusesfmwin.${location}.cloudapp.azure.com*
* Access the MySQL database internally from the VMs through *mysql-zurusesfm.zurusesfm.private.mysql.database.azure.com"
* For internal connections between the VMs use the vm-name, e.g. "vm-windows" or "vm-ubuntu"
