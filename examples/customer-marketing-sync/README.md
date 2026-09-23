# Customer marketing sync

Notifies on customer creation and marketing-consent changes, a starting point for syncing a shop's
customers into a downstream CRM or marketing platform.

## Prerequisites

Complete the [Setup guide](../../ballerina/README.md#setup-guide) in the package README, subscribing
to the `customers/create` and `customers/marketing_consent_update` topics, then update
`webhookSecret` in `Config.toml` with your app's Client Secret.

## Run the example

```bash
bal run
```

Create a customer, or change a customer's marketing consent preference, in your Shopify development
store to see the corresponding log line.
