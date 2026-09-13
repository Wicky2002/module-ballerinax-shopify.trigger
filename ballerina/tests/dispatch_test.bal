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

listener Listener triggerTestListener = check new ({webhookSecret: TRIGGER_TEST_SECRET}, TRIGGER_TEST_PORT);

final http:Client triggerClient = check new (string `http://localhost:${TRIGGER_TEST_PORT}`);

service FulfillmentsService on triggerTestListener {
    isolated remote function onFulfillmentsCreate(FulfillmentEvent payload) returns error? {
        lock {
            triggerFired["FulfillmentsService.onFulfillmentsCreate"] = true;
        }
    }

    isolated remote function onFulfillmentsUpdate(FulfillmentEvent payload) returns error? {
        lock {
            triggerFired["FulfillmentsService.onFulfillmentsUpdate"] = true;
        }
    }
}

service OrdersService on triggerTestListener {
    isolated remote function onOrdersFulfilled(OrderEvent payload) returns error? {
        lock {
            triggerFired["OrdersService.onOrdersFulfilled"] = true;
        }
    }

    isolated remote function onOrdersPartiallyFulfilled(OrderEvent payload) returns error? {
        lock {
            triggerFired["OrdersService.onOrdersPartiallyFulfilled"] = true;
        }
    }

    isolated remote function onOrdersCancelled(OrderEvent payload) returns error? {
        lock {
            triggerFired["OrdersService.onOrdersCancelled"] = true;
        }
    }

    isolated remote function onOrdersCreate(OrderEvent payload) returns error? {
        lock {
            triggerFired["OrdersService.onOrdersCreate"] = true;
        }
    }

    isolated remote function onOrdersUpdated(OrderEvent payload) returns error? {
        lock {
            triggerFired["OrdersService.onOrdersUpdated"] = true;
        }
    }

    isolated remote function onOrdersPaid(OrderEvent payload) returns error? {
        lock {
            triggerFired["OrdersService.onOrdersPaid"] = true;
        }
    }
}

service CustomersService on triggerTestListener {
    isolated remote function onCustomersMarketingConsentUpdate(CustomerEvent payload) returns error? {
        lock {
            triggerFired["CustomersService.onCustomersMarketingConsentUpdate"] = true;
        }
    }

    isolated remote function onCustomersEnable(CustomerEvent payload) returns error? {
        lock {
            triggerFired["CustomersService.onCustomersEnable"] = true;
        }
    }

    isolated remote function onCustomersUpdate(CustomerEvent payload) returns error? {
        lock {
            triggerFired["CustomersService.onCustomersUpdate"] = true;
        }
    }

    isolated remote function onCustomersDisable(CustomerEvent payload) returns error? {
        lock {
            triggerFired["CustomersService.onCustomersDisable"] = true;
        }
    }

    isolated remote function onCustomersCreate(CustomerEvent payload) returns error? {
        lock {
            triggerFired["CustomersService.onCustomersCreate"] = true;
        }
    }
}

service ProductsService on triggerTestListener {
    isolated remote function onProductsUpdate(ProductEvent payload) returns error? {
        lock {
            triggerFired["ProductsService.onProductsUpdate"] = true;
        }
    }

    isolated remote function onProductsCreate(ProductEvent payload) returns error? {
        lock {
            triggerFired["ProductsService.onProductsCreate"] = true;
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

@test:Config {}
function testFulfillmentsCreateDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("fulfillments/create", "fulfillments/create");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("FulfillmentsService.onFulfillmentsCreate"), "FulfillmentsService.onFulfillmentsCreate should have fired");
}

@test:Config {}
function testFulfillmentsUpdateDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("fulfillments/update", "fulfillments/update");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("FulfillmentsService.onFulfillmentsUpdate"), "FulfillmentsService.onFulfillmentsUpdate should have fired");
}

@test:Config {}
function testOrdersFulfilledDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("orders/fulfilled", "orders/fulfilled");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("OrdersService.onOrdersFulfilled"), "OrdersService.onOrdersFulfilled should have fired");
}

@test:Config {}
function testOrdersPartiallyFulfilledDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("orders/partially_fulfilled", "orders/partially_fulfilled");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("OrdersService.onOrdersPartiallyFulfilled"), "OrdersService.onOrdersPartiallyFulfilled should have fired");
}

@test:Config {}
function testOrdersCancelledDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("orders/cancelled", "orders/cancelled");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("OrdersService.onOrdersCancelled"), "OrdersService.onOrdersCancelled should have fired");
}

@test:Config {}
function testOrdersCreateDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("orders/create", "orders/create");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("OrdersService.onOrdersCreate"), "OrdersService.onOrdersCreate should have fired");
}

@test:Config {}
function testOrdersUpdatedDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("orders/updated", "orders/updated");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("OrdersService.onOrdersUpdated"), "OrdersService.onOrdersUpdated should have fired");
}

@test:Config {}
function testOrdersPaidDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("orders/paid", "orders/paid");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("OrdersService.onOrdersPaid"), "OrdersService.onOrdersPaid should have fired");
}

@test:Config {}
function testCustomersMarketingConsentUpdateDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("customers_marketing_consent/update", "customers_marketing_consent/update");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("CustomersService.onCustomersMarketingConsentUpdate"), "CustomersService.onCustomersMarketingConsentUpdate should have fired");
}

@test:Config {}
function testCustomersEnableDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("customers/enable", "customers/enable");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("CustomersService.onCustomersEnable"), "CustomersService.onCustomersEnable should have fired");
}

@test:Config {}
function testCustomersUpdateDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("customers/update", "customers/update");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("CustomersService.onCustomersUpdate"), "CustomersService.onCustomersUpdate should have fired");
}

@test:Config {}
function testCustomersDisableDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("customers/disable", "customers/disable");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("CustomersService.onCustomersDisable"), "CustomersService.onCustomersDisable should have fired");
}

@test:Config {}
function testCustomersCreateDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("customers/create", "customers/create");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("CustomersService.onCustomersCreate"), "CustomersService.onCustomersCreate should have fired");
}

@test:Config {}
function testProductsUpdateDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("products/update", "products/update");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("ProductsService.onProductsUpdate"), "ProductsService.onProductsUpdate should have fired");
}

@test:Config {}
function testProductsCreateDispatch() returns error? {
    http:Response response = check sendSignedTriggerWebhook("products/create", "products/create");
    test:assertEquals(response.statusCode, http:STATUS_OK);
    test:assertTrue(waitForDispatch("ProductsService.onProductsCreate"), "ProductsService.onProductsCreate should have fired");
}

