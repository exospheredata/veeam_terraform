
variable "vsphere_server" {
  type        = "string"
  description = "vCenter FQDN or IP to which the systems will be deployed."
}

variable "vsphere_user" {
  type        = "string"
  description = "vCenter Username with privileges to deploy machines"
}

variable "vsphere_password" {
  type        = "string"
  description = "vCenter Password of User selected"
}

variable "datacenter" {
  type        = "string"
  description = "vSphere Datacenter Name to which the systems will be deployed."
}

variable "vsphere_resource_pool" {
  type        = "string"
  description = "vSphere Cluster or Resource Pool to which the systems will be deployed."
}

variable "vsphere_network_name" {
  type        = "string"
  description = "vSphere Virtual Machine Network to which the systems will be attached."
}

variable "proxy_template_path" {
  type        = "string"
  description = "[Optional] vSphere Full Template Path from which the Proxy systems will be deployed.  If empty or 'same' then the variable veeam_template_path will be used."
  default     = "same"
}

variable "proxy_cpu_count" {
  type        = "string"
  description = "Total number of vCPUs to assign to Veeam Proxy Server"
  default     = 2
}

variable "proxy_memory_size_mb" {
  type        = "string"
  description = "Total amount of memory (MB) to assign to Veeam Proxy Server."
  default     = 2048
}

variable "should_register_proxy" {
  type        = "string"
  description = "Should the Veeam Proxy Server be registered to the Veeam VBR Server."
  default     = "true"
}

variable "veeam_deployment_folder" {
  type        = "string"
  description = "vSphere Folder to which the systems will be deployed.  Must exist prior to execution."
}

variable "vbr_server_address" {
  type        = "string"
  description = "Veeam VBR Server Address.  Must exist prior to execution."
}

variable "vbr_admin_user" {
  type        = "string"
  description = "Username for Remote Windows Management Connections.  Must be in Domain\\username or username (for local accounts) format."
}

variable "vbr_admin_password" {
  type        = "string"
  description = "Password for Remote Windows Management Connections"
}

variable "proxy_admin_user" {
  type        = "string"
  description = "Username for Remote Windows Management Connections.  Must be in Domain\\username or username (for local accounts)  format."
}

variable "proxy_admin_password" {
  type        = "string"
  description = "Password for Remote Windows Management Connections"
}

variable "domain_name" {
  type        = "string"
  description = "FQDN domain name"
}

variable "veeam_proxy_name" {
  type        = "string"
  description = "Enter the hostname prefix to give to the Veeam Proxy Server.  Must be less than 12 characters as proxies will receive a 3 digit identifier at the end of their name."
  default     = "proxy"
}

variable "proxy_count" {
  type        = "string"
  description = "Number of Proxy Servers to create.  Zero will remove all proxies created by this Terraform State"
  default     = 0
}


# Chef Configuration
variable "chef_server_url" {
  type        = "string"
  description = "Full Chef Organization URL to which these hosts will be configured."
}

variable "chef_username" {
  type        = "string"
  description = "Chef Username with access to the assigned Chef Organization URL."
}

variable "chef_user_key" {
  type        = "string"
  description = "Full File location on disk to the private key for the assigned Chef Username."
}

variable "chef_environment" {
  type        = "string"
  description = "Chef Environment to which the servers will be configured."
  default     = "_default"
}

variable "veeam_installation_url" {
  type        = "string"
  description = "Full URL from which the Veeam software will be downloaded."
  default     = "https://download.veeam.com/VeeamBackup&Replication_9.5.0.1922.Update3a.iso"
}

variable "veeam_installation_checksum" {
  type        = "string"
  description = "SHA256 Checksum for the ISO Url selected."
  default     = "9a6fa7d857396c058b2e65f20968de56f96bc293e0e8fd9f1a848c7d71534134"
}







