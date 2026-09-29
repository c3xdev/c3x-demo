# cloudformation: a plain CloudFormation template

[`template.yaml`](template.yaml): an EC2 app server (`m7i.xlarge`), RDS
PostgreSQL (`db.r7g.large`, 250 GB gp3) and an S3 bucket whose storage and
requests come from [`c3x-usage.yml`](c3x-usage.yml). Parameter defaults
(`!Ref AppInstanceType`) are resolved.

```console
$ c3x estimate --path cloudformation
...
PROJECT TOTAL: $362.79/mo
```

The [workflow](../.github/workflows/cloudformation.yml) runs with
`strict: true`: the estimate has no caveats, so it passes, and it would fail
as soon as a change introduced a number c3x had to assume.
