# EventBridge Pipe Enrichment

A quick-and-dirty example of EventBridge's pipe enrichment that allows to add extra context to events for consumers that need it, to avoid HTTP roundtrips in a microservice environment.

## Quickstart

1. `docker compose up`
2. Go to `enrichment-lambda` and follow the `README`.
3. Go to `terraform` and follow the `README`.
3. Go to `consumer` and start the app.
3. In another terminal, go to `producer` and start the app. Watch the `consumer` logs.
