# Changelog
This file contains all the notable changes done to the Ballerina Shopify trigger through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Fixed
- [Order webhooks with a geocoded billing or shipping address no longer fail to bind](https://github.com/wso2/product-integrator/issues/148). `latitude` and `longitude` are now `string|decimal`, because Shopify sends them as numbers although its documentation shows strings.

## [0.2.0] - 2026-09-28
### Changed
- [Generated record fields are now camelCase, carrying the original JSON key via `@jsondata:Name`](https://github.com/ballerina-platform/ballerina-library/issues/9218). This renames public fields - code reading them by their previous snake_case names needs updating.
- [Webhook payloads now bind to the concrete event type instead of the `GenericDataType` union](https://github.com/ballerina-platform/ballerina-library/issues/9218). Binding into a union resolved to the first structurally matching member, so the value handed to a handler was typed by declaration order rather than by which event arrived. An unrecognised event identifier now returns an error instead of binding to an arbitrary member.
- [Generated doc comments are wrapped to the 120-character line budget](https://github.com/ballerina-platform/ballerina-library/issues/9217) instead of being emitted as a single long line.

## [0.1.0] - 2026-09-23
### Added
- Initial release of the Shopify trigger as its own package, migrated out of the `asyncapi-triggers` monorepo. Handles `orders`, `customers`, `products` and `fulfillments` webhook events (15 events across 4 service types), with HMAC-SHA256 signature verification.
