# Examples

The `ballerinax/shopify.trigger` connector provides practical examples illustrating usage in various scenarios.

1. [Order lifecycle logger](order-lifecycle-logger) - the minimal, canonical use case: log every `Order` lifecycle event.
2. [Customer marketing sync](customer-marketing-sync) - notify on customer creation and marketing-consent changes, a starting point for CRM/marketing-platform sync.
3. [Fulfillment tracking alert](fulfillment-tracking-alert) - a different, logistics-sensitive case: alert when a fulfillment is created without a tracking number.

## Prerequisites

Complete the [Setup guide](../ballerina/README.md#setup-guide) in the package README first - each
example needs a Shopify app with a webhook subscribed to the events it listens for.

## Running an example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```

## Building the examples with the local module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```
