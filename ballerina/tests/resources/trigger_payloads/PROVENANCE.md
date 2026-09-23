# Trigger payload fixture provenance

Verification status of all 15 webhook payload fixtures under `trigger_payloads/`, checked
against Shopify's real, currently-documented webhook/REST payload samples.

## customers/create.json
Topic: `customers/create`. Status: corrected — brought in line with the minimal shape used
by `customers/update`/`enable`/`disable` below (id, created_at, updated_at, first_name,
last_name, state, note, verified_email, multipass_identifier, tax_exempt, email, phone,
currency, addresses, tax_exemptions, admin_graphql_api_id, default_address), adding a
real `addresses`/`default_address` entry rather than the empty arrays it previously had.
Source: https://shopify.dev/docs/api/webhooks/latest

## customers_marketing_consent/update.json
Topic: `customers/marketing_consent_update`. Status: corrected — replaced the full
~17-field Customer shape with the real minimal 3-field shape (id, phone,
sms_marketing_consent). Source: https://shopify.dev/docs/api/webhooks/latest

## customers/update.json
Topic: `customers/update`. Status: corrected — the real sample uses a smaller, distinct
shape (id, created_at, updated_at, first_name, last_name, state, note, verified_email,
multipass_identifier, tax_exempt, email, phone, currency, addresses, tax_exemptions,
admin_graphql_api_id, default_address), not the full Customer/orders-history shape the
fixture previously had (accepts_marketing, orders_count, total_spent, tags,
sms_marketing_consent, etc. are not part of this payload).
Source: https://shopify.dev/docs/api/webhooks/latest

## customers/enable.json
Topic: `customers/enable`. Status: corrected — same minimal shape issue as
`customers/update`; Shopify's documented sample for this topic uses the identical
field set (id, created_at, updated_at, first_name, last_name, state, note,
verified_email, multipass_identifier, tax_exempt, email, phone, currency, addresses,
tax_exemptions, admin_graphql_api_id, default_address).
Source: https://shopify.dev/docs/api/webhooks/latest

## customers/disable.json
Topic: `customers/disable`. Status: corrected — same minimal shape as
`customers/update` / `customers/enable`; fixture previously carried the full
order-history Customer shape instead.
Source: https://shopify.dev/docs/api/webhooks/latest

## orders/create.json
Topic: `orders/create`. Status: corrected — fixture was completely missing `line_items`,
`shipping_lines`, and `tax_lines`, all explicitly-typed fields on `OrderEvent` and core
parts of every real order payload. Added a representative line item, shipping line, and
tax line consistent with the existing totals.
Source: https://shopify.dev/docs/api/admin-rest/latest/resources/order (order webhooks
send the full current order state, identical in shape to the order resource)

## orders/updated.json
Topic: `orders/updated`. Status: corrected — same missing `line_items` /
`shipping_lines` / `tax_lines` gap as `orders/create.json`; fixed identically.
Source: https://shopify.dev/docs/api/admin-rest/latest/resources/order

## orders/cancelled.json
Topic: `orders/cancelled`. Status: corrected — added `line_items`, `shipping_lines`,
`tax_lines`, and a `refunds` entry (the fixture's `financial_status` is already
"refunded", so a refund record is realistic and `refunds` is an explicitly-typed
`OrderEvent` field).
Source: https://shopify.dev/docs/api/admin-rest/latest/resources/order

## orders/fulfilled.json
Topic: `orders/fulfilled`. Status: corrected — added `line_items` (marked fulfilled),
`shipping_lines`, `tax_lines`, and a `fulfillments` entry matching the fulfillment used
in `fulfillments/update.json` for the same order id.
Source: https://shopify.dev/docs/api/admin-rest/latest/resources/order

## orders/paid.json
Topic: `orders/paid`. Status: corrected — added `line_items`, `shipping_lines`,
`tax_lines` (line item left unfulfilled, consistent with the pre-existing
`fulfillment_status: null`).
Source: https://shopify.dev/docs/api/admin-rest/latest/resources/order

## orders/partially_fulfilled.json
Topic: `orders/partially_fulfilled`. Status: corrected — added two `line_items` (one
fulfilled, one not, summing to the existing subtotal), `shipping_lines`, `tax_lines`,
and a `fulfillments` entry matching `fulfillments/create.json` for the same order id.
Source: https://shopify.dev/docs/api/admin-rest/latest/resources/order

## products/create.json
Topic: `products/create`. Status: verified-accurate — fixture's top-level fields,
`variants[]`, `options[]`, and `images[]` all match the real documented product shape
and field types; no changes needed.
Source: https://shopify.dev/docs/api/admin-rest/latest/resources/product

## products/update.json
Topic: `products/update`. Status: verified-accurate — same as `products/create.json`;
shape and fields match the real documented sample.
Source: https://shopify.dev/docs/api/admin-rest/latest/resources/product

## fulfillments/create.json
Topic: `fulfillments/create`. Status: corrected — fixture was missing `destination`
(the shipping address), an explicitly-typed `FulfillmentEvent` field present in
Shopify's real sample; added it.
Source: https://shopify.dev/docs/api/webhooks/latest and
https://shopify.dev/docs/api/admin-rest/latest/resources/fulfillment

## fulfillments/update.json
Topic: `fulfillments/update`. Status: corrected — same missing `destination` field as
`fulfillments/create.json`; also added a `receipt` object, realistic for a
successfully-shipped fulfillment.
Source: https://shopify.dev/docs/api/webhooks/latest and
https://shopify.dev/docs/api/admin-rest/latest/resources/fulfillment
