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

import ballerina/log;
import ballerinax/shopify.trigger as shopify;

configurable shopify:ListenerConfig config = {
    webhookSecret: "xxxxxx"
};

listener shopify:Listener webhookListener = new (config, 8090);

// The minimal, canonical use case: log every Order lifecycle event.
service shopify:OrdersService on webhookListener {

    remote function onOrdersCreate(shopify:OrderEvent payload) returns error? {
        log:printInfo("Order created", id = payload.id, name = payload.name);
    }

    remote function onOrdersUpdated(shopify:OrderEvent payload) returns error? {
        log:printInfo("Order updated", id = payload.id, name = payload.name);
    }

    remote function onOrdersCancelled(shopify:OrderEvent payload) returns error? {
        log:printInfo("Order cancelled", id = payload.id, name = payload.name);
    }

    remote function onOrdersFulfilled(shopify:OrderEvent payload) returns error? {
        log:printInfo("Order fulfilled", id = payload.id, name = payload.name);
    }

    remote function onOrdersPartiallyFulfilled(shopify:OrderEvent payload) returns error? {
        log:printInfo("Order partially fulfilled", id = payload.id, name = payload.name);
    }

    remote function onOrdersPaid(shopify:OrderEvent payload) returns error? {
        log:printInfo("Order paid", id = payload.id, name = payload.name);
    }
}
