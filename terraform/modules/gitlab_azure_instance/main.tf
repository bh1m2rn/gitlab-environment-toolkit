terraform {
  required_version = ">= 0.14"
}

data "azurerm_public_ip" "gitlab_external_ips" {
  name                = each.key
  resource_group_name = var.resource_group_name

  for_each = toset(var.external_ip_names)
}

locals {
  external_ip_ids = [for ip in data.azurerm_public_ip.gitlab_external_ips : ip.id]
}

resource "azurerm_public_ip" "gitlab" {
  count               = length(local.external_ip_ids) == 0 ? var.node_count : 0
  name                = "${var.prefix}-${var.node_type}-ip-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "gitlab" {
  count               = var.node_count
  name                = "${var.prefix}-${var.node_type}-network-interface-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Dynamic allocation is used because otherwise we will need to "manually" specify
  # private_ip_address for each NIC/VM. The difference between Static and Dynamic:
  # https://docs.microsoft.com/en-us/azure/virtual-network/private-ip-addresses#allocation-method
  ip_configuration {
    name                          = "${var.prefix}-${var.node_type}-internal-ip-configuration-${count.index + 1}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = length(local.external_ip_ids) == 0 ? azurerm_public_ip.gitlab[count.index].id : local.external_ip_ids[count.index]
  }
}

# Connect the security group to the network interface if provided
resource "azurerm_network_interface_security_group_association" "gitlab" {
  count                     = var.node_count == 0 || var.network_security_group == null ? 0 : 1
  network_interface_id      = azurerm_network_interface.gitlab[count.index].id
  network_security_group_id = var.network_security_group.id
}

resource "azurerm_linux_virtual_machine" "gitlab" {
  count               = var.node_count
  name                = "${var.prefix}-${var.node_type}-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size
  # The username of the local administrator used for the Virtual Machine.
  admin_username = var.vm_admin_username

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = file(var.ssh_public_key_file_path)
  }

  network_interface_ids = [
    azurerm_network_interface.gitlab[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type
    disk_size_gb         = var.disk_size
  }

  source_image_reference {
    publisher = var.source_image_reference["publisher"]
    offer     = var.source_image_reference["offer"]
    sku       = var.source_image_reference["sku"]
    version   = var.source_image_reference["version"]
  }

  tags = {
    gitlab_node_prefix = var.prefix
    gitlab_node_type   = var.node_type
    gitlab_node_level  = var.label_secondaries == true ? (count.index == 0 ? "${var.node_type}-primary" : "${var.node_type}-secondary") : null
  }
}
