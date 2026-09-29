terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Every resource below takes its location from the resource group, and
# c3x prices each one in that region.
resource "azurerm_resource_group" "main" {
  name     = "rg-shop-prod"
  location = "westeurope"
}

# --- Kubernetes -----------------------------------------------------------

resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-shop-prod"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "shop"
  sku_tier            = "Standard" # uptime SLA

  default_node_pool {
    name       = "system"
    vm_size    = "Standard_D4s_v5"
    node_count = 3
  }

  identity {
    type = "SystemAssigned"
  }
}

# --- Database ---------------------------------------------------------------

resource "azurerm_mssql_server" "main" {
  name                         = "sql-shop-prod"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  version                      = "12.0"
  administrator_login          = "shopadmin"
  administrator_login_password = "change-me-in-key-vault"
}

resource "azurerm_mssql_database" "orders" {
  name      = "orders"
  server_id = azurerm_mssql_server.main.id
  sku_name  = "GP_Gen5_4" # General Purpose, 4 vCores
}

# --- Storage ----------------------------------------------------------------

resource "azurerm_storage_account" "media" {
  name                     = "stshopmedia"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

# --- Bastion / jump host ------------------------------------------------------

resource "azurerm_virtual_network" "main" {
  name                = "vnet-shop-prod"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "ops" {
  name                 = "snet-ops"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_interface" "ops" {
  name                = "nic-ops"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ops.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "ops" {
  name                  = "vm-ops"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  size                  = "Standard_D2s_v5"
  admin_username        = "ops"
  network_interface_ids = [azurerm_network_interface.ops.id]

  admin_ssh_key {
    username   = "ops"
    public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExampleKeyOnlyForTheDemo ops@example"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}
