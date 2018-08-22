# Terraform template for Veeam Proxy Servers
#
# Maintained by Exposphere Data, LLC
# Version 1.0.0
# Date 2018-08-14
#
# This template will deploy one or more Windows Templates to create Veeam Proxy Servers
#

resource "vsphere_virtual_machine" "proxy" {
  count            = "${var.proxy_count}"
  name             = "${format("${var.veeam_proxy_name}%02d", count.index+1)}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  folder           = "${var.veeam_deployment_folder}"
  guest_id         = "${data.vsphere_virtual_machine.proxy_template.guest_id}"

  scsi_type        = "${data.vsphere_virtual_machine.proxy_template.scsi_type}"

  num_cpus         = "${var.proxy_cpu_count}"
  memory           = "${var.proxy_memory_size_mb}"

  network_interface {
    network_id     = "${data.vsphere_network.network.id}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.proxy_template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.proxy_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.proxy_template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.proxy_template.id}"

    customize {
      network_interface {}
      windows_options {
        computer_name  = "${format("${var.veeam_proxy_name}%02d", count.index+1)}"
      }
    }

  }
}
resource "null_resource" "install_chef_proxy" {
  count            = "${var.proxy_count}"
  triggers {
    instance_id = "${vsphere_virtual_machine.proxy.*.id[count.index]}"
  }

  depends_on = [
    "vsphere_virtual_machine.proxy"
  ]

  connection {
    host      = "${element(vsphere_virtual_machine.proxy.*.guest_ip_addresses.0, count.index)}"
    type      = "winrm"
    user      = "${var.proxy_admin_user}"
    password  = "${var.proxy_admin_password}"
    timeout   = "20m"
  }

  provisioner "chef" {
    attributes_json = ""

    environment     = "${var.chef_environment}"
    run_list        = []
    node_name       = "${element(vsphere_virtual_machine.proxy.*.name, count.index)}.${var.domain_name}"
    server_url      = "${var.chef_server_url}"
    recreate_client = true
    user_name       = "${var.chef_username}"
    user_key        = "${file(var.chef_user_key)}"
    # If you have a self signed cert on your chef server change this to :verify_none
    ssl_verify_mode = ":verify_peer"
  }

  provisioner "chef" {
    when = "destroy"
    attributes_json = <<-EOF
      {
        "veeam": {
          "installer": {
            "package_url": "${var.veeam_installation_url}",
            "package_checksum": "${var.veeam_installation_checksum}"
          },
          "version": "9.5",
          "console": {
            "accept_eula": true,
            "keep_media": true
          },
          "proxy": {
            "vbr_server": "${var.vbr_server_address}",
            "vbr_username": "${var.vbr_admin_user}",
            "vbr_password": "${var.vbr_admin_password}",
            "proxy_username": "${var.proxy_admin_user}",
            "proxy_password": "${var.proxy_admin_password}",
            "use_ip_address": true
          }
        }
      }
    EOF

    environment     = "${var.chef_environment}"
    run_list        = ["veeam::proxy_remove"]
    node_name       = "${element(vsphere_virtual_machine.proxy.*.name, count.index)}.${var.domain_name}"
    server_url      = "${var.chef_server_url}"
    skip_install    = true
    skip_register   = true
    recreate_client = false
    user_name       = "${var.chef_username}"
    user_key        = "${file(var.chef_user_key)}"
    # If you have a self signed cert on your chef server change this to :verify_none
    ssl_verify_mode = ":verify_peer"
  }

  # The following will remove the node from the Chef server by remoting executing this command on the instance.
  #
  provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "knife node delete ${element(vsphere_virtual_machine.proxy.*.name, count.index)}.${var.domain_name} --config C:\\chef\\client.rb --key C:\\chef\\client.pem --yes"
    ]
  }

  provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "knife client delete ${element(vsphere_virtual_machine.proxy.*.name, count.index)}.${var.domain_name} --config C:\\chef\\client.rb --key C:\\chef\\client.pem --yes"
    ]
  }
}

resource "null_resource" "bootstrap_proxy" {
  count            = "${var.proxy_count}"
  triggers {
    instance_id = "${vsphere_virtual_machine.proxy.*.id[count.index]}",
    should_register_proxy = "${var.should_register_proxy}"
  }

  depends_on = [
    "null_resource.install_chef_proxy"
  ]

  connection {
    host      = "${element(vsphere_virtual_machine.proxy.*.guest_ip_addresses.0, count.index)}"
    type      = "winrm"
    user      = "${var.proxy_admin_user}"
    password  = "${var.proxy_admin_password}"
    timeout   = "20m"
  }

  provisioner "chef" {
    attributes_json = <<-EOF
      {
        "veeam": {
          "installer": {
            "package_url": "${var.veeam_installation_url}",
            "package_checksum": "${var.veeam_installation_checksum}"
          },
          "version": "9.5",
          "console": {
            "accept_eula": true,
            "keep_media": true
          },
          "proxy": {
            "vbr_server": "${var.vbr_server_address}",
            "vbr_username": "${var.vbr_admin_user}",
            "vbr_password": "${var.vbr_admin_password}",
            "proxy_username": "${var.proxy_admin_user}",
            "proxy_password": "${var.proxy_admin_password}",
            "use_ip_address": true,
            "register": ${var.should_register_proxy == "true" ? true : false}
          }
        }
      }
    EOF

    environment     = "${var.chef_environment}"
    run_list        = ["veeam::proxy_server"]
    node_name       = "${element(vsphere_virtual_machine.proxy.*.name, count.index)}.${var.domain_name}"
    server_url      = "${var.chef_server_url}"
    skip_install    = true
    skip_register   = true
    recreate_client = false
    user_name       = "${var.chef_username}"
    user_key        = "${file(var.chef_user_key)}"
    # If you have a self signed cert on your chef server change this to :verify_none
    ssl_verify_mode = ":verify_peer"
  }
}
