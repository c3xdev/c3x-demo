# aws: web application

A typical three-AZ web stack in `us-east-1`.

| Resource | Notes |
|---|---|
| VPC, public and private subnets | one of each per availability zone (free) |
| NAT gateways | one per AZ, `count` driven by `data.aws_availability_zones` |
| Application Load Balancer | hourly charge plus LCU-hours from the usage file |
| `module.tier` | local module used with `for_each` over `var.tiers` (`web`, `worker`); each tier has `instance_count` EC2 instances and a `dynamic "ebs_block_device"` per entry in `data_volumes` |
| RDS PostgreSQL | `db.m7g.large`, Multi-AZ, 200 GB gp3 |
| S3 bucket, Lambda function | priced from [`c3x-usage.yml`](c3x-usage.yml) |

[`.c3x.toml`](.c3x.toml) points c3x at the usage file and sets a `budget`
of $5,000/mo. The [workflow](../.github/workflows/aws.yml) also fails a pull
request that adds more than $500/mo (`budget-delta`).

```console
$ c3x estimate --path aws
...
PROJECT TOTAL: $1115.58/mo
```

`data.aws_availability_zones` can't be read without AWS credentials, so c3x
assumes three zones for the region (`us-east-1a`, `-b`, `-c`) and marks each
NAT gateway and Elastic IP with an `assumed_count` ⚠ caveat naming that
assumption. For exact counts, price a plan JSON instead.
