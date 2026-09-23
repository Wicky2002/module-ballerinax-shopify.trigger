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

// Sync new customers and marketing-consent changes to a downstream CRM - a starting point for
// marketing automation. CustomersService declares more remote functions than these two - every
// one of them must still be implemented, even as a no-op, since Ballerina requires a complete
// implementation of the service type.
service shopify:CustomersService on webhookListener {

    remote function onCustomersCreate(shopify:CustomerEvent payload) returns error? {
        log:printInfo("New customer created, sync to CRM", id = payload.id, email = payload.email);
    }

    remote function onCustomersMarketingConsentUpdate(shopify:CustomerEvent payload) returns error? {
        log:printInfo("Marketing consent changed, update CRM subscription state",
                id = payload.id, email = payload.email);
    }

    remote function onCustomersUpdate(shopify:CustomerEvent payload) returns error? {
        return;
    }

    remote function onCustomersEnable(shopify:CustomerEvent payload) returns error? {
        return;
    }

    remote function onCustomersDisable(shopify:CustomerEvent payload) returns error? {
        return;
    }
}
