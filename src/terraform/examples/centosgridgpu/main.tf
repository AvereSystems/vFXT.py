// customize the simple VM by editing the following local variables
locals {
    // the region of the deployment
    location = "westus2"
    resource_group = "centosgridgpu"
    vm_admin_username = "azureuser"
    // use either SSH Key data or admin password, if ssh_key_data is specified
    // then admin_password is ignored
    vm_admin_password = "ReplacePassword$"
    // if you use SSH key, ensure you have ~/.ssh/id_rsa with permission 600
    // populated where you are running terraform
    vm_ssh_key_data = null //"ssh-rsa AAAAB3...."
    ssh_port = 22
    
    // network details
    network_resource_group_name = "network_resource_group"
    vnet_name = "rendernetwork"
    subnet_name = "jumpbox"

    unique_name = "centosgridgpu"
}

provider "azurerm" {
    version = "~>2.12.0"
    features {}
}

resource "azurerm_resource_group" "centosgridgpu" {
  name     = local.resource_group
  location = local.location
}

module "centosgridgpu" {
    source = "github.com/Azure/Avere/src/terraform/modules/centosgridgpu"
    resource_group_name = local.resource_group
    location = local.location
    admin_username = local.vm_admin_username
    admin_password = local.vm_admin_password
    ssh_key_data = local.vm_ssh_key_data
    ssh_port = local.ssh_port

    // network details
    virtual_network_resource_group = local.network_resource_group_name
    virtual_network_name = local.vnet_name
    virtual_network_subnet_name = local.subnet_name

    module_depends_on = [azurerm_resource_group.centosgridgpu.id]
}

output "address" {
  value = module.centosgridgpu.address
}