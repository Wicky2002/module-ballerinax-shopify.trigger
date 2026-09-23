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

// A different, logistics-sensitive case: alert when a fulfillment is created without a tracking
// number attached, since that's the one Fulfillment event worth paging someone over.
service shopify:FulfillmentsService on webhookListener {

    remote function onFulfillmentsCreate(shopify:FulfillmentEvent payload) returns error? {
        if payload.tracking_number is () {
            log:printWarn("Fulfillment created without a tracking number", id = payload.id,
                    orderId = payload.order_id);
            return;
        }
        log:printInfo("Fulfillment created", id = payload.id, orderId = payload.order_id,
                trackingNumber = payload.tracking_number);
    }

    remote function onFulfillmentsUpdate(shopify:FulfillmentEvent payload) returns error? {
        return;
    }
}
