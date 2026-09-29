# azure: AKS, Azure SQL, storage and a VM in West Europe

Every resource takes `location = azurerm_resource_group.main.location`, and
c3x prices each one in that region (`westeurope`), not in a default one.

| Resource | Notes |
|---|---|
| `azurerm_kubernetes_cluster` | Standard tier (uptime SLA), 3 x `Standard_D4s_v5` nodes |
| `azurerm_mssql_database` | `GP_Gen5_4`: General Purpose, 4 vCores, SQL license included |
| `azurerm_storage_account` | Standard GRS, 1 TB from [`c3x-usage.yml`](c3x-usage.yml) |
| `azurerm_linux_virtual_machine` | `Standard_D2s_v5` with a 64 GB Premium SSD OS disk |

```console
$ c3x estimate --path azure
...
PROJECT TOTAL: $1451.13/mo
```
