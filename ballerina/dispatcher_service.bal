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
import ballerina/log;
import ballerinax/asyncapi.native.handler;

service class DispatcherService {
    *http:Service;
    private map<GenericServiceType> services = {};
    private handler:NativeHandler nativeHandler = new ();
    private string? webhookSecret;

    function init(string? webhookSecret) {
        self.webhookSecret = webhookSecret;
    }

    isolated function addServiceRef(string serviceType, GenericServiceType genericService) returns error? {
        if (self.services.hasKey(serviceType)) {
            return error(string `Service of type ${serviceType} has already been attached`);
        }
        self.services[serviceType] = genericService;
    }

    isolated function removeServiceRef(string serviceType) returns error? {
        if (!self.services.hasKey(serviceType)) {
            return error(string `Cannot detach the service of type ${serviceType}. Service has not been attached to the listener before`);
        }
        _ = self.services.remove(serviceType);
    }

    resource function post .(http:Caller caller, http:Request request) returns error? {
        error? verifyResult = self.verifyWebhookSignature(request, self.webhookSecret);
        if verifyResult is error {
            http:Response r = new;
            r.statusCode = http:STATUS_UNAUTHORIZED;
            check caller->respond(r);
            return;
        }
        json payload = check request.getJsonPayload();
        string|error eventTypeResult = request.getHeader("X-Shopify-Topic");
        if eventTypeResult is error {
            http:Response badRequest = new;
            badRequest.statusCode = http:STATUS_BAD_REQUEST;
            check caller->respond(badRequest);
            return;
        }
        string eventType = eventTypeResult;
        http:Response ackResponse = new;
        ackResponse.statusCode = http:STATUS_OK;
        check caller->respond(ackResponse);
        boolean|error dispatchResult = self.matchRemoteFunc(payload, eventType);
        if dispatchResult is error {
            log:printError("DISPATCH_FAILED", dispatchResult);
        } else if !dispatchResult {
            log:printWarn("NO_HANDLER_FOR_EVENT", eventIdentifier = eventType);
        }
    }

    private isolated function verifyWebhookSignature(http:Request request, string? webhookSecret) returns error? {
        if webhookSecret is () {
            return error("Unauthorized: Webhook Secret Not Configured");
        }
        if !request.hasHeader("X-Shopify-Hmac-Sha256") {
            return error("Unauthorized: Missing Signature Header");
        }
        string receivedHeader = check request.getHeader("X-Shopify-Hmac-Sha256");
        map<string> extractedHeaderValues = {};
        int headerCursor = 0;
        extractedHeaderValues["signature"] = receivedHeader.substring(headerCursor);
        headerCursor = receivedHeader.length();
        if !extractedHeaderValues.hasKey("signature") {
            return error("Unauthorized: Missing Header Component: signature");
        }
        string payloadToHash = string `${check request.getTextPayload()}`;
        byte[] computedDigest = check crypto:hmacSha256(payloadToHash.toBytes(), webhookSecret.toBytes());
        string computedSignature = computedDigest.toBase64();
        string expectedHeader = string `${computedSignature}`;
        if !crypto:equalConstantTime(receivedHeader.toBytes(), expectedHeader.toBytes()) {
            return error("Unauthorized: Signature Mismatch");
        }
    }

    private isolated function matchRemoteFunc(json payload, string eventType) returns boolean|error {
        if check self.matchRemoteFuncForOrders(payload, eventType) {
            return true;
        }
        if check self.matchRemoteFuncForProducts(payload, eventType) {
            return true;
        }
        if check self.matchRemoteFuncForCustomers(payload, eventType) {
            return true;
        }
        if check self.matchRemoteFuncForFulfillments(payload, eventType) {
            return true;
        }
        return false;
    }

    private isolated function matchRemoteFuncForOrders(json payload, string eventIdentifier) returns boolean|error {
        match eventIdentifier {
            "orders/fulfilled" => {
                check self.executeRemoteFunc(payload, "orders/fulfilled", "OrdersService", "onOrdersFulfilled");
                return true;
            }
            "orders/partially_fulfilled" => {
                check self.executeRemoteFunc(payload, "orders/partially_fulfilled", "OrdersService", "onOrdersPartiallyFulfilled");
                return true;
            }
            "orders/cancelled" => {
                check self.executeRemoteFunc(payload, "orders/cancelled", "OrdersService", "onOrdersCancelled");
                return true;
            }
            "orders/create" => {
                check self.executeRemoteFunc(payload, "orders/create", "OrdersService", "onOrdersCreate");
                return true;
            }
            "orders/updated" => {
                check self.executeRemoteFunc(payload, "orders/updated", "OrdersService", "onOrdersUpdated");
                return true;
            }
            "orders/paid" => {
                check self.executeRemoteFunc(payload, "orders/paid", "OrdersService", "onOrdersPaid");
                return true;
            }
        }
        return false;
    }

    private isolated function matchRemoteFuncForProducts(json payload, string eventIdentifier) returns boolean|error {
        match eventIdentifier {
            "products/update" => {
                check self.executeRemoteFunc(payload, "products/update", "ProductsService", "onProductsUpdate");
                return true;
            }
            "products/create" => {
                check self.executeRemoteFunc(payload, "products/create", "ProductsService", "onProductsCreate");
                return true;
            }
        }
        return false;
    }

    private isolated function matchRemoteFuncForCustomers(json payload, string eventIdentifier) returns boolean|error {
        match eventIdentifier {
            "customers_marketing_consent/update" => {
                check self.executeRemoteFunc(payload, "customers_marketing_consent/update", "CustomersService", "onCustomersMarketingConsentUpdate");
                return true;
            }
            "customers/enable" => {
                check self.executeRemoteFunc(payload, "customers/enable", "CustomersService", "onCustomersEnable");
                return true;
            }
            "customers/update" => {
                check self.executeRemoteFunc(payload, "customers/update", "CustomersService", "onCustomersUpdate");
                return true;
            }
            "customers/disable" => {
                check self.executeRemoteFunc(payload, "customers/disable", "CustomersService", "onCustomersDisable");
                return true;
            }
            "customers/create" => {
                check self.executeRemoteFunc(payload, "customers/create", "CustomersService", "onCustomersCreate");
                return true;
            }
        }
        return false;
    }

    private isolated function matchRemoteFuncForFulfillments(json payload, string eventIdentifier) returns boolean|error {
        match eventIdentifier {
            "fulfillments/create" => {
                check self.executeRemoteFunc(payload, "fulfillments/create", "FulfillmentsService", "onFulfillmentsCreate");
                return true;
            }
            "fulfillments/update" => {
                check self.executeRemoteFunc(payload, "fulfillments/update", "FulfillmentsService", "onFulfillmentsUpdate");
                return true;
            }
        }
        return false;
    }

    private isolated function executeRemoteFunc(json payload, string eventName, string serviceTypeStr, string eventFunction) returns error? {
        GenericServiceType? genericService = self.services[serviceTypeStr];
        if genericService is GenericServiceType {
            any boundEvent = check self.nativeHandler.bindEventPayload(genericService, eventFunction, payload);
            check self.nativeHandler.invokeRemoteFunction(boundEvent, eventName, eventFunction, genericService);
        } else {
            log:printDebug("SERVICE_NOT_ATTACHED", serviceType = serviceTypeStr, eventName = eventName);
        }
    }
}
