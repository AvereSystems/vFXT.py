// customize the simple VM by editing the following local variables
locals {
    // paste from 0.network output variables
    location1 = ""
    location2 = ""
    location3 = ""
    network_rg1_name = ""
    network_rg2_name = ""
    network_rg3_name = ""
    network-region1-vnet_name = ""
    network-region2-vnet_name = ""
    network-region3-vnet_name = ""
    network-region1-cloud_filers_ha_subnet_name = ""
    network-region1-cloud_filers_subnet_name = ""
    network-region1-jumpbox_subnet_name = ""
    network-region2-cloud_filers_ha_subnet_name = ""
    network-region2-cloud_filers_subnet_name = ""
    network-region3-cloud_filers_ha_subnet_name = ""
    network-region3-cloud_filers_subnet_name = ""
    resource_group_unique_prefix = ""

    // set the following variables to appropriate values
    admin_username = "azureuser"
    admin_password = "ReplacePassword$"
    ssh_public_key = ""

    jumpbox_rg1_name = "${local.resource_group_unique_prefix}jbregion1"
    jumpbox_add_public_ip = true

    // storage rg
    storage_rg1_name = "${local.resource_group_unique_prefix}stgregion1"
    storage_rg2_name = "${local.resource_group_unique_prefix}stgregion2"
    storage_rg3_name = "${local.resource_group_unique_prefix}stgregion3"
    
    // add a globally uniquename
    storage_account_unique_name = ""
    storage_account_name1 = "${local.storage_account_unique_name}${local.location1}"
    storage_container_name = "sharedglobalstorage"

    hammerspace_image_id_1 = ""
    hammerspace_image_id_2 = ""
    hammerspace_image_id_3 = ""
    site1_sharename = ""
    ad_domain = ""
    ad_user = ""
    ad_password = ""
    unique_name_1 = local.location1
    unique_name_2 = local.location2
    unique_name_3 = local.location3
    use_highly_available = false
    anvil_configuration = local.use_highly_available ? "High Availability" : "Standalone"
    // virtual network and subnet details
    data_subnet_mask_bits                = 25
    anvil_data_cluster_ip_1              = "10.0.2.240" // leave blank to be dynamic
    anvil_data_cluster_ip_2              = "10.1.2.240" // leave blank to be dynamic
    anvil_data_cluster_ip_3              = "10.2.2.240" // leave blank to be dynamic
    dsx_instance_count                   = 1

    region1_configuration = local.render_configuration
    region2_configuration = local.artist_configuration
    region3_configuration = local.artist_configuration

    test_configuration = {
        use_highly_available  = false
        anvil_instance_type   = "Standard_F8s_v2"
        metadata_disk_size_gb = 127
        
        dsx_instance_count    = 1
        dsx_instance_type     = "Standard_F8s_v2"
        datadisk_size_gb      = 511

        storage_account_type = "Standard_LRS"
        // storage_account_type = "StandardSSD_LRS"
        // storage_account_type = "Premium_LRS"
    }

    artist_configuration = {
        use_highly_available  = false
        anvil_instance_type   = "Standard_F16s_v2"
        dsx_instance_count    = 3
        
        dsx_instance_type     = "Standard_DS14_v2"
        metadata_disk_size_gb = 256
        datadisk_size_gb      = 1024

        // storage_account_type = "Standard_LRS"
        // storage_account_type = "StandardSSD_LRS"
        storage_account_type = "Premium_LRS"
    }

    render_configuration = {
        use_highly_available  = false
        anvil_instance_type   = "Standard_F16s_v2"
        metadata_disk_size_gb = 256
        
        dsx_instance_count    = 3
        dsx_instance_type     = "Standard_L32s_v2"
        datadisk_size_gb      = 0

        // storage_account_type = "Standard_LRS"
        // storage_account_type = "StandardSSD_LRS"
        storage_account_type = "Premium_LRS"
    }

    // More sizes found here: https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
    anvil_instance_type = "Standard_F8s_v2"
    // anvil_instance_type = "Standard_F16s_v2"
    // anvil_instance_type = "Standard_F32s_v2"
    // anvil_instance_type = "Standard_F48s_v2"
    //anvil_instance_type = "Standard_F16s_v2"
    // More sizes found here: https://docs.microsoft.com/en-us/azure/virtual-machines/sizes
    dsx_instance_type = "Standard_F8s_v2"
    // dsx_instance_type = "Standard_F16s_v2"
    // dsx_instance_type = "Standard_F32s_v2"
    // dsx_instance_type = "Standard_F48s_v2"
    // dsx_instance_type = "Standard_F16s_v2"

    // storage_account_type = "Standard_LRS"
    // storage_account_type = "StandardSSD_LRS"
    storage_account_type = "Premium_LRS"
    
    // more disk sizes and pricing found here: https://azure.microsoft.com/en-us/pricing/details/managed-disks/
    // metadata_disk_size_gb = 127   //  P10, E10, S10
    metadata_disk_size_gb = 255   //  P15, E15, S15
    // metadata_disk_size_gb = 511   //  P20, E20, S20
    // metadata_disk_size_gb = 1023  //  P30, E30, S30
    // metadata_disk_size_gb = 2047  //  P40, E40, S40
    // metadata_disk_size_gb = 4095  //  P50, E50, S50
    // metadata_disk_size_gb = 8191  //  P60, E60, S60
    // metadata_disk_size_gb = 16383 //  P70, E70, S70
    // metadata_disk_size_gb = 32767 //  P80, E80, S80
    
    // more disk sizes and pricing found here: https://azure.microsoft.com/en-us/pricing/details/managed-disks/
    // data_disk_size_gb = 127   //  P10, E10, S10
    // data_disk_size_gb = 255   //  P15, E15, S15
    // data_disk_size_gb = 511   //  P20, E20, S20
    data_disk_size_gb = 1023  //  P30, E30, S30
    // data_disk_size_gb = 2047  //  P40, E40, S40
    //data_disk_size_gb = 4095  //  P50, E50, S50
    // data_disk_size_gb = 8191  //  P60, E60, S60
    // data_disk_size_gb = 16383 //  P70, E70, S70
    // data_disk_size_gb = 32767 //  P80, E80, S80

    # advanced scenario: add external ports to work with cloud policies example [10022, 13389]
    open_external_ports = [22,3389]
    // for a fully locked down internet get your external IP address from http://www.myipaddress.com/
    // or if accessing from cloud shell, put "AzureCloud"
    open_external_sources = ["*"]
    dns_servers = null // set this to the dc, for example ["10.0.3.254"] could be use for domain controller
}

