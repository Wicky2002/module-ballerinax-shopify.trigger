# Customer marketing sync

Notifies on customer creation and marketing-consent changes, a starting point for syncing a shop's
customers into a downstream CRM or marketing platform.

## Prerequisites

Complete the [Setup guide](../../ballerina/README.md#setup-guide) in the package README, subscribing
to the `customers/create` and `customers_marketing_consent/update` topics.

Then put your app's Client Secret in a `Config.toml` in this directory (keep it out of version control):

```toml
[config]
webhookSecret = "<your app's Client Secret>"
```

## Run the example

```bash
bal run
```

Create a customer, or change a customer's marketing consent preference, in your Shopify development
store to see the corresponding log line.
