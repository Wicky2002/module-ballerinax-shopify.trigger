// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/crypto;
import ballerina/http;
import ballerina/io;
import ballerina/lang.runtime;
import ballerina/test;

const TRIGGER_TEST_SECRET = "trigger-test-secret";
const TRIGGER_TEST_PORT = 9091;
const TRIGGER_PAYLOAD_DIR = "tests/resources/trigger_payloads";

isolated map<boolean> triggerFired = {};
isolated map<json> boundPayloads = {};

listener Listener triggerTestListener = check new ({webhookSecret: TRIGGER_TEST_SECRET}, TRIGGER_TEST_PORT);

final http:Client triggerClient = check new (string `http://localhost:${TRIGGER_TEST_PORT}`);

service FulfillmentsService on triggerTestListener {
    isolated remote function onFulfillmentsCreate(FulfillmentEvent payload) returns error? {
        lock {
            triggerFired["FulfillmentsService.onFulfillmentsCreate"] = true;
        }
        lock {
            boundPayloads["FulfillmentsService.onFulfillmentsCreate"] = payload.toJson().clone();
        }
    }

    isolated remote function onFulfillmentsUpdate(FulfillmentEvent payload) returns error? {
        lock {
            triggerFired["FulfillmentsService.onFulfillmentsUpdate"] = true;
        }
        lock {
            boundPayloads["FulfillmentsService.onFulfillmentsUpdate"] = payload.toJson().clone();
        }
    }
}

service OrdersService on triggerTestListener {
    isolated remote function onOrdersFulfilled(OrderEvent payload) returns error? {
        lock {
            triggerFired["OrdersService.onOrdersFulfilled"] = true;
        }
        lock {
            boundPayloads["OrdersService.onOrdersFulfilled"] = payload.toJson().clone();
        }
    }

    isolated remote function onOrdersPartiallyFulfilled(OrderEvent payload) returns error? {
        lock {
            triggerFired["OrdersService.onOrdersPartiallyFulfilled"] = true;
        }
        lock {
            boundPayloads["OrdersService.onOrdersPartiallyFulfilled"] = payload.toJson().clone();
        }
    }

    isolated remote function onOrdersCancelled(OrderEvent payload) returns error? {
        lock {
            triggerFired["OrdersService.onOrdersCancelled"] = true;
        }
        lock {
            boundPayloads["OrdersService.onOrdersCancelled"] = payload.toJson().clone();
        }
    }

    isolated remote function onOrdersCreate(OrderEvent payload) returns error? {
        lock {
            triggerFired["OrdersService.onOrdersCreate"] = true;
        }
        lock {
            boundPayloads["OrdersService.onOrdersCreate"] = payload.toJson().clone();
        }
    }

    isolated remote function onOrdersUpdated(OrderEvent payload) returns error? {
        lock {
            triggerFired["OrdersService.onOrdersUpdated"] = true;
        }
        lock {
            boundPayloads["OrdersService.onOrdersUpdated"] = payload.toJson().clone();
        }
    }

    isolated remote function onOrdersPaid(OrderEvent payload) returns error? {
        lock {
            triggerFired["OrdersService.onOrdersPaid"] = true;
        }
        lock {
            boundPayloads["OrdersService.onOrdersPaid"] = payload.toJson().clone();
        }
    }
}