provider "azurerm" {
    version = "~>2.12.0"
    features {}
}

////////////////////////////////////////////////////////////////
// Jumpbox
////////////////////////////////////////////////////////////////

resource "azurerm_resource_group" "jumpboxrg1" {
    name     = local.jumpbox_rg1_name
    location = local.location1
}

module "jumpbox1" {
    source = "github.com/Azure/Avere/src/terraform/modules/jumpbox"
    resource_group_name = azurerm_resource_group.jumpboxrg1.name
    location = local.location1
    admin_username = local.admin_username
    admin_password = local.admin_password
    ssh_key_data = local.ssh_public_key
    add_public_ip = local.jumpbox_add_public_ip
    build_vfxt_terraform_provider = false

    // network details
    virtual_network_resource_group = local.network_rg1_name
    virtual_network_name = local.network-region1-vnet_name
    virtual_network_subnet_name = local.network-region1-jumpbox_subnet_name

    module_depends_on = [azurerm_resource_group.jumpboxrg1.id]
}

////////////////////////////////////////////////////////////////
// STORAGE
////////////////////////////////////////////////////////////////

resource "azurerm_resource_group" "nfsfiler1" {
    name     = local.storage_rg1_name
    location = local.location1
}

resource "azurerm_storage_account" "storage1" {
  name                     = local.storage_account_name1
  resource_group_name      = azurerm_resource_group.nfsfiler1.name
  location                 = local.location1
  account_tier             = "Standard"
  account_replication_type = "LRS"

  depends_on = [azurerm_resource_group.nfsfiler1]
}

resource "azurerm_storage_container" "blob_container1" {
  name                 = local.storage_container_name
  storage_account_name = azurerm_storage_account.storage1.name
}

