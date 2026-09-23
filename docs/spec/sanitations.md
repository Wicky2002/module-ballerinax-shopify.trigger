_Author_:  Dinuka Wickramasinghe \
_Created_: 2026-09-23 \
_Updated_: 2026-09-23 \
_Edition_: Swan Lake

# Sanitation for AsyncAPI specification

This document records the sanitation done on top of the AsyncAPI specification for the Shopify trigger (`asyncapi.yml`, this directory). Unlike a client connector, this package is a webhook *trigger* (an inbound listener) generated from an AsyncAPI spec, not an OpenAPI client spec — the spec describes the webhook events Shopify delivers, not a REST API this package calls out to. These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

1. The event identifier is `x-ballerina-event-identifier: {type: header, name: "X-Shopify-Topic"}`. An earlier version of this spec had it as `type: body, path: "x-shopify-topic"` instead — wrong, since Shopify actually sends the topic as a request header, not a body field. That mistake also exposed a real generator bug (a hyphenated body-path segment produced uncompilable dot-notation source): filed as `ballerina-platform/ballerina-library#9157`, fixed in `ballerina-platform/asyncapi-tools#210`. Not currently reachable through this spec since it now correctly uses `type: header`, but worth knowing why the identifier is shaped this way.
2. Added an `x-ballerina-auth` block for signature verification: HMAC-SHA256 over the raw request body, base64-encoded, checked against `X-Shopify-Hmac-Sha256`. Unlike HubSpot's scheme, nothing beyond the body participates in the signature (no method, URL, or timestamp), so there's no freshness window to configure.

## Ballerina trigger generation

The Ballerina trigger source (`listener.bal`, `dispatcher_service.bal`, `service_types.bal`, `types.bal`) is generated from `asyncapi.yml` using the `asyncapi-tools` generator (`ballerina-platform/asyncapi-tools`). The command should be executed from the repository root directory.

```bash
bal asyncapi http -i docs/spec/asyncapi.yml -o ballerina/
```

This overwrites `listener.bal`, `dispatcher_service.bal`, `service_types.bal`, and the data-types file in `ballerina/` with fresh output. Diff the result before committing - anything currently correct only because of a hand patch to these files (rather than to the spec or the generator itself) will be silently reverted by this command.