service CustomersService on triggerTestListener {
    isolated remote function onCustomersMarketingConsentUpdate(CustomerEvent payload) returns error? {
        lock {
            triggerFired["CustomersService.onCustomersMarketingConsentUpdate"] = true;
        }
        lock {
            boundPayloads["CustomersService.onCustomersMarketingConsentUpdate"] = payload.toJson().clone();
        }
    }

    isolated remote function onCustomersEnable(CustomerEvent payload) returns error? {
        lock {
            triggerFired["CustomersService.onCustomersEnable"] = true;
        }
        lock {
            boundPayloads["CustomersService.onCustomersEnable"] = payload.toJson().clone();
        }
    }

    isolated remote function onCustomersUpdate(CustomerEvent payload) returns error? {
        lock {
            triggerFired["CustomersService.onCustomersUpdate"] = true;
        }
        lock {
            boundPayloads["CustomersService.onCustomersUpdate"] = payload.toJson().clone();
        }
    }

    isolated remote function onCustomersDisable(CustomerEvent payload) returns error? {
        lock {
            triggerFired["CustomersService.onCustomersDisable"] = true;
        }
        lock {
            boundPayloads["CustomersService.onCustomersDisable"] = payload.toJson().clone();
        }
    }

    isolated remote function onCustomersCreate(CustomerEvent payload) returns error? {
        lock {
            triggerFired["CustomersService.onCustomersCreate"] = true;
        }
        lock {
            boundPayloads["CustomersService.onCustomersCreate"] = payload.toJson().clone();
        }
    }
}

service ProductsService on triggerTestListener {
    isolated remote function onProductsUpdate(ProductEvent payload) returns error? {
        lock {
            triggerFired["ProductsService.onProductsUpdate"] = true;
        }
        lock {
            boundPayloads["ProductsService.onProductsUpdate"] = payload.toJson().clone();
        }
    }

    isolated remote function onProductsCreate(ProductEvent payload) returns error? {
        lock {
            triggerFired["ProductsService.onProductsCreate"] = true;
        }
        lock {
            boundPayloads["ProductsService.onProductsCreate"] = payload.toJson().clone();
        }
    }
}

isolated function sendSignedTriggerWebhook(string headerValue, string eventIdentifier) returns http:Response|error {
    byte[] body = check io:fileReadBytes(string `${TRIGGER_PAYLOAD_DIR}/${eventIdentifier}.json`);
    string bodyText = check string:fromBytes(body);
    string payloadToHash = string `${bodyText}`;
    byte[] computedDigest = check crypto:hmacSha256(payloadToHash.toBytes(), TRIGGER_TEST_SECRET.toBytes());
    string computedSignature = computedDigest.toBase64();
    map<string> headers = {
        "X-Shopify-Topic": headerValue,
        "X-Shopify-Hmac-Sha256": string `${computedSignature}`
    };
    return triggerClient->post("/", body, headers, "application/json");
}

function waitForDispatch(string trackerKey) returns boolean {
    foreach int i in 0 ..< 20 {
        lock {
            if triggerFired[trackerKey] ?: false {
                return true;
            }
        }
        runtime:sleep(0.05);
    }
    return false;
}

function boundPayloadOf(string trackerKey) returns map<json> {
    lock {
        json payload = boundPayloads[trackerKey] ?: {};
        return payload is map<json> ? payload.clone() : {};
    }
}

@test:Config {}
function testFulfillmentsCreateDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("fulfillments/create", "fulfillments/create");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("FulfillmentsService.onFulfillmentsCreate"), "FulfillmentsService.onFulfillmentsCreate should have fired");
    map<json> bound = boundPayloadOf("FulfillmentsService.onFulfillmentsCreate");
    test:assertFalse(bound.hasKey("order_id"), "'order_id' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("created_at"), "'created_at' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("updated_at"), "'updated_at' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tracking_company"), "'tracking_company' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("shipment_status"), "'shipment_status' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("location_id"), "'location_id' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("origin_address"), "'origin_address' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("line_items"), "'line_items' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tracking_number"), "'tracking_number' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tracking_numbers"), "'tracking_numbers' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tracking_url"), "'tracking_url' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tracking_urls"), "'tracking_urls' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("admin_graphql_api_id"), "'admin_graphql_api_id' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
}

