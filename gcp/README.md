# gcp: Cloud Run, Cloud SQL and GKE in europe-west1

| Resource | Notes |
|---|---|
| `google_cloud_run_v2_service` | 2 always-warm instances (`min_instance_count`) of 2 vCPU / 4 GiB, plus request traffic from [`c3x-usage.yml`](c3x-usage.yml) |
| `google_sql_database_instance` | PostgreSQL 16, `db-custom-4-16384`, `REGIONAL` (HA), 100 GB SSD |
| `google_container_cluster` + node pool | zonal cluster in `europe-west1-b`, 3 x `n2-standard-4` |
| `google_compute_instance` | `e2-standard-4` with `zone = "europe-west1-b"`, priced in `europe-west1` |

```console
$ c3x estimate --path gcp
...
PROJECT TOTAL: $1341.1/mo
```

Everything is priced in `europe-west1`, including Cloud SQL, whose price
lookups use the region's own SKUs ("… in Belgium"), and the Compute Engine
VM and GKE nodes, whose region comes from the zone.
