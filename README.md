# Infracost GitHub Actions Demo

See [this pull request](https://github.com/infracost/gh-actions-demo/pull/18) for the demo.

The [Infracost GitHub Action](https://github.com/marketplace/actions/infracost) runs [Infracost](https://infracost.io) against the master/main branch and the pull request whenever a Terraform file changes. It automatically adds a pull request comment showing the cost estimate difference (similar to `git diff`) if a percentage threshold is crossed.

See the [Infracost integrations](https://www.infracost.io/docs/integrations/) page for other integrations.
