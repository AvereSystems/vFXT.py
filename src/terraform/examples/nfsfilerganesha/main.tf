// customize the simple VM by editing the following local variables
locals {
    // the region of the deployment
    location = "eastus"
    vm_admin_username = "azureuser"
    // use either SSH Key data or admin password, if ssh_key_data is specified
    // then admin_password is ignored
    vm_admin_password = "ReplacePassword$"
    // if you use SSH key, ensure you have ~/.ssh/id_rsa with permission 600
    // populated where you are running terraform
    vm_ssh_key_data = null //"ssh-rsa AAAAB3...."

    unique_name = "cloudnfsfiler"

    // virtual network and subnet details
    network_resource_group_name  = "network_resource_group"
    virtual_network_name         = "rendervnet"
    subnet_name                  = "cloud_filers"
    filer_private_ip_address     = null

    // nfs filer details
    filer_resource_group_name = "filer_resource_group"

    // More sizes found here: https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
    // vm_size = "Standard_F16s_v2"
    // vm_size = "Standard_F32s_v2"
    // vm_size = "Standard_F48s_v2"
    vm_size = "Standard_DS14_v2"

    // storage_account_type = "Standard_LRS"
    // storage_account_type = "StandardSSD_LRS"
    storage_account_type = "Premium_LRS"
    
    // set to true to preserve the disk, but destroy the VM
    offline_mode = false
    offline_storage_account_type = "Standard_LRS"

    // more disk sizes and pricing found here: https://azure.microsoft.com/en-us/pricing/details/managed-disks/
    // disk_size_gb = 127   //  P10, E10, S10
    // disk_size_gb = 255   //  P15, E15, S15
    // disk_size_gb = 511   //  P20, E20, S20
    // disk_size_gb = 1023  //  P30, E30, S30
    // disk_size_gb = 2047  //  P40, E40, S40
    // disk_size_gb = 4095  //  P50, E50, S50
    // disk_size_gb = 8191  //  P60, E60, S60
    // disk_size_gb = 16383 //  P70, E70, S70
    disk_size_gb = 32767 //  P80, E80, S80
    nfs_export_path    = "/data"
    caching = local.disk_size_gb > 4095 ? "None" : "ReadWrite"
}

provider "azurerm" {
    version = "~>2.12.0"
    features {}
}

resource "azurerm_resource_group" "nfsfiler" {
    name     = local.filer_resource_group_name
    location = local.location
}

resource "azurerm_managed_disk" "nfsfiler" {
    name                 = "${local.unique_name}-disk1"
    resource_group_name  = azurerm_resource_group.nfsfiler.name
    location             = azurerm_resource_group.nfsfiler.location
    storage_account_type = local.offline_mode ? local.offline_storage_account_type : local.storage_account_type
    create_option        = "Empty"
    disk_size_gb         = local.disk_size_gb
}

// the ephemeral filer
module "nfsfiler" {
    source                  = "github.com/Azure/Avere/src/terraform/modules/nfs_filer_ganesha"
    deploy_vm               = !local.offline_mode
    resource_group_name     = azurerm_resource_group.nfsfiler.name
    location                = azurerm_resource_group.nfsfiler.location
    admin_username          = local.vm_admin_username
    admin_password          = local.vm_admin_password
    ssh_key_data            = local.vm_ssh_key_data
    vm_size                 = local.vm_size
    unique_name             = local.unique_name
    caching                 = local.caching
    enable_root_login       = false
    deploy_diagnostic_tools = false

    // disk and export details
    managed_disk_id    = azurerm_managed_disk.nfsfiler.id
    nfs_export_path    = local.nfs_export_path

    // network details
    virtual_network_resource_group = local.network_resource_group_name
    virtual_network_name           = local.virtual_network_name
    virtual_network_subnet_name    = local.subnet_name
    private_ip_address             = local.filer_private_ip_address
}
output "nfsfiler_username" {
    value = module.nfsfiler.admin_username
}

output "nfsfiler_address" {
    value = module.nfsfiler.primary_ip
}

output "ssh_string" {
    value = module.nfsfiler.ssh_string
}