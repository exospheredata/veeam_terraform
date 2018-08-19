# Terraform template for Veeam VBR Server
#
# Maintained by Exposphere Data, LLC
# Version 1.0.0
# Date 2018-08-14
#
# This template will deploy a Windows Template to create Veeam VBR Server
#

resource "vsphere_virtual_machine" "vbr_server" {
  name             = "${var.veeam_server_name}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  folder           = "${var.veeam_deployment_folder}"
  guest_id         = "${data.vsphere_virtual_machine.template.guest_id}"

  scsi_type        = "${data.vsphere_virtual_machine.template.scsi_type}"

  num_cpus = "${var.vbr_cpu_count}"
  memory   = "${var.vbr_memory_size_mb}"

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      network_interface {}
      windows_options {
        computer_name  = "${var.veeam_server_name}"
      }
    }
  }
}

# Install the Chef Client and configure the initial connection to the Chef Organization.
# Note: On destroy, this client will
resource "null_resource" "install_chef_vbr_server" {
  triggers {
    instance_id = "${vsphere_virtual_machine.vbr_server.id}"
  }

  depends_on = [
    "vsphere_virtual_machine.vbr_server"
  ]

  connection {
    host = "${vsphere_virtual_machine.vbr_server.guest_ip_addresses.0}"
    type = "winrm"
    user = "${var.admin_user}"
    password = "${var.admin_password}"
    timeout = "20m"
  }

  provisioner "chef" {
    attributes_json =""

    environment     = "${var.chef_environment}"
    run_list        = []
    node_name       = "${vsphere_virtual_machine.vbr_server.name}.${var.domain_name}"
    server_url      = "${var.chef_server_url}"
    recreate_client = true
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
      "knife node delete ${element(vsphere_virtual_machine.vbr_server.*.name, count.index)}.${var.domain_name} --config C:\\chef\\client.rb --key C:\\chef\\client.pem --yes"
    ]
  }

  provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "knife client delete ${element(vsphere_virtual_machine.vbr_server.*.name, count.index)}.${var.domain_name} --config C:\\chef\\client.rb --key C:\\chef\\client.pem --yes"
    ]
  }
}

resource "null_resource" "bootstrap_vbr_server" {
  triggers {
    instance_id = "${vsphere_virtual_machine.vbr_server.id}"
  }

  depends_on = [
    "null_resource.install_chef_vbr_server"
  ]

  connection {
    host      = "${vsphere_virtual_machine.vbr_server.guest_ip_addresses.0}"
    type      = "winrm"
    user      = "${var.admin_user}"
    password  = "${var.admin_password}"
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
          "server": {
            "accept_eula": true,
            "keep_media": true,
            "evaluation": false
          },
          "console": {
            "accept_eula": true
          }
        }
      }
    EOF

    environment     = "${var.chef_environment}"
    run_list        = ["veeam::standalone_complete"]
    node_name       = "${vsphere_virtual_machine.vbr_server.name}.${var.domain_name}"
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
