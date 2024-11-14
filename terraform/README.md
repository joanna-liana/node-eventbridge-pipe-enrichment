## Prerequisites

1. [tflocal](https://github.com/localstack/terraform-local) installed - since we're using Localstack
2. The root's `docker-compose.yml` is up and running.
3. There's a `lambda.zip` at this (`terraform`) directory. If it's not, go to `../enrichment-lambda` and follow the instructions.
4. **LOCALSTACK PRO** - NEEDED TO SUPPORT [PIPES](https://docs.localstack.cloud/user-guide/aws/pipes/). As of November, you'll otherwise see:
```
Error: creating AWS EventBridge Pipes Pipe (EventToSQSPipeWithEnrichment): operation error Pipes: CreatePipe, https response error StatusCode: 501, RequestID: 4b47d8c5-d050-4e62-8b30-47e0ec178c1d, api error InternalFailure: API for service 'pipes' not yet implemented or pro feature - please check https://docs.localstack.cloud/references/coverage/ for further information
```

## How to use
```
tflocal init && tflocal apply
```
