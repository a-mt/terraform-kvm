
output "vm_ips" {
  value = libvirt_domain.domain-ubuntu.*.network_interface.0.addresses
  description = "IP addresses of the created VMs"
}
