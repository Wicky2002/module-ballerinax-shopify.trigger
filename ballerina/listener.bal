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

import ballerina/cloud;
import ballerina/http;

@display {label: "Shopify Events API", iconPath: "icon.png"}
public class Listener {
    private http:Listener httpListener;
    private DispatcherService dispatcherService;

    public function init(ListenerConfig listenerConfig = {}, @cloud:Expose int|http:Listener listenOn = 8090) returns error? {
        if listenOn is http:Listener {
            self.httpListener = listenOn;
        } else {
            self.httpListener = check new (listenOn);
        }
        self.dispatcherService = new DispatcherService(listenerConfig.webhookSecret);
        check self.httpListener.attach(self.dispatcherService, ());
    }

    public isolated function attach(GenericServiceType serviceRef, () attachPoint) returns error? {
        string serviceTypeStr = check self.getServiceTypeStr(serviceRef);
        check self.dispatcherService.addServiceRef(serviceTypeStr, serviceRef);
    }

    public isolated function detach(GenericServiceType serviceRef) returns error? {
        string serviceTypeStr = check self.getServiceTypeStr(serviceRef);
        check self.dispatcherService.removeServiceRef(serviceTypeStr);
    }

    public isolated function 'start() returns error? {
        return self.httpListener.'start();
    }

    public isolated function gracefulStop() returns error? {
        return self.httpListener.gracefulStop();
    }

    public isolated function immediateStop() returns error? {
        return self.httpListener.immediateStop();
    }

    private isolated function getServiceTypeStr(GenericServiceType serviceRef) returns string|error {
        match serviceRef {
            var v if v is OrdersService => {
                return "OrdersService";
            }
            var v if v is ProductsService => {
                return "ProductsService";
            }
            var v if v is CustomersService => {
                return "CustomersService";
            }
            var v if v is FulfillmentsService => {
                return "FulfillmentsService";
            }
            var _ => {
                return error("Unrecognized service type attached to the listener");
            }
        }
    }
}