resource "azurerm_resource_group" "nfsfiler2" {
    name     = local.storage_rg2_name
    location = local.location2
}

resource "azurerm_resource_group" "nfsfiler3" {
    name     = local.storage_rg3_name
    location = local.location3
}

////////////////////////////////////////////////////////////////
// Hammerspace
////////////////////////////////////////////////////////////////

// the ephemeral filer
module "anvil1" {
    source                                = "github.com/Azure/Avere/src/terraform/modules/hammerspace/anvil"
    resource_group_name                   = azurerm_resource_group.nfsfiler1.name
    location                              = azurerm_resource_group.nfsfiler1.location
    hammerspace_image_id                  = local.hammerspace_image_id_1
    unique_name                           = local.unique_name_1
    admin_username                        = local.admin_username
    admin_password                        = local.admin_password
    anvil_configuration                   = local.anvil_configuration
    anvil_instance_type                   = local.anvil_instance_type
    virtual_network_resource_group        = local.network_rg1_name
    virtual_network_name                  = local.network-region1-vnet_name
    virtual_network_ha_subnet_name        = local.network-region1-cloud_filers_ha_subnet_name
    virtual_network_data_subnet_name      = local.network-region1-cloud_filers_subnet_name
    virtual_network_data_subnet_mask_bits = local.data_subnet_mask_bits
    anvil_data_cluster_ip                 = local.anvil_data_cluster_ip_1
    anvil_metadata_disk_storage_type      = local.storage_account_type
    anvil_metadata_disk_size              = local.metadata_disk_size_gb

    module_depends_on = [azurerm_resource_group.nfsfiler1.id]
}

// the ephemeral filer
module "dsx1" {
    source                                = "github.com/Azure/Avere/src/terraform/modules/hammerspace/dsx"
    resource_group_name                   = azurerm_resource_group.nfsfiler1.name
    location                              = azurerm_resource_group.nfsfiler1.location
    hammerspace_image_id                  = local.hammerspace_image_id_1
    unique_name                           = local.unique_name_1
    admin_username                        = local.admin_username
    admin_password                        = local.admin_password
    dsx_instance_count                    = local.dsx_instance_count
    dsx_instance_type                     = local.dsx_instance_type
    virtual_network_resource_group        = local.network_rg1_name
    virtual_network_name                  = local.network-region1-vnet_name
    virtual_network_data_subnet_name      = local.network-region1-cloud_filers_subnet_name
    virtual_network_data_subnet_mask_bits = local.data_subnet_mask_bits
    anvil_password                        = module.anvil1.web_ui_password
    anvil_data_cluster_ip                 = module.anvil1.anvil_data_cluster_ip
    anvil_domain                          = module.anvil1.anvil_domain
    dsx_data_disk_storage_type            = local.storage_account_type
    dsx_data_disk_size                    = local.data_disk_size_gb
}

module "anvil_configure1" {
    source                       = "github.com/Azure/Avere/src/terraform/modules/hammerspace/anvil-run-once-configure"
    anvil_arm_virtual_machine_id = length(module.anvil1.arm_virtual_machine_ids) == 0 ? "" : module.anvil1.arm_virtual_machine_ids[0]
    anvil_data_cluster_ip        = module.anvil1.anvil_data_cluster_ip
    web_ui_password              = module.anvil1.web_ui_password
    dsx_count                    = local.dsx_instance_count
    anvil_hostname               = length(module.anvil1.anvil_host_names) == 0 ? "" : module.anvil1.anvil_host_names[0]

    nfs_export_path  = local.site1_sharename
    local_site_name  = local.unique_name_1
    ad_domain        = local.ad_domain
    ad_user          = local.ad_user
    ad_user_password = local.ad_password

    azure_storage_account = local.storage_account_name1
    azure_storage_account_key = azurerm_storage_account.storage1.primary_access_key
    azure_storage_account_container = local.storage_container_name

    module_depends_on = module.anvil1.module_depends_on_ids
}

