# C3X Demo

Example Terraform project demonstrating C3X cost estimation on pull requests.

## How it works

Every pull request automatically gets a cost estimate comment from [C3X Cloud](https://github.com/apps/c3x-cloud).

The workflow is two steps:

```yaml
- uses: actions/checkout@v4
- uses: c3xdev/setup-c3x@v1
  with:
    path: .
```

See [PR #1](https://github.com/c3xdev/c3x-demo/pull/1) for a live example.

## Links

- [C3X](https://github.com/c3xdev/c3x)
- [Documentation](https://c3x.dev/docs)
- [Setup Action](https://github.com/marketplace/actions/setup-c3x)