@test:Config {}
function testFulfillmentsUpdateDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("fulfillments/update", "fulfillments/update");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("FulfillmentsService.onFulfillmentsUpdate"), "FulfillmentsService.onFulfillmentsUpdate should have fired");
    map<json> bound = boundPayloadOf("FulfillmentsService.onFulfillmentsUpdate");
    test:assertFalse(bound.hasKey("order_id"), "'order_id' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("created_at"), "'created_at' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("updated_at"), "'updated_at' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tracking_company"), "'tracking_company' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("shipment_status"), "'shipment_status' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("location_id"), "'location_id' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("origin_address"), "'origin_address' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("line_items"), "'line_items' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tracking_number"), "'tracking_number' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tracking_numbers"), "'tracking_numbers' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tracking_url"), "'tracking_url' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tracking_urls"), "'tracking_urls' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("admin_graphql_api_id"), "'admin_graphql_api_id' should have bound to its camelCase field on FulfillmentEvent, not stayed a raw key");
}

@test:Config {}
function testOrdersFulfilledDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("orders/fulfilled", "orders/fulfilled");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("OrdersService.onOrdersFulfilled"), "OrdersService.onOrdersFulfilled should have fired");
    map<json> bound = boundPayloadOf("OrdersService.onOrdersFulfilled");
    test:assertFalse(bound.hasKey("closed_at"), "'closed_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("created_at"), "'created_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("updated_at"), "'updated_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_price"), "'total_price' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("subtotal_price"), "'subtotal_price' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_weight"), "'total_weight' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_tax"), "'total_tax' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("taxes_included"), "'taxes_included' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("financial_status"), "'financial_status' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_discounts"), "'total_discounts' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_line_items_price"), "'total_line_items_price' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("cart_token"), "'cart_token' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("buyer_accepts_marketing"), "'buyer_accepts_marketing' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("referring_site"), "'referring_site' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("landing_site"), "'landing_site' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("cancelled_at"), "'cancelled_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("cancel_reason"), "'cancel_reason' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_price_usd"), "'total_price_usd' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("checkout_token"), "'checkout_token' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("user_id"), "'user_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("location_id"), "'location_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("source_identifier"), "'source_identifier' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("source_url"), "'source_url' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("processed_at"), "'processed_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("device_id"), "'device_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("customer_locale"), "'customer_locale' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("app_id"), "'app_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("browser_ip"), "'browser_ip' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("landing_site_ref"), "'landing_site_ref' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("order_number"), "'order_number' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("discount_applications"), "'discount_applications' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("discount_codes"), "'discount_codes' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("note_attributes"), "'note_attributes' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("payment_gateway_names"), "'payment_gateway_names' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("processing_method"), "'processing_method' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("source_name"), "'source_name' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("fulfillment_status"), "'fulfillment_status' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tax_lines"), "'tax_lines' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("contact_email"), "'contact_email' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("order_status_url"), "'order_status_url' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("presentment_currency"), "'presentment_currency' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_line_items_price_set"), "'total_line_items_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_discounts_set"), "'total_discounts_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_shipping_price_set"), "'total_shipping_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("subtotal_price_set"), "'subtotal_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_price_set"), "'total_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_tax_set"), "'total_tax_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("line_items"), "'line_items' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_tip_received"), "'total_tip_received' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("original_total_duties_set"), "'original_total_duties_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("current_total_duties_set"), "'current_total_duties_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("payment_terms"), "'payment_terms' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("admin_graphql_api_id"), "'admin_graphql_api_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("shipping_lines"), "'shipping_lines' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("billing_address"), "'billing_address' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("shipping_address"), "'shipping_address' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
}