// the ephemeral filer
module "anvil2" {
    source                                = "github.com/Azure/Avere/src/terraform/modules/hammerspace/anvil"
    resource_group_name                   = azurerm_resource_group.nfsfiler2.name
    location                              = azurerm_resource_group.nfsfiler2.location
    hammerspace_image_id                  = local.hammerspace_image_id_2
    unique_name                           = local.unique_name_2
    admin_username                        = local.admin_username
    admin_password                        = local.admin_password
    anvil_configuration                   = local.anvil_configuration
    anvil_instance_type                   = local.anvil_instance_type
    virtual_network_resource_group        = local.network_rg2_name
    virtual_network_name                  = local.network-region2-vnet_name
    virtual_network_ha_subnet_name        = local.network-region2-cloud_filers_ha_subnet_name
    virtual_network_data_subnet_name      = local.network-region2-cloud_filers_subnet_name
    virtual_network_data_subnet_mask_bits = local.data_subnet_mask_bits
    anvil_data_cluster_ip                 = local.anvil_data_cluster_ip_2
    anvil_metadata_disk_storage_type      = local.storage_account_type
    anvil_metadata_disk_size              = local.metadata_disk_size_gb

    module_depends_on = [azurerm_resource_group.nfsfiler2.id]
}

// the ephemeral filer
module "dsx2" {
    source                                = "github.com/Azure/Avere/src/terraform/modules/hammerspace/dsx"
    resource_group_name                   = azurerm_resource_group.nfsfiler2.name
    location                              = azurerm_resource_group.nfsfiler2.location
    hammerspace_image_id                  = local.hammerspace_image_id_2
    unique_name                           = local.unique_name_2
    admin_username                        = local.admin_username
    admin_password                        = local.admin_password
    dsx_instance_count                    = local.dsx_instance_count
    dsx_instance_type                     = local.dsx_instance_type
    virtual_network_resource_group        = local.network_rg2_name
    virtual_network_name                  = local.network-region2-vnet_name
    virtual_network_data_subnet_name      = local.network-region2-cloud_filers_subnet_name
    virtual_network_data_subnet_mask_bits = local.data_subnet_mask_bits
    anvil_password                        = module.anvil2.web_ui_password
    anvil_data_cluster_ip                 = module.anvil2.anvil_data_cluster_ip
    anvil_domain                          = module.anvil2.anvil_domain
    dsx_data_disk_storage_type            = local.storage_account_type
    dsx_data_disk_size                    = local.data_disk_size_gb
}

module "anvil_configure2" {
    source                       = "github.com/Azure/Avere/src/terraform/modules/hammerspace/anvil-run-once-configure"
    anvil_arm_virtual_machine_id = length(module.anvil2.arm_virtual_machine_ids) == 0 ? "" : module.anvil2.arm_virtual_machine_ids[0]
    anvil_data_cluster_ip        = module.anvil2.anvil_data_cluster_ip
    web_ui_password              = module.anvil2.web_ui_password
    dsx_count                    = local.dsx_instance_count
    anvil_hostname               = length(module.anvil2.anvil_host_names) == 0 ? "" : module.anvil2.anvil_host_names[0]

    local_site_name  = local.unique_name_2
    ad_domain        = local.ad_domain
    ad_user          = local.ad_user
    ad_user_password = local.ad_password

    azure_storage_account = local.storage_account_name1
    azure_storage_account_key = azurerm_storage_account.storage1.primary_access_key
    azure_storage_account_container = local.storage_container_name

    module_depends_on = module.anvil2.module_depends_on_ids
}

// the ephemeral filer
module "anvil3" {
    source                                = "github.com/Azure/Avere/src/terraform/modules/hammerspace/anvil"
    resource_group_name                   = azurerm_resource_group.nfsfiler3.name
    location                              = azurerm_resource_group.nfsfiler3.location
    hammerspace_image_id                  = local.hammerspace_image_id_3
    unique_name                           = local.unique_name_3
    admin_username                        = local.admin_username
    admin_password                        = local.admin_password
    anvil_configuration                   = local.anvil_configuration
    anvil_instance_type                   = local.anvil_instance_type
    virtual_network_resource_group        = local.network_rg3_name
    virtual_network_name                  = local.network-region3-vnet_name
    virtual_network_ha_subnet_name        = local.network-region3-cloud_filers_ha_subnet_name
    virtual_network_data_subnet_name      = local.network-region3-cloud_filers_subnet_name
    virtual_network_data_subnet_mask_bits = local.data_subnet_mask_bits
    anvil_data_cluster_ip                 = local.anvil_data_cluster_ip_3
    anvil_metadata_disk_storage_type      = local.storage_account_type
    anvil_metadata_disk_size              = local.metadata_disk_size_gb

