resource "azurerm_public_ip" "public_ip" {
  name                = "${var.name}PublicIp"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  domain_name_label   = lower(var.domain_name_label)
  count               = var.public_ip ? 1 : 0
  tags                = var.tags

  lifecycle {
    ignore_changes = [
        tags
    ]
  }
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  my_public_ip = chomp(data.http.myip.body)
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name}Nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = local.my_public_ip
    destination_address_prefix = "*"
  }

  lifecycle {
    ignore_changes = [
        tags
    ]
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.name}Nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "Configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = try(azurerm_public_ip.public_ip[0].id, "")
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on = [azurerm_network_security_group.nsg]
}

resource "azurerm_linux_virtual_machine" "virtual_machine" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  network_interface_ids         = [azurerm_network_interface.nic.id]
  size                          = var.size
  computer_name                 = var.name
  admin_username                = var.vm_user
  tags                          = var.tags

  os_disk {
    name                 = "${var.name}OsDisk"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
  }

  admin_ssh_key {
    username   = var.vm_user
    public_key = file(var.admin_ssh_public_key)
  }

  source_image_reference {
    offer     = lookup(var.os_disk_image, "offer", null)
    publisher = lookup(var.os_disk_image, "publisher", null)
    sku       = lookup(var.os_disk_image, "sku", null)
    version   = lookup(var.os_disk_image, "version", null)
  }

  lifecycle {
    ignore_changes = [
        tags
    ]
  }

  depends_on = [
    azurerm_network_interface.nic,
    azurerm_network_security_group.nsg
  ]
}

resource "azurerm_virtual_machine_extension" "custom_script" {
  name                    = "${var.name}CustomScript"
  virtual_machine_id      = azurerm_linux_virtual_machine.virtual_machine.id
  publisher               = "Microsoft.Azure.Extensions"
  type                    = "CustomScript"
  type_handler_version    = "2.0"

  settings = <<SETTINGS
    {
      "commandToExecute": "bash ${var.script_name}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "script": "${base64encode(file("../scripts/configure-vm.sh"))}"
    }
  PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [
      tags,
      settings,
      protected_settings
    ]
  }
}