@test:Config {}
function testOrdersPartiallyFulfilledDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("orders/partially_fulfilled", "orders/partially_fulfilled");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("OrdersService.onOrdersPartiallyFulfilled"), "OrdersService.onOrdersPartiallyFulfilled should have fired");
    map<json> bound = boundPayloadOf("OrdersService.onOrdersPartiallyFulfilled");
    test:assertFalse(bound.hasKey("closed_at"), "'closed_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("created_at"), "'created_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("updated_at"), "'updated_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_price"), "'total_price' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("subtotal_price"), "'subtotal_price' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_weight"), "'total_weight' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_tax"), "'total_tax' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("taxes_included"), "'taxes_included' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("financial_status"), "'financial_status' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_discounts"), "'total_discounts' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_line_items_price"), "'total_line_items_price' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("cart_token"), "'cart_token' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("buyer_accepts_marketing"), "'buyer_accepts_marketing' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("referring_site"), "'referring_site' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("landing_site"), "'landing_site' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("cancelled_at"), "'cancelled_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("cancel_reason"), "'cancel_reason' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_price_usd"), "'total_price_usd' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("checkout_token"), "'checkout_token' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("user_id"), "'user_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("location_id"), "'location_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("source_identifier"), "'source_identifier' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("source_url"), "'source_url' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("processed_at"), "'processed_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("device_id"), "'device_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("customer_locale"), "'customer_locale' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("app_id"), "'app_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("browser_ip"), "'browser_ip' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("landing_site_ref"), "'landing_site_ref' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("order_number"), "'order_number' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("discount_applications"), "'discount_applications' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("discount_codes"), "'discount_codes' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("note_attributes"), "'note_attributes' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("payment_gateway_names"), "'payment_gateway_names' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("processing_method"), "'processing_method' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("source_name"), "'source_name' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("fulfillment_status"), "'fulfillment_status' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tax_lines"), "'tax_lines' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("contact_email"), "'contact_email' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("order_status_url"), "'order_status_url' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("presentment_currency"), "'presentment_currency' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_line_items_price_set"), "'total_line_items_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_discounts_set"), "'total_discounts_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_shipping_price_set"), "'total_shipping_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("subtotal_price_set"), "'subtotal_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_price_set"), "'total_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_tax_set"), "'total_tax_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("line_items"), "'line_items' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_tip_received"), "'total_tip_received' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("original_total_duties_set"), "'original_total_duties_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("current_total_duties_set"), "'current_total_duties_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("payment_terms"), "'payment_terms' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("admin_graphql_api_id"), "'admin_graphql_api_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("shipping_lines"), "'shipping_lines' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("billing_address"), "'billing_address' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("shipping_address"), "'shipping_address' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
}

@test:Config {}
function testOrdersCancelledDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("orders/cancelled", "orders/cancelled");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("OrdersService.onOrdersCancelled"), "OrdersService.onOrdersCancelled should have fired");
    map<json> bound = boundPayloadOf("OrdersService.onOrdersCancelled");
    test:assertFalse(bound.hasKey("closed_at"), "'closed_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("created_at"), "'created_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("updated_at"), "'updated_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_price"), "'total_price' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("subtotal_price"), "'subtotal_price' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_weight"), "'total_weight' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_tax"), "'total_tax' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("taxes_included"), "'taxes_included' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("financial_status"), "'financial_status' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_discounts"), "'total_discounts' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_line_items_price"), "'total_line_items_price' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("cart_token"), "'cart_token' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("buyer_accepts_marketing"), "'buyer_accepts_marketing' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("referring_site"), "'referring_site' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("landing_site"), "'landing_site' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("cancelled_at"), "'cancelled_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("cancel_reason"), "'cancel_reason' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_price_usd"), "'total_price_usd' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("checkout_token"), "'checkout_token' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("user_id"), "'user_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("location_id"), "'location_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("source_identifier"), "'source_identifier' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("source_url"), "'source_url' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("processed_at"), "'processed_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("device_id"), "'device_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("customer_locale"), "'customer_locale' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("app_id"), "'app_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("browser_ip"), "'browser_ip' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("landing_site_ref"), "'landing_site_ref' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("order_number"), "'order_number' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("discount_applications"), "'discount_applications' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("discount_codes"), "'discount_codes' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("note_attributes"), "'note_attributes' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("payment_gateway_names"), "'payment_gateway_names' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("processing_method"), "'processing_method' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("source_name"), "'source_name' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("fulfillment_status"), "'fulfillment_status' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tax_lines"), "'tax_lines' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("contact_email"), "'contact_email' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("order_status_url"), "'order_status_url' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("presentment_currency"), "'presentment_currency' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_line_items_price_set"), "'total_line_items_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_discounts_set"), "'total_discounts_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_shipping_price_set"), "'total_shipping_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("subtotal_price_set"), "'subtotal_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_price_set"), "'total_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_tax_set"), "'total_tax_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("line_items"), "'line_items' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_tip_received"), "'total_tip_received' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("original_total_duties_set"), "'original_total_duties_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("current_total_duties_set"), "'current_total_duties_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("payment_terms"), "'payment_terms' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("admin_graphql_api_id"), "'admin_graphql_api_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("shipping_lines"), "'shipping_lines' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("billing_address"), "'billing_address' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("shipping_address"), "'shipping_address' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
}

