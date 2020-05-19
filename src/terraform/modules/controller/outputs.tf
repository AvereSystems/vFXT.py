output "controller_address" {
  value = "${var.add_public_ip ? azurerm_public_ip.vm[0].ip_address : azurerm_network_interface.vm.ip_configuration[0].private_ip_address}"
}

output "controller_username" {
  value = "${var.admin_username}"
}

output "module_depends_on_id" {
  description = "the id(s) to force others to wait"
  value = zurerm_role_assignment.create_compute.id
}