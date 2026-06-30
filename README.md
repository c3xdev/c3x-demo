# C3X Demo

Example Terraform project demonstrating C3X cost estimation on pull requests.

## How it works

Every pull request automatically gets a cost estimate comment from [C3X Cloud](https://github.com/apps/c3x-cloud).

The workflow (`.github/workflows/c3x.yml`) runs on every pull request:

```yaml
name: Cost Estimation
on: [pull_request]

permissions:
  pull-requests: write
  id-token: write        # mints the branded c3x-cloud[bot] token

jobs:
  c3x:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: c3xdev/c3x@v0
        with:
          path: .
          branded-comments: true
```

On a pull request the comment shows the **cost delta versus the base
branch** — e.g. `Total: $533.16/mo → $1038.32/mo  🔺 +$505.16` — with a
per-resource breakdown. See [PR #4](https://github.com/c3xdev/c3x-demo/pull/4)
for a live example.

## Gate on cost increases

Add `budget-delta` to fail the check when a PR raises the monthly cost
by more than a set amount versus the base branch (independent of the
absolute `budget` cap):

```yaml
      - uses: c3xdev/c3x@v0
        with:
          path: .
          branded-comments: true
          budget-delta: "50"     # fail if this PR adds > $50/mo
          # budget: "1000"       # (optional) fail if the total exceeds $1000/mo
```

## Links

- [C3X](https://github.com/c3xdev/c3x)
- [Documentation](https://c3x.dev/docs)
- [CI/CD guide](https://c3x.dev/docs/ci-cd)