@test:Config {}
function testOrdersCreateDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("orders/create", "orders/create");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("OrdersService.onOrdersCreate"), "OrdersService.onOrdersCreate should have fired");
    map<json> bound = boundPayloadOf("OrdersService.onOrdersCreate");
    test:assertFalse(bound.hasKey("closed_at"), "'closed_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("created_at"), "'created_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("updated_at"), "'updated_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_price"), "'total_price' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("subtotal_price"), "'subtotal_price' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_weight"), "'total_weight' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_tax"), "'total_tax' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("taxes_included"), "'taxes_included' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("financial_status"), "'financial_status' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_discounts"), "'total_discounts' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_line_items_price"), "'total_line_items_price' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("cart_token"), "'cart_token' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("buyer_accepts_marketing"), "'buyer_accepts_marketing' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("referring_site"), "'referring_site' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("landing_site"), "'landing_site' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("cancelled_at"), "'cancelled_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("cancel_reason"), "'cancel_reason' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_price_usd"), "'total_price_usd' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("checkout_token"), "'checkout_token' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("user_id"), "'user_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("location_id"), "'location_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("source_identifier"), "'source_identifier' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("source_url"), "'source_url' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("processed_at"), "'processed_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("device_id"), "'device_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("customer_locale"), "'customer_locale' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("app_id"), "'app_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("browser_ip"), "'browser_ip' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("landing_site_ref"), "'landing_site_ref' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("order_number"), "'order_number' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("discount_applications"), "'discount_applications' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("discount_codes"), "'discount_codes' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("note_attributes"), "'note_attributes' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("payment_gateway_names"), "'payment_gateway_names' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("processing_method"), "'processing_method' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("source_name"), "'source_name' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("fulfillment_status"), "'fulfillment_status' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tax_lines"), "'tax_lines' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("contact_email"), "'contact_email' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("order_status_url"), "'order_status_url' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("presentment_currency"), "'presentment_currency' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_line_items_price_set"), "'total_line_items_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_discounts_set"), "'total_discounts_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_shipping_price_set"), "'total_shipping_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("subtotal_price_set"), "'subtotal_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_price_set"), "'total_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_tax_set"), "'total_tax_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("line_items"), "'line_items' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_tip_received"), "'total_tip_received' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("original_total_duties_set"), "'original_total_duties_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("current_total_duties_set"), "'current_total_duties_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("payment_terms"), "'payment_terms' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("admin_graphql_api_id"), "'admin_graphql_api_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("shipping_lines"), "'shipping_lines' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("billing_address"), "'billing_address' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("shipping_address"), "'shipping_address' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
}

