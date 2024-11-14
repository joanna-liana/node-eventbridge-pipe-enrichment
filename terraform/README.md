## Prerequisites

1. [tflocal](https://github.com/localstack/terraform-local) installed - since we're using Localstack
2. The root's `docker-compose.yml` is up and running.
3. There's a `lambda.zip` at this (`terraform`) directory. If it's not, go to `../enrichment-lambda` and follow the instructions.

## How to use
```
tflocal init && tflocal apply
```
