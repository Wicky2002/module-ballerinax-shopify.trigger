# Order lifecycle logger

Logs every `Order` lifecycle event (created, updated, cancelled, fulfilled, partially fulfilled,
paid) as it arrives - the minimal, canonical use case for the `shopify.trigger` listener.

## Prerequisites

Complete the [Setup guide](../../ballerina/README.md#setup-guide) in the package README, subscribing
to the `orders/*` topics.

Then put your app's Client Secret in a `Config.toml` in this directory (keep it out of version control):

```toml
[config]
webhookSecret = "<your app's Client Secret>"
```

## Run the example

```bash
bal run
```

Create, update, cancel, fulfill, or pay for an order in your Shopify development store to see the
corresponding log line.
