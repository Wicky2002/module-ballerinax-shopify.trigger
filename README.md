# Ballerina Shopify.trigger connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-shopify.trigger/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-shopify.trigger/actions/workflows/ci.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-shopify.trigger.svg)](https://github.com/ballerina-platform/module-ballerinax-shopify.trigger/commits/master)
[![GitHub Issues](https://img.shields.io/github/issues/ballerina-platform/ballerina-library/module/shopify.trigger.svg?label=Open%20Issues)](https://github.com/ballerina-platform/ballerina-library/labels/module%2Fshopify.trigger)

## Overview

The [Ballerina](https://ballerina.io/) listener for Shopify allows you to listen to store events, grouped by the resource they relate to.

* **Orders** (`OrdersService`): `onOrdersCreate`, `onOrdersUpdated`, `onOrdersCancelled`, `onOrdersFulfilled`, `onOrdersPartiallyFulfilled`, `onOrdersPaid`
* **Customers** (`CustomersService`): `onCustomersCreate`, `onCustomersUpdate`, `onCustomersEnable`, `onCustomersDisable`, `onCustomersMarketingConsentUpdate`
* **Products** (`ProductsService`): `onProductsCreate`, `onProductsUpdate`
* **Fulfillments** (`FulfillmentsService`): `onFulfillmentsCreate`, `onFulfillmentsUpdate`

This module receives Shopify's webhook notifications directly - it does not call Shopify's Admin API
on your behalf. Each notification carries the full resource representation (the whole order, customer,
product, or fulfillment), not just a change reference, so no follow-up API call is needed to see what
changed.

## Setup guide

Before using this connector in your Ballerina application, you need a Shopify partner account and a
development store to generate real events against, plus a Ballerina service that Shopify can reach
over the internet to deliver webhook payloads to.

### Try it out locally

Use this flow to test your webhook handling logic on your own machine before deploying anywhere,
using [ngrok](https://ngrok.com/) to expose your local listener to the internet.

1. [Create a Shopify Partner account](https://www.shopify.com/partners) if you don't already have one,
   and create a development store from the Partner Dashboard to trigger real test events against.
2. Create a custom app for that store (**Settings > Apps and sales channels > Develop apps**), and
   configure a webhook subscription under the app's **Webhooks** section for each topic you want to
   receive (e.g. `orders/create`).
3. Install [ngrok](https://ngrok.com/) and start a tunnel on port `8090` (the default port for the
   Ballerina listener):

   ```sh
   ngrok http 8090
   ```

   Use the HTTPS forwarding URL ngrok prints as the webhook endpoint URL when configuring each topic
   subscription in Shopify.
4. Shopify signs every webhook delivery with your app's **Client Secret**, using HMAC-SHA256 over the
   raw request body. Copy the Client Secret from the app's **API credentials** page - this is the
   value the listener calls `webhookSecret`.

### Production / business integration

The steps above use ngrok's temporary URL, which is fine for local testing but not for a real
deployment. For production use:

1. Deploy your Ballerina service somewhere with a stable, internet-reachable HTTPS URL.
2. Update each webhook topic subscription's endpoint URL to your production URL instead of the ngrok
   URL.
3. Rather than hardcoding `webhookSecret` as shown in the Quickstart, inject it via `Config.toml` (or
   your platform's equivalent configuration/secret mechanism), since it's a `configurable` value.

### Compatibility

|                               | Version                       |
|-------------------------------|--------------------------------|
| Ballerina Language            | Ballerina Swan Lake 2201.13.0 |

## Quickstart

```ballerina
import ballerinax/shopify.trigger as shopify;
import ballerina/io;

configurable string webhookSecret = ?;

listener shopify:Listener shopifyWebhook = new ({webhookSecret}, 8090);

service shopify:OrdersService on shopifyWebhook {
    remote function onOrdersCreate(shopify:OrderEvent payload) returns error? {
        io:println(payload);
    }

    remote function onOrdersUpdated(shopify:OrderEvent payload) returns error? {
        io:println(payload);
    }

    remote function onOrdersCancelled(shopify:OrderEvent payload) returns error? {
        io:println(payload);
    }

    remote function onOrdersFulfilled(shopify:OrderEvent payload) returns error? {
        io:println(payload);
    }

    remote function onOrdersPartiallyFulfilled(shopify:OrderEvent payload) returns error? {
        io:println(payload);
    }

    remote function onOrdersPaid(shopify:OrderEvent payload) returns error? {
        io:println(payload);
    }
}
```

A service attached to a listener's service type must implement **all** of that type's remote
functions - see [`ballerina/README.md`](ballerina/README.md) for the full Quickstart walkthrough.

To verify it is working, go to your **Shopify development store** and create an order. You should see
the event printed in the Ballerina console output.

## Examples

The `shopify.trigger` module provides practical examples illustrating usage in various scenarios.
Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-shopify.trigger/tree/main/examples/),
covering common webhook event handling use cases.

## Build from the source

### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 21. You can download it from either of the following sources:

    * [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
    * [OpenJDK](https://adoptium.net/)

   > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

   > **Note**: Ensure that the Docker daemon is running before executing any tests.

4. Export GitHub Personal access token with read package permissions as follows,

    ```bash
    export packageUser=<Username>
    export packagePAT=<Personal access token>
    ```

### Build options

Execute the commands below to build from the source.

1. To build the package:

   ```bash
   ./gradlew clean build
   ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To build the package without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

4. To run tests against different environments:

   ```bash
   ./gradlew clean test -Pgroups=<Comma separated groups/test cases>
   ```

5. To debug the package with a remote debugger:

   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

6. To debug with the Ballerina language:

   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

7. Publish the generated artifacts to the local Ballerina Central repository:

    ```bash
    ./gradlew clean build -PpublishToLocalCentral=true
    ```

8. Publish the generated artifacts to the Ballerina Central repository:

   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`shopify.trigger` package](https://central.ballerina.io/ballerinax/shopify.trigger/latest).
* See the [migration notes](docs/migration-notes.md) for context on this package's move from the asyncapi-triggers monorepo.
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