@test:Config {}
function testOrdersUpdatedDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("orders/updated", "orders/updated");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("OrdersService.onOrdersUpdated"), "OrdersService.onOrdersUpdated should have fired");
    map<json> bound = boundPayloadOf("OrdersService.onOrdersUpdated");
    test:assertFalse(bound.hasKey("closed_at"), "'closed_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("created_at"), "'created_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("updated_at"), "'updated_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_price"), "'total_price' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("subtotal_price"), "'subtotal_price' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_weight"), "'total_weight' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_tax"), "'total_tax' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("taxes_included"), "'taxes_included' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("financial_status"), "'financial_status' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_discounts"), "'total_discounts' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_line_items_price"), "'total_line_items_price' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("cart_token"), "'cart_token' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("buyer_accepts_marketing"), "'buyer_accepts_marketing' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("referring_site"), "'referring_site' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("landing_site"), "'landing_site' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("cancelled_at"), "'cancelled_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("cancel_reason"), "'cancel_reason' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_price_usd"), "'total_price_usd' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("checkout_token"), "'checkout_token' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("user_id"), "'user_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("location_id"), "'location_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("source_identifier"), "'source_identifier' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("source_url"), "'source_url' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("processed_at"), "'processed_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("device_id"), "'device_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("customer_locale"), "'customer_locale' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("app_id"), "'app_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("browser_ip"), "'browser_ip' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("landing_site_ref"), "'landing_site_ref' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("order_number"), "'order_number' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("discount_applications"), "'discount_applications' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("discount_codes"), "'discount_codes' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("note_attributes"), "'note_attributes' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("payment_gateway_names"), "'payment_gateway_names' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("processing_method"), "'processing_method' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("source_name"), "'source_name' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("fulfillment_status"), "'fulfillment_status' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tax_lines"), "'tax_lines' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("contact_email"), "'contact_email' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("order_status_url"), "'order_status_url' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("presentment_currency"), "'presentment_currency' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_line_items_price_set"), "'total_line_items_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_discounts_set"), "'total_discounts_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_shipping_price_set"), "'total_shipping_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("subtotal_price_set"), "'subtotal_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_price_set"), "'total_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_tax_set"), "'total_tax_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("line_items"), "'line_items' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_tip_received"), "'total_tip_received' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("original_total_duties_set"), "'original_total_duties_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("current_total_duties_set"), "'current_total_duties_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("payment_terms"), "'payment_terms' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("admin_graphql_api_id"), "'admin_graphql_api_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("shipping_lines"), "'shipping_lines' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("billing_address"), "'billing_address' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("shipping_address"), "'shipping_address' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
}

@test:Config {}
function testOrdersPaidDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("orders/paid", "orders/paid");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("OrdersService.onOrdersPaid"), "OrdersService.onOrdersPaid should have fired");
    map<json> bound = boundPayloadOf("OrdersService.onOrdersPaid");
    test:assertFalse(bound.hasKey("closed_at"), "'closed_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("created_at"), "'created_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("updated_at"), "'updated_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_price"), "'total_price' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("subtotal_price"), "'subtotal_price' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_weight"), "'total_weight' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_tax"), "'total_tax' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("taxes_included"), "'taxes_included' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("financial_status"), "'financial_status' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_discounts"), "'total_discounts' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_line_items_price"), "'total_line_items_price' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("cart_token"), "'cart_token' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("buyer_accepts_marketing"), "'buyer_accepts_marketing' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("referring_site"), "'referring_site' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("landing_site"), "'landing_site' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("cancelled_at"), "'cancelled_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("cancel_reason"), "'cancel_reason' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_price_usd"), "'total_price_usd' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("checkout_token"), "'checkout_token' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("user_id"), "'user_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("location_id"), "'location_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("source_identifier"), "'source_identifier' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("source_url"), "'source_url' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("processed_at"), "'processed_at' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("device_id"), "'device_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("customer_locale"), "'customer_locale' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("app_id"), "'app_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("browser_ip"), "'browser_ip' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("landing_site_ref"), "'landing_site_ref' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("order_number"), "'order_number' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("discount_applications"), "'discount_applications' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("discount_codes"), "'discount_codes' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("note_attributes"), "'note_attributes' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("payment_gateway_names"), "'payment_gateway_names' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("processing_method"), "'processing_method' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("source_name"), "'source_name' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("fulfillment_status"), "'fulfillment_status' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tax_lines"), "'tax_lines' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("contact_email"), "'contact_email' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("order_status_url"), "'order_status_url' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("presentment_currency"), "'presentment_currency' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_line_items_price_set"), "'total_line_items_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_discounts_set"), "'total_discounts_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_shipping_price_set"), "'total_shipping_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("subtotal_price_set"), "'subtotal_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_price_set"), "'total_price_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_tax_set"), "'total_tax_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("line_items"), "'line_items' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_tip_received"), "'total_tip_received' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("original_total_duties_set"), "'original_total_duties_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("current_total_duties_set"), "'current_total_duties_set' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("payment_terms"), "'payment_terms' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("admin_graphql_api_id"), "'admin_graphql_api_id' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("shipping_lines"), "'shipping_lines' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("billing_address"), "'billing_address' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("shipping_address"), "'shipping_address' should have bound to its camelCase field on OrderEvent, not stayed a raw key");
}

