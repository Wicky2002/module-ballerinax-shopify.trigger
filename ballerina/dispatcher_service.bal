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
        GenericDataType genericDataType = check payload.cloneWithType(GenericDataType);
        http:Response ackResponse = new;
        ackResponse.statusCode = http:STATUS_OK;
        check caller->respond(ackResponse);
        error? dispatchResult = self.matchRemoteFunc(genericDataType, eventType);
        if dispatchResult is error {
            log:printError("DISPATCH_FAILED", dispatchResult);
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

    private isolated function matchRemoteFunc(GenericDataType genericDataType, string eventType) returns error? {
        check self.matchRemoteFuncForOrders(genericDataType, eventType);
        check self.matchRemoteFuncForProducts(genericDataType, eventType);
        check self.matchRemoteFuncForCustomers(genericDataType, eventType);
        check self.matchRemoteFuncForFulfillments(genericDataType, eventType);
    }

    private isolated function matchRemoteFuncForOrders(GenericDataType genericDataType, string eventIdentifier) returns error? {
        match eventIdentifier {
            "orders/fulfilled" => {
                check self.executeRemoteFunc(genericDataType, "orders/fulfilled", "OrdersService", "onOrdersFulfilled");
            }
            "orders/partially_fulfilled" => {
                check self.executeRemoteFunc(genericDataType, "orders/partially_fulfilled", "OrdersService", "onOrdersPartiallyFulfilled");
            }
            "orders/cancelled" => {
                check self.executeRemoteFunc(genericDataType, "orders/cancelled", "OrdersService", "onOrdersCancelled");
            }
            "orders/create" => {
                check self.executeRemoteFunc(genericDataType, "orders/create", "OrdersService", "onOrdersCreate");
            }
            "orders/updated" => {
                check self.executeRemoteFunc(genericDataType, "orders/updated", "OrdersService", "onOrdersUpdated");
            }
            "orders/paid" => {
                check self.executeRemoteFunc(genericDataType, "orders/paid", "OrdersService", "onOrdersPaid");
            }
        }
    }

    private isolated function matchRemoteFuncForProducts(GenericDataType genericDataType, string eventIdentifier) returns error? {
        match eventIdentifier {
            "products/update" => {
                check self.executeRemoteFunc(genericDataType, "products/update", "ProductsService", "onProductsUpdate");
            }
            "products/create" => {
                check self.executeRemoteFunc(genericDataType, "products/create", "ProductsService", "onProductsCreate");
            }
        }
    }

    private isolated function matchRemoteFuncForCustomers(GenericDataType genericDataType, string eventIdentifier) returns error? {
        match eventIdentifier {
            "customers_marketing_consent/update" => {
                check self.executeRemoteFunc(genericDataType, "customers_marketing_consent/update", "CustomersService", "onCustomersMarketingConsentUpdate");
            }
            "customers/enable" => {
                check self.executeRemoteFunc(genericDataType, "customers/enable", "CustomersService", "onCustomersEnable");
            }
            "customers/update" => {
                check self.executeRemoteFunc(genericDataType, "customers/update", "CustomersService", "onCustomersUpdate");
            }
            "customers/disable" => {
                check self.executeRemoteFunc(genericDataType, "customers/disable", "CustomersService", "onCustomersDisable");
            }
            "customers/create" => {
                check self.executeRemoteFunc(genericDataType, "customers/create", "CustomersService", "onCustomersCreate");
            }
        }
    }

    private isolated function matchRemoteFuncForFulfillments(GenericDataType genericDataType, string eventIdentifier) returns error? {
        match eventIdentifier {
            "fulfillments/create" => {
                check self.executeRemoteFunc(genericDataType, "fulfillments/create", "FulfillmentsService", "onFulfillmentsCreate");
            }
            "fulfillments/update" => {
                check self.executeRemoteFunc(genericDataType, "fulfillments/update", "FulfillmentsService", "onFulfillmentsUpdate");
            }
        }
    }

    private isolated function executeRemoteFunc(GenericDataType genericEvent, string eventName, string serviceTypeStr, string eventFunction) returns error? {
        GenericServiceType? genericService = self.services[serviceTypeStr];
        if genericService is GenericServiceType {
            check self.nativeHandler.invokeRemoteFunction(genericEvent, eventName, eventFunction, genericService);
        }
    }
}
