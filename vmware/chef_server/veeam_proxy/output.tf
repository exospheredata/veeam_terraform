/*
Output Variables
*/

output "proxy_host" {
  value = "${vsphere_virtual_machine.proxy.*.default_ip_address}"
}