@test:Config {}
function testCustomersMarketingConsentUpdateDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("customers_marketing_consent/update", "customers_marketing_consent/update");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("CustomersService.onCustomersMarketingConsentUpdate"), "CustomersService.onCustomersMarketingConsentUpdate should have fired");
    map<json> bound = boundPayloadOf("CustomersService.onCustomersMarketingConsentUpdate");
    test:assertFalse(bound.hasKey("accepts_marketing"), "'accepts_marketing' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("created_at"), "'created_at' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("updated_at"), "'updated_at' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("first_name"), "'first_name' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("last_name"), "'last_name' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("orders_count"), "'orders_count' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_spent"), "'total_spent' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("last_order_id"), "'last_order_id' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("verified_email"), "'verified_email' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("multipass_identifier"), "'multipass_identifier' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tax_exempt"), "'tax_exempt' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("last_order_name"), "'last_order_name' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("accepts_marketing_updated_at"), "'accepts_marketing_updated_at' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("marketing_opt_in_level"), "'marketing_opt_in_level' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("sms_marketing_consent"), "'sms_marketing_consent' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("admin_graphql_api_id"), "'admin_graphql_api_id' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
}

@test:Config {}
function testCustomersEnableDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("customers/enable", "customers/enable");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("CustomersService.onCustomersEnable"), "CustomersService.onCustomersEnable should have fired");
    map<json> bound = boundPayloadOf("CustomersService.onCustomersEnable");
    test:assertFalse(bound.hasKey("accepts_marketing"), "'accepts_marketing' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("created_at"), "'created_at' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("updated_at"), "'updated_at' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("first_name"), "'first_name' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("last_name"), "'last_name' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("orders_count"), "'orders_count' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_spent"), "'total_spent' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("last_order_id"), "'last_order_id' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("verified_email"), "'verified_email' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("multipass_identifier"), "'multipass_identifier' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tax_exempt"), "'tax_exempt' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("last_order_name"), "'last_order_name' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("accepts_marketing_updated_at"), "'accepts_marketing_updated_at' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("marketing_opt_in_level"), "'marketing_opt_in_level' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("sms_marketing_consent"), "'sms_marketing_consent' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("admin_graphql_api_id"), "'admin_graphql_api_id' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
}

@test:Config {}
function testCustomersUpdateDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("customers/update", "customers/update");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("CustomersService.onCustomersUpdate"), "CustomersService.onCustomersUpdate should have fired");
    map<json> bound = boundPayloadOf("CustomersService.onCustomersUpdate");
    test:assertFalse(bound.hasKey("accepts_marketing"), "'accepts_marketing' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("created_at"), "'created_at' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("updated_at"), "'updated_at' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("first_name"), "'first_name' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("last_name"), "'last_name' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("orders_count"), "'orders_count' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_spent"), "'total_spent' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("last_order_id"), "'last_order_id' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("verified_email"), "'verified_email' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("multipass_identifier"), "'multipass_identifier' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tax_exempt"), "'tax_exempt' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("last_order_name"), "'last_order_name' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("accepts_marketing_updated_at"), "'accepts_marketing_updated_at' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("marketing_opt_in_level"), "'marketing_opt_in_level' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("sms_marketing_consent"), "'sms_marketing_consent' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("admin_graphql_api_id"), "'admin_graphql_api_id' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
}

