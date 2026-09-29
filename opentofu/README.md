# opentofu: one provider per region with for_each

[`main.tofu`](main.tofu) uses OpenTofu's provider `for_each` to configure one
AWS provider per region, and fans an EC2 instance and an ElastiCache node out
across them. c3x reads `.tofu` files and prices each instance in the region
of the provider it uses:

```console
$ c3x estimate --path opentofu
  aws_instance.edge["eu-west-1"]
    Instance usage (Linux/UNIX, on-demand)
      730 hours × $0.1819 = $132.787/mo
  ...
  aws_instance.edge["us-east-1"]
    Instance usage (Linux/UNIX, on-demand)
      730 hours × $0.1632 = $119.136/mo
  ...
  PROJECT TOTAL: $597.59/mo
```

Add `--currency EUR` to see the same estimate in euros (€526.27/mo).
