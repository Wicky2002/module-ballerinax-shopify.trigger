# Migration notes: moved from the asyncapi-triggers monorepo

This is the first release of `shopify.trigger` as its own repository, migrated out of
`ballerina-platform/asyncapi-triggers`. Unlike some other triggers migrated the same way, this was
a straightforward move — the spec (`docs/spec/asyncapi.yml`) already correctly modeled Shopify's real
webhook behavior, and regenerating it with the current `asyncapi-tools` generator produced output
byte-identical to what the monorepo shipped, except for one rename (see below) and a doc-comment
improvement. See `docs/spec/sanitations.md` for the spec's own history, including a generator bug
this spec's event identifier previously exposed (already fixed upstream, not currently reachable
here since the spec correctly uses a header-based identifier).

## What changed from the monorepo

- `data_types.bal` renamed to `types.bal`, matching the generator's current naming convention across
  all four migrated trigger connectors.
- `ballerina/metadata/` (L1/L2 metadata for Copilot and low-code UI support) adapted from the real
  reference files already present in the monorepo, with one real fix: the monorepo's UI metadata
  referenced a listener config field named `apiSecretKey` marked required, but the actual generated
  `ListenerConfig` has an optional field named `webhookSecret` - the UI metadata now matches the real
  generated code, including the same fallback-value fix already shipped for github.trigger,
  hubspot.trigger, and quickbooks.trigger to handle that field being left blank.

## Fixture verification

All 15 test fixtures in `ballerina/tests/resources/trigger_payloads/` were verified against
Shopify's real documented webhook/REST payload samples before this release. 13 were corrected -
missing fields (`line_items`, `shipping_lines`, `tax_lines`, `destination`, etc.) and one topic
(`customers/marketing_consent_update`) that used the wrong payload shape entirely. See
`ballerina/tests/resources/trigger_payloads/PROVENANCE.md` for the per-fixture verification status
and sources.
