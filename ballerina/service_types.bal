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

# Attachable service type exposing the OrdersService family of webhook events.
public type OrdersService service object {
    # Triggered on Orders fulfilled.
    # + payload - the OrderEvent webhook payload
    # + return - an error if handling the event fails
    remote function onOrdersFulfilled(OrderEvent payload) returns error?;

    # Triggered on Orders partially fulfilled.
    # + payload - the OrderEvent webhook payload
    # + return - an error if handling the event fails
    remote function onOrdersPartiallyFulfilled(OrderEvent payload) returns error?;

    # Triggered on Orders cancelled.
    # + payload - the OrderEvent webhook payload
    # + return - an error if handling the event fails
    remote function onOrdersCancelled(OrderEvent payload) returns error?;

    # Triggered on Orders create.
    # + payload - the OrderEvent webhook payload
    # + return - an error if handling the event fails
    remote function onOrdersCreate(OrderEvent payload) returns error?;

    # Triggered on Orders updated.
    # + payload - the OrderEvent webhook payload
    # + return - an error if handling the event fails
    remote function onOrdersUpdated(OrderEvent payload) returns error?;

    # Triggered on Orders paid.
    # + payload - the OrderEvent webhook payload
    # + return - an error if handling the event fails
    remote function onOrdersPaid(OrderEvent payload) returns error?;
};

# Attachable service type exposing the ProductsService family of webhook events.
public type ProductsService service object {
    # Triggered on Products update.
    # + payload - the ProductEvent webhook payload
    # + return - an error if handling the event fails
    remote function onProductsUpdate(ProductEvent payload) returns error?;

    # Triggered on Products create.
    # + payload - the ProductEvent webhook payload
    # + return - an error if handling the event fails
    remote function onProductsCreate(ProductEvent payload) returns error?;
};

# Attachable service type exposing the CustomersService family of webhook events.
public type CustomersService service object {
    # Triggered on Customers marketing consent update.
    # + payload - the CustomerEvent webhook payload
    # + return - an error if handling the event fails
    remote function onCustomersMarketingConsentUpdate(CustomerEvent payload) returns error?;

    # Triggered on Customers enable.
    # + payload - the CustomerEvent webhook payload
    # + return - an error if handling the event fails
    remote function onCustomersEnable(CustomerEvent payload) returns error?;

    # Triggered on Customers update.
    # + payload - the CustomerEvent webhook payload
    # + return - an error if handling the event fails
    remote function onCustomersUpdate(CustomerEvent payload) returns error?;

    # Triggered on Customers disable.
    # + payload - the CustomerEvent webhook payload
    # + return - an error if handling the event fails
    remote function onCustomersDisable(CustomerEvent payload) returns error?;

    # Triggered on Customers create.
    # + payload - the CustomerEvent webhook payload
    # + return - an error if handling the event fails
    remote function onCustomersCreate(CustomerEvent payload) returns error?;
};

# Attachable service type exposing the FulfillmentsService family of webhook events.
public type FulfillmentsService service object {
    # Triggered on Fulfillments create.
    # + payload - the FulfillmentEvent webhook payload
    # + return - an error if handling the event fails
    remote function onFulfillmentsCreate(FulfillmentEvent payload) returns error?;

    # Triggered on Fulfillments update.
    # + payload - the FulfillmentEvent webhook payload
    # + return - an error if handling the event fails
    remote function onFulfillmentsUpdate(FulfillmentEvent payload) returns error?;
};

# The union of every service type that can be attached to this listener.
public type GenericServiceType OrdersService|ProductsService|CustomersService|FulfillmentsService;

