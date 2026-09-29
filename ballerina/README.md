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
development store to generate real events against, and a Ballerina service that Shopify can reach
over the internet to deliver webhook payloads to. The two sections below cover both a quick local
test setup and a production deployment.

### Try it out locally

Use this flow to test your webhook handling logic on your own machine before deploying anywhere,
using [ngrok](https://ngrok.com/) to expose your local listener to the internet.

#### Step 1: Create a Shopify Partner account and a development store

1. [Sign up for a Shopify Partner account](https://www.shopify.com/partners) if you don't already
   have one.
2. From the Partner Dashboard, go to **Stores > Create store > Dev** and create a development store -
   this is where you'll trigger real test events (creating orders, customers, products, etc.). Turn
   on **Generate test data for store** so you have sample products and a bogus payment gateway ready
   to go.

   <img src="https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-shopify.trigger/main/docs/setup/resources/shopify-dev-store.png" alt="A newly created Shopify development store's admin dashboard" width="600">

#### Step 2: Create a custom app

Shopify's older "legacy custom apps" flow (configured directly under a store's Settings) has been
retired. Apps are now created and managed through the **Dev Dashboard**, and webhook subscriptions
are declared as config rather than filled into a form.

1. From the Partner Dashboard, go to **Apps > Create app**, give it a name, and leave the app URL as
   a placeholder (e.g. `https://example.com`) - it's only relevant for an app with a real embedded
   UI, which this test app doesn't need.

   <img src="https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-shopify.trigger/main/docs/setup/resources/app-create-1.png" alt="Shopify Dev Dashboard's App development landing page" width="600">
   <img src="https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-shopify.trigger/main/docs/setup/resources/app-create-2.png" alt="Creating a new app in the Shopify Dev Dashboard" width="600">

2. Install the [Shopify CLI](https://shopify.dev/docs/api/shopify-cli) (`npx shopify` works without a
   global install) and link a local project to the app you just created:

   ```sh
   npx shopify app config link
   ```

   This logs you into the Shopify CLI (opens a browser) and prompts you to select your organization
   and the app to link to, generating a `shopify.app.toml` file in the current directory.

#### Step 3: Set up ngrok

The Ballerina listener runs locally and needs a publicly accessible URL so Shopify can deliver
webhook events to it. [ngrok](https://ngrok.com/) creates a secure tunnel from a public URL to your
local service.

Install ngrok and start a tunnel on port `8090` (the default port for the Ballerina listener):

```sh
ngrok http 8090
```

<img src="https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-shopify.trigger/main/docs/setup/resources/ngrok-forwarding.png" alt="ngrok forwarding a public URL to localhost:8090" width="600">

Copy the HTTPS forwarding URL from the ngrok terminal output. It looks like:

```text
https://xxxx-xxx-xxx-xxx.ngrok-free.app
```

> **Save this value** - you will need the ngrok URL in the next step.

#### Step 4: Subscribe to webhook topics

Add the topics you want to receive to `shopify.app.toml`, pointing at your ngrok URL from Step 3,
and declare the access scope each topic needs (e.g. `products/create` needs `read_products`):

```toml
[access_scopes]
scopes = "read_products"

[[webhooks.subscriptions]]
topics = ["products/create"]
uri = "https://<your-ngrok-url>"
```

> Some topics (e.g. anything under `orders/*` or `customers/*`) touch protected customer data and
> require Shopify's separate data-access approval before you can subscribe to them - see
> [Protected customer data](https://shopify.dev/docs/apps/launch/protected-customer-data) if you hit
> that error. `products/*` and `fulfillments/*` don't have this restriction, and are the simplest
> topics to test locally.

Deploy the config, which also installs the app on your development store:

```sh
npx shopify app deploy
```

Confirm the subscription is live from the app's **Versions** page in the Dev Dashboard:

<img src="https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-shopify.trigger/main/docs/setup/resources/webhook-endpoint-config.png" alt="A deployed app version showing an active products/create webhook subscription pointed at the ngrok URL" width="600">

Repeat with more `[[webhooks.subscriptions]]` blocks for every additional topic your service needs.

#### Step 5: Retrieve the signing secret

Shopify signs every webhook delivery with your app's **Client Secret**, using HMAC-SHA256 over the
raw request body. This is a single shared secret - unlike QuickBooks' separate verifier token, it's
the same credential used to sign every subscription on the app.

1. Go to the app's **App settings** page in the Dev Dashboard and reveal the **Client secret**.

   <img src="https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-shopify.trigger/main/docs/setup/resources/webhook-verifier-token.png" alt="Shopify Dev Dashboard app settings page with the Client ID and Client secret fields (value hidden)" width="600">

> **Save this value** - you will need it in the Quickstart section when initialising the Ballerina
> listener. This is the value the listener calls `webhookSecret`.

### Production / business integration

The steps above use ngrok's temporary URL, which is fine for local testing but not for a real
deployment. For production use:

1. Deploy your Ballerina service somewhere with a stable, internet-reachable HTTPS URL. Ballerina
   doesn't require any specific hosting platform - containers, a VM, a managed PaaS, or anything
   else that gives you a stable HTTPS endpoint all work equally well.

2. Update the `uri` in each `[[webhooks.subscriptions]]` block in `shopify.app.toml` (Step 4) to
   your production URL instead of the ngrok URL, and run `shopify app deploy` again to push the
   change live.

3. Rather than hardcoding `webhookSecret` as shown in the Quickstart, inject it via `Config.toml`
   (or your platform's equivalent configuration/secret mechanism), since it's a `configurable`
   value.

4. If you need topics under `orders/*` or `customers/*`, request Shopify's protected customer data
   approval before going live - see
   [Protected customer data](https://shopify.dev/docs/apps/launch/protected-customer-data).

### Compatibility

|                               | Version                       |
|-------------------------------|-------------------------------|
| Ballerina Language            | Ballerina Swan Lake 2201.13.0 |

## Quickstart

To use the Shopify listener in your Ballerina application, update the `.bal` file as follows.

Before running the quickstart, ensure you have:
- The **Client Secret** from Step 5 of the Setup guide
- ngrok running (`ngrok http 8090`)

### Step 1: Import listener

To import the `ballerinax/shopify.trigger` module into the Ballerina project, add the following statement:

```ballerina
import ballerinax/shopify.trigger as shopify;
import ballerina/io;
```

### Step 2: Create a new listener instance

Add the following to your `Config.toml` file, replacing the placeholder with the value saved during
the Setup guide:

```toml
webhookSecret = "<YOUR_CLIENT_SECRET>"
```

Then initialise the listener in your `.bal` file:

```ballerina
configurable string webhookSecret = ?;

listener shopify:Listener shopifyWebhook = new (
    {webhookSecret},
    8090
);
```

`webhookSecret` should always match the Client Secret configured on the Shopify app - this is what
the listener uses to verify incoming payloads actually came from Shopify.

### Step 3: Invoke listener triggers

Now let's use the triggers available within the listener.

A service attached to one of the listener's service types must implement **all** of that type's
remote functions. For example, `OrdersService` exposes six, covering every order event:

```ballerina
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

**Note:** Unlike QuickBooks' notification-only webhooks, Shopify sends the full resource
representation in every event - `payload` above is the complete order, not just its ID, so no
follow-up API call is needed to see what changed.

To compile and run the Ballerina program, issue the following command:

```sh
bal run
```

To verify it is working, go to your **Shopify development store** and create an order (or whichever
resource matches the topic you subscribed to). You should see the event printed in the Ballerina
console output.

<img src="https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-shopify.trigger/main/docs/setup/resources/webhook-confirmed.png" alt="Ballerina console output showing a real Shopify webhook event dispatched successfully" width="600">

## Examples

The `shopify.trigger` module provides practical examples illustrating usage in various scenarios.
Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-shopify.trigger/tree/main/examples/),
covering common webhook event handling use cases.

## Report issues

To report bugs, request new features, start new discussions, etc., go to the [Ballerina Library repository](https://github.com/ballerina-platform/ballerina-library)

## Useful links

- For more information go to the [`shopify.trigger` package](https://central.ballerina.io/ballerinax/shopify.trigger/latest).
- See the [migration notes](https://github.com/ballerina-platform/module-ballerinax-shopify.trigger/blob/main/docs/migration-notes.md) for context on this package's move from the asyncapi-triggers monorepo.
- For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
- Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
- Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
