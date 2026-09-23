# Fulfillment tracking alert

Alerts when a fulfillment is created without a tracking number attached - a logistics-sensitive
case worth paging someone over, since it usually means a shipment can't be tracked yet.

## Prerequisites

Complete the [Setup guide](../../ballerina/README.md#setup-guide) in the package README, subscribing
to the `fulfillments/create` topic, then update `webhookSecret` in `main.bal` (or externalize it via
`Config.toml`) with your app's Client Secret.

## Run the example

```bash
bal run
```

Create a fulfillment in your Shopify development store to see the corresponding log line.