    module_depends_on = [azurerm_resource_group.nfsfiler3.id]
}

// the ephemeral filer
module "dsx3" {
    source                                = "github.com/Azure/Avere/src/terraform/modules/hammerspace/dsx"
    resource_group_name                   = azurerm_resource_group.nfsfiler3.name
    location                              = azurerm_resource_group.nfsfiler3.location
    hammerspace_image_id                  = local.hammerspace_image_id_3
    unique_name                           = local.unique_name_3
    admin_username                        = local.admin_username
    admin_password                        = local.admin_password
    dsx_instance_count                    = local.dsx_instance_count
    dsx_instance_type                     = local.dsx_instance_type
    virtual_network_resource_group        = local.network_rg3_name
    virtual_network_name                  = local.network-region3-vnet_name
    virtual_network_data_subnet_name      = local.network-region3-cloud_filers_subnet_name
    virtual_network_data_subnet_mask_bits = local.data_subnet_mask_bits
    anvil_password                        = module.anvil3.web_ui_password
    anvil_data_cluster_ip                 = module.anvil3.anvil_data_cluster_ip
    anvil_domain                          = module.anvil3.anvil_domain
    dsx_data_disk_storage_type            = local.storage_account_type
    dsx_data_disk_size                    = local.data_disk_size_gb
}

module "anvil_configure3" {
    source                       = "github.com/Azure/Avere/src/terraform/modules/hammerspace/anvil-run-once-configure"
    anvil_arm_virtual_machine_id = length(module.anvil3.arm_virtual_machine_ids) == 0 ? "" : module.anvil3.arm_virtual_machine_ids[0]
    anvil_data_cluster_ip        = module.anvil3.anvil_data_cluster_ip
    web_ui_password              = module.anvil3.web_ui_password
    dsx_count                    = local.dsx_instance_count
    anvil_hostname               = length(module.anvil3.anvil_host_names) == 0 ? "" : module.anvil3.anvil_host_names[0]

    local_site_name  = local.unique_name_3
    ad_domain        = local.ad_domain
    ad_user          = local.ad_user
    ad_user_password = local.ad_password

    azure_storage_account = local.storage_account_name1
    azure_storage_account_key = azurerm_storage_account.storage1.primary_access_key
    azure_storage_account_container = local.storage_container_name

    module_depends_on = module.anvil3.module_depends_on_ids
}

output "hammerspace_webui_username" {
    value = module.anvil1.web_ui_username
}

output "hammerspace_webui_password_1" {
    value = module.anvil1.web_ui_password
}

output "anvil_data_cluster_ip_1" {
    value = module.anvil1.anvil_data_cluster_ip
}

output "nfs_mountable_ips_1" {
    value = module.dsx1.dsx_ip_addresses
}

output "hammerspace_webui_password_2" {
    value = module.anvil2.web_ui_password
}

output "anvil_data_cluster_ip_2" {
    value = module.anvil2.anvil_data_cluster_ip
}

output "nfs_mountable_ips_2" {
    value = module.dsx2.dsx_ip_addresses
}

output "hammerspace_webui_password_3" {
    value = module.anvil3.web_ui_password
}

output "anvil_data_cluster_ip_3" {
    value = module.anvil3.anvil_data_cluster_ip
}

output "nfs_mountable_ips_3" {
    value = module.dsx3.dsx_ip_addresses
}

output "ssh_command_jb1" {
    value = "ssh ${module.jumpbox1.jumpbox_username}@${module.jumpbox1.jumpbox_address}"
}

output "storage_account_name1_rg" {
    value = azurerm_resource_group.nfsfiler1.name
}

output "storage_account_name1" {
    value = local.storage_account_name1
}

output "storage_container_name" {
    value = local.storage_container_name
}