@test:Config {}
function testCustomersDisableDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("customers/disable", "customers/disable");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("CustomersService.onCustomersDisable"), "CustomersService.onCustomersDisable should have fired");
    map<json> bound = boundPayloadOf("CustomersService.onCustomersDisable");
    test:assertFalse(bound.hasKey("accepts_marketing"), "'accepts_marketing' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("created_at"), "'created_at' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("updated_at"), "'updated_at' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("first_name"), "'first_name' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("last_name"), "'last_name' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("orders_count"), "'orders_count' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_spent"), "'total_spent' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("last_order_id"), "'last_order_id' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("verified_email"), "'verified_email' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("multipass_identifier"), "'multipass_identifier' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tax_exempt"), "'tax_exempt' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("last_order_name"), "'last_order_name' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("accepts_marketing_updated_at"), "'accepts_marketing_updated_at' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("marketing_opt_in_level"), "'marketing_opt_in_level' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("sms_marketing_consent"), "'sms_marketing_consent' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("admin_graphql_api_id"), "'admin_graphql_api_id' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
}

@test:Config {}
function testCustomersCreateDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("customers/create", "customers/create");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("CustomersService.onCustomersCreate"), "CustomersService.onCustomersCreate should have fired");
    map<json> bound = boundPayloadOf("CustomersService.onCustomersCreate");
    test:assertFalse(bound.hasKey("accepts_marketing"), "'accepts_marketing' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("created_at"), "'created_at' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("updated_at"), "'updated_at' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("first_name"), "'first_name' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("last_name"), "'last_name' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("orders_count"), "'orders_count' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("total_spent"), "'total_spent' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("last_order_id"), "'last_order_id' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("verified_email"), "'verified_email' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("multipass_identifier"), "'multipass_identifier' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("tax_exempt"), "'tax_exempt' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("last_order_name"), "'last_order_name' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("accepts_marketing_updated_at"), "'accepts_marketing_updated_at' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("marketing_opt_in_level"), "'marketing_opt_in_level' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("sms_marketing_consent"), "'sms_marketing_consent' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("admin_graphql_api_id"), "'admin_graphql_api_id' should have bound to its camelCase field on CustomerEvent, not stayed a raw key");
}

@test:Config {}
function testProductsUpdateDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("products/update", "products/update");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("ProductsService.onProductsUpdate"), "ProductsService.onProductsUpdate should have fired");
    map<json> bound = boundPayloadOf("ProductsService.onProductsUpdate");
    test:assertFalse(bound.hasKey("body_html"), "'body_html' should have bound to its camelCase field on ProductEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("product_type"), "'product_type' should have bound to its camelCase field on ProductEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("created_at"), "'created_at' should have bound to its camelCase field on ProductEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("updated_at"), "'updated_at' should have bound to its camelCase field on ProductEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("published_at"), "'published_at' should have bound to its camelCase field on ProductEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("template_suffix"), "'template_suffix' should have bound to its camelCase field on ProductEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("published_scope"), "'published_scope' should have bound to its camelCase field on ProductEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("admin_graphql_api_id"), "'admin_graphql_api_id' should have bound to its camelCase field on ProductEvent, not stayed a raw key");
}

@test:Config {}
function testProductsCreateDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("products/create", "products/create");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("ProductsService.onProductsCreate"), "ProductsService.onProductsCreate should have fired");
    map<json> bound = boundPayloadOf("ProductsService.onProductsCreate");
    test:assertFalse(bound.hasKey("body_html"), "'body_html' should have bound to its camelCase field on ProductEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("product_type"), "'product_type' should have bound to its camelCase field on ProductEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("created_at"), "'created_at' should have bound to its camelCase field on ProductEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("updated_at"), "'updated_at' should have bound to its camelCase field on ProductEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("published_at"), "'published_at' should have bound to its camelCase field on ProductEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("template_suffix"), "'template_suffix' should have bound to its camelCase field on ProductEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("published_scope"), "'published_scope' should have bound to its camelCase field on ProductEvent, not stayed a raw key");
    test:assertFalse(bound.hasKey("admin_graphql_api_id"), "'admin_graphql_api_id' should have bound to its camelCase field on ProductEvent, not stayed a raw key");
}

