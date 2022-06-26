##resource "aedv-dbup-demo-gp" "rg-name"{
##	prefix = var.resource_group_name_prefix
##}

resource "azurerm_resource_group" "aedv-dbup-demo-gp" {
  name = "aedv-dbup-demo-gp"
  ##.rg-name.id
  location = var.resource_group_location
}

resource "azurerm_mssql_server" "dbup-demo" {
  name                         = "dbup-demo-sqlserver"
  resource_group_name          = azurerm_resource_group.aedv-dbup-demo-gp.name
  location                     = azurerm_resource_group.aedv-dbup-demo-gp.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_mssql_database" "dbup-demo-test" {
  name         = "acctest-db-d"
  server_id    = azurerm_mssql_server.dbup-demo.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 1
  ##NOTE: Following is not supported in the basic mode.
  #read_scale     = true
  sku_name       = "Basic"
  zone_redundant = false
  create_mode    = "Default"
  sample_name    = "AdventureWorksLT"


  #extended_auditing_policy {
  #  storage_endpoint                        = azurerm_storage_account.example.primary_blob_endpoint
  #  storage_account_access_key              = azurerm_storage_account.example.primary_access_key
  #  storage_account_access_key_is_secondary = true
  #  retention_in_days                       = 6
  #}


  tags = {
    foo = "bar"
  }

}

variable "resource_group_name_prefix" {
  default = "rg"

}

variable "resource_group_location" {
  default = "australiaeast"
}

output "resource_group_name" {
  value = azurerm_resource_group.aedv-dbup-demo-gp.name
}

