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

import ballerina/data.jsondata;

# Configuration for the webhook listener, including the secret used to verify incoming requests.
public type ListenerConfig record {
    # The secret used to verify incoming webhook signatures.
    string webhookSecret?;
};

# Address
public type Address record {
    # The customer's mailing address.
    string 'address1?;
    # An additional field for the customer's mailing address.
    string 'address2?;
    # The customer's city, town, or village.
    string city?;
    # The customer's company.
    string company?;
    # The customer's country.
    string country?;
    # The two-letter country code corresponding to the customer's country.
    @jsondata:Name {value: "country_code"}
    string countryCode?;
    # The customer's normalized country name.
    @jsondata:Name {value: "country_name"}
    string countryName?;
    # A unique identifier for the customer.
    @jsondata:Name {value: "customer_id"}
    int customerId?;
    # Returns true for each default address.
    boolean 'default?;
    # The customer's first name.
    @jsondata:Name {value: "first_name"}
    string firstName?;
    # A unique identifier for the address.
    int id?;
    # The customer's last name.
    @jsondata:Name {value: "last_name"}
    string lastName?;
    # The customer's first and last names.
    string name?;
    # The customer's phone number at this address.
    string phone?;
    # The customer's region name. Typically a province, a state, or a prefecture.
    string province?;
    # The two-letter code for the customer's region.
    @jsondata:Name {value: "province_code"}
    string provinceCode?;
    # The customer's postal code, also known as zip, postcode, Eircode, etc.
    string zip?;
};

# Order adjustment attached to the refund.
public type OrderAdjustment record {
    # The unique identifier for the order adjustment.
    int id?;
    # The unique identifier for the order that the order adjustment is associated with.
    @jsondata:Name {value: "order_id"}
    int orderId?;
    # The unique identifier for the refund that the order adjustment is associated with.
    @jsondata:Name {value: "refund_id"}
    int refundId?;
    # The value of the discrepancy between the calculated refund and the actual refund. If the kind property's value is
    # shipping_refund, then amount returns the value of shipping charges refunded to the customer.
    string amount?;
    # The taxes that are added to amount, such as applicable shipping taxes added to a shipping refund.
    @jsondata:Name {value: "tax_amount"}
    string taxAmount?;
    # The order adjustment type. Valid values are shipping_refund and refund_discrepancy.
    string kind?;
    # The reason for the order adjustment. To set this value, include discrepancy_reason when you create a refund.
    string reason?;
};

# The Customer resource stores information about a shop's customers, such as their contact details, their order
# history, and whether they've agreed to receive email marketing.
public type Customer record {
    # Whether the customer has consented to receive marketing material via email.
    @jsondata:Name {value: "accepts_marketing"}
    boolean acceptsMarketing?;
    # The date and time (ISO 8601 format) when the customer consented or objected to receiving marketing material by
    # email. Set this value whenever the customer consents or objects to marketing materials.
    @jsondata:Name {value: "accepts_marketing_updated_at"}
    string acceptsMarketingUpdatedAt?;
    # A list of the ten most recently updated addresses for the customer.
    Address[] addresses?;
    # The three-letter code (ISO 4217 format) for the currency that the customer used when they paid for their last
    # order. Defaults to the shop currency. Returns the shop currency for test orders.
    string currency?;
    # The date and time (ISO 8601 format) when the customer was created.
    @jsondata:Name {value: "created_at"}
    string createdAt?;
    # The customer's first name.
    @jsondata:Name {value: "first_name"}
    string firstName?;
    # The unique email address of the customer. Attempting to assign the same email address to multiple customers
    # returns an error.
    string email?;
    # Address
    @jsondata:Name {value: "default_address"}
    Address defaultAddress?;
    # A unique identifier for the customer.
    int id?;
    # The customer's last name.
    @jsondata:Name {value: "last_name"}
    string lastName?;
    # The ID of the customer's last order.
    @jsondata:Name {value: "last_order_id"}
    int lastOrderId?;
    # The name of the customer's last order. This is directly related to the name field on the Order resource.
    @jsondata:Name {value: "last_order_name"}
    string lastOrderName?;
    # Attaches additional metadata to a shop's resources
    Metafield metafield?;
    # The marketing subscription opt-in level (as described by the M3AAWG best practices guideline) that the customer
    # gave when they consented to receive marketing material by email. If the customer does not accept email marketing,
    # then this property will be set to null.
    @jsondata:Name {value: "marketing_opt_in_level"}
    string marketingOptInLevel?;
    # A unique identifier for the customer that's used with Multipass login.
    @jsondata:Name {value: "multipass_identifier"}
    string multipassIdentifier?;
    # A note about the customer.
    string note?;
    # The number of orders associated with this customer.
    @jsondata:Name {value: "orders_count"}
    int ordersCount?;
    # The unique phone number (E.164 format) for this customer. Attempting to assign the same phone number to multiple
    # customers returns an error. The property can be set using different formats, but each format must represent a
    # number that can be dialed from anywhere in the world.
    string phone?;
    # The marketing consent information when the customer consented to receiving marketing material by SMS. The phone
    # property is required to create a customer with SMS consent information and to perform an SMS update on a customer
    # that doesn't have a phone number recorded. The customer must have a unique phone number associated to the record.
    @jsondata:Name {value: "sms_marketing_consent"}
    SmsMarketingConsent smsMarketingConsent?;
    # The state of the customer's account with a shop. Default value is disabled.
    string state?;
    # Tags that the shop owner has attached to the customer, formatted as a string of comma-separated values. A customer
    # can have up to 250 tags. Each tag can have up to 255 characters.
    string tags?;
    # Whether the customer is exempt from paying taxes on their order. If true, then taxes won't be applied to an order
    # at checkout. If false, then taxes will be applied at checkout.
    @jsondata:Name {value: "tax_exempt"}
    boolean taxExempt?;
    # Whether the customer is exempt from paying specific taxes on their order. Canadian taxes only.
    @jsondata:Name {value: "tax_exemptions"}
    string[] taxExemptions?;
    # The total amount of money that the customer has spent across their order history.
    @jsondata:Name {value: "total_spent"}
    string totalSpent?;
    # The date and time (ISO 8601 format) when the customer information was last updated.
    @jsondata:Name {value: "updated_at"}
    string updatedAt?;
    # Whether the customer has verified their email address.
    @jsondata:Name {value: "verified_email"}
    boolean verifiedEmail?;
};

# The total tax applied to the order in shop and presentment currencies.
public type TotalTaxSet record {
    # The price object
    @jsondata:Name {value: "shop_money"}
    Price shopMoney?;
    # The price object
    @jsondata:Name {value: "presentment_money"}
    Price presentmentMoney?;
};

# Products are easier to sell if customers can see pictures of them, which is why there are product images.
public type ProductImage record {
    # The date and time when the product image was created. The API returns this value in ISO 8601 formatting.
    @jsondata:Name {value: "created_at"}
    string createdAt?;
    # A unique numeric identifier for the product image.
    int id?;
    # The order of the product image in the list. The first product image is at position 1 and is the "main" image for
    # the product.
    int position?;
    # The id of the product associated with the image.
    @jsondata:Name {value: "product_id"}
    int productId?;
    # An array of variant ids associated with the image.
    @jsondata:Name {value: "variant_ids"}
    int[] variantIds?;
    # Specifies the location of the product image. This parameter supports URL filters that you can use to retrieve
    # modified copies of the image. For example, add _small, to the filename to retrieve a scaled copy of the image at
    # 100 x 100 px (for example, ipod-nano_small.png), or add _2048x2048 to retrieve a copy of the image constrained at
    # 2048 x 2048 px resolution (for example, ipod-nano_2048x2048.png).
    string src?;
    # Width dimension of the image which is determined on upload.
    int width?;
    # Height dimension of the image which is determined on upload.
    int height?;
    # The date and time when the product image was last modified. The API returns this value in ISO 8601 format.
    @jsondata:Name {value: "updated_at"}
    string updatedAt?;
    # Admin GraphQL API ID.
    @jsondata:Name {value: "admin_graphql_api_id"}
    string adminGraphqlApiId?;
};

# Stacked discount application
public type DiscountApplication record {
    # The discount application type.Valid values:manual The discount was manually applied by the merchant (for example,
    # by using an app or creating a draft order).script: The discount was applied by a Shopify Script.discount_code: The
    # discount was applied by a discount code. = ['discount_code', 'manual', 'script']
    string 'type?;
    # The value of the discount application as a decimal. This represents the intention of the discount application
    string value?;
    # The type of the value = ['percentage', 'fixed_amount']
    @jsondata:Name {value: "value_type"}
    string valueType?;
    # The method by which the discount application value has been allocated to entitled lines. = ['across', 'each',
    # 'one']
    @jsondata:Name {value: "allocation_method"}
    string allocationMethod?;
    # The lines on the order, of the type defined by target_type, that the discount is allocated over = ['all',
    # 'entitled', 'explicit']
    @jsondata:Name {value: "target_selection"}
    string targetSelection?;
    # The type of line on the order that the discount is applicable on = ['line_item', 'shipping_line']
    @jsondata:Name {value: "target_type"}
    string targetType?;
    # The description of the discount application, as defined by the merchant or the Shopify Script. Available only for
    # manual and script discount applications
    string description?;
    # The title of the discount application, as defined by the merchant. Available only for manual discount applications
    string title?;
};

# The price of the line item in shop and presentment currencies.
public type PriceSet record {
    # The price object
    @jsondata:Name {value: "shop_money"}
    Price shopMoney?;
    # The price object
    @jsondata:Name {value: "presentment_money"}
    Price presentmentMoney?;
};

# The terms and conditions under which a payment should be processed.
public type PaymentTerms record {
    # The amount that is owed according to the payment terms.
    string amount?;
    # The presentment currency for the payment.
    string currency?;
    # The name of the selected payment terms template for the order.
    @jsondata:Name {value: "payment_terms_name"}
    string paymentTermsName?;
    # The type of selected payment terms template for the order.
    @jsondata:Name {value: "payment_terms_type"}
    string paymentTermsType?;
    # The number of days between the invoice date and due date that is defined in the selected payment terms template.
    @jsondata:Name {value: "due_in_days"}
    int dueInDays?;
    # An array of schedules associated to the payment terms.
    @jsondata:Name {value: "payment_schedules"}
    PaymentSchedule[] paymentSchedules?;
};

# The price of the shipping method in both shop and presentment currencies after line-level discounts have been
# applied.
public type DiscountedPriceSet record {
    # The price object
    @jsondata:Name {value: "shop_money"}
    Price shopMoney?;
    # The price object
    @jsondata:Name {value: "presentment_money"}
    Price presentmentMoney?;
};

# Tax line object, which details a tax applicable to the order.
public type TaxLine record {
    # The amount of tax to be charged in the shop currency.
    string price?;
    # The rate of tax to be applied.
    decimal rate?;
    # The name of the tax.
    string title?;
    # Whether the channel that submitted the tax line is liable for remitting. A value of null indicates unknown
    # liability for the tax line.
    @jsondata:Name {value: "channel_liable"}
    boolean channelLiable?;
};

public type CustomerEvent record {|
    # A unique identifier for the customer.
    int id?;
    # The unique email address of the customer. Attempting to assign the same email address to multiple customers
    # returns an error.
    string email?;
    # Whether the customer has consented to receive marketing material via email.
    @jsondata:Name {value: "accepts_marketing"}
    boolean acceptsMarketing?;
    # The date and time (ISO 8601 format) when the customer was created.
    @jsondata:Name {value: "created_at"}
    string createdAt?;
    # The date and time (ISO 8601 format) when the customer information was last updated.
    @jsondata:Name {value: "updated_at"}
    string updatedAt?;
    # The customer's first name.
    @jsondata:Name {value: "first_name"}
    string firstName?;
    # The customer's last name.
    @jsondata:Name {value: "last_name"}
    string lastName?;
    # The number of orders associated with this customer.
    @jsondata:Name {value: "orders_count"}
    int ordersCount?;
    # The state of the customer's account with a shop. Default value is disabled.
    string state?;
    # The total amount of money that the customer has spent across their order history.
    @jsondata:Name {value: "total_spent"}
    string totalSpent?;
    # The ID of the customer's last order.
    @jsondata:Name {value: "last_order_id"}
    int lastOrderId?;
    # A note about the customer.
    string note?;
    # Whether the customer has verified their email address.
    @jsondata:Name {value: "verified_email"}
    boolean verifiedEmail?;
    # A unique identifier for the customer that's used with Multipass login.
    @jsondata:Name {value: "multipass_identifier"}
    string multipassIdentifier?;
    # Whether the customer is exempt from paying taxes on their order. If true, then taxes won't be applied to an order
    # at checkout. If false, then taxes will be applied at checkout.
    @jsondata:Name {value: "tax_exempt"}
    boolean taxExempt?;
    # The unique phone number (E.164 format) for this customer. Attempting to assign the same phone number to multiple
    # customers returns an error. The property can be set using different formats, but each format must represent a
    # number that can be dialed from anywhere in the world.
    string phone?;
    # Tags that the shop owner has attached to the customer, formatted as a string of comma-separated values. A customer
    # can have up to 250 tags. Each tag can have up to 255 characters.
    string tags?;
    # The name of the customer's last order. This is directly related to the name field on the Order resource.
    @jsondata:Name {value: "last_order_name"}
    string lastOrderName?;
    # The three-letter code (ISO 4217 format) for the currency that the customer used when they paid for their last
    # order. Defaults to the shop currency. Returns the shop currency for test orders.
    string currency?;
    # A list of the ten most recently updated addresses for the customer.
    Address[] addresses?;
    # The date and time (ISO 8601 format) when the customer consented or objected to receiving marketing material by
    # email. Set this value whenever the customer consents or objects to marketing materials.
    @jsondata:Name {value: "accepts_marketing_updated_at"}
    string acceptsMarketingUpdatedAt?;
    # The marketing subscription opt-in level (as described by the M3AAWG best practices guideline) that the customer
    # gave when they consented to receive marketing material by email. If the customer does not accept email marketing,
    # then this property will be set to null.
    @jsondata:Name {value: "marketing_opt_in_level"}
    string marketingOptInLevel?;
    # The marketing consent information when the customer consented to receiving marketing material by SMS. The phone
    # property is required to create a customer with SMS consent information and to perform an SMS update on a customer
    # that doesn't have a phone number recorded. The customer must have a unique phone number associated to the record.
    @jsondata:Name {value: "sms_marketing_consent"}
    SmsMarketingConsent smsMarketingConsent?;
    # Admin GraphQL API ID
    @jsondata:Name {value: "admin_graphql_api_id"}
    string adminGraphqlApiId?;
    json...;
|};

# The total price of the order in shop and presentment currencies.
public type TotalPriceSet record {
    # The price object
    @jsondata:Name {value: "shop_money"}
    Price shopMoney?;
    # The price object
    @jsondata:Name {value: "presentment_money"}
    Price presentmentMoney?;
};

# The total of all line item prices in shop and presentment currencies.
public type TotalLineItemsPriceSet record {
    # The price object
    @jsondata:Name {value: "shop_money"}
    Price shopMoney?;
    # The price object
    @jsondata:Name {value: "presentment_money"}
    Price presentmentMoney?;
};

# The total amount allocated to the line item in the presentment currency. Instead of using this field, Shopify
# recommends using discount_allocations, which provides the same information.
public type TotalDiscountSet record {
    # The price object
    @jsondata:Name {value: "shop_money"}
    Price shopMoney?;
    # The price object
    @jsondata:Name {value: "presentment_money"}
    Price presentmentMoney?;
};

# The variant's presentment prices and compare-at prices in each of the shop's enabled presentment currencies.
public type PresentmentPrices record {
    # A list of the variant's presentment prices and compare-at prices in each of the shop's enabled presentment
    # currencies.
    @jsondata:Name {value: "presentment_prices"}
    PresentmentPrice[] presentmentPrices?;
};

# A variant can be added to a Product resource to represent one version of a product with several options. The
# Product resource will have a variant for every possible combination of its options. Each product can have a
# maximum of three options and a maximum of 100 variants.
public type ProductVariant record {
    # The barcode, UPC, or ISBN number for the product.
    string barcode?;
    # The original price of the item before an adjustment or a sale.
    @jsondata:Name {value: "compare_at_price"}
    string compareAtPrice?;
    # The date and time (ISO 8601 format) when the product variant was created.
    @jsondata:Name {value: "created_at"}
    string createdAt?;
    # The fulfillment service associated with the product variant. Valid values are manual or the handle of a
    # fulfillment service.
    @jsondata:Name {value: "fulfillment_service"}
    string fulfillmentService?;
    # The weight of the product variant in grams.
    int grams?;
    # The unique numeric identifier for the product variant.
    int id?;
    # The unique numeric identifier for a product's image. The image must be associated to the same product as the
    # variant.
    @jsondata:Name {value: "image_id"}
    int imageId?;
    # The unique identifier for the inventory item, which is used in the Inventory API to query for inventory
    # information.
    @jsondata:Name {value: "inventory_item_id"}
    int inventoryItemId?;
    # The fulfillment service that tracks the number of items in stock for the product variant.
    @jsondata:Name {value: "inventory_management"}
    string inventoryManagement?;
    # Whether customers are allowed to place an order for the product variant when it's out of stock.
    @jsondata:Name {value: "inventory_policy"}
    string inventoryPolicy?;
    # An aggregate of inventory across all locations. To adjust inventory at a specific location, use the InventoryLevel
    # resource.
    @jsondata:Name {value: "inventory_quantity"}
    int inventoryQuantity?;
    # This property is deprecated. Use the InventoryLevel resource instead.
    @jsondata:Name {value: "old_inventory_quantity"}
    int oldInventoryQuantity?;
    # This property is deprecated. Use the InventoryLevel resource instead.
    @jsondata:Name {value: "inventory_quantity_adjustment"}
    int inventoryQuantityAdjustment?;
    # The custom properties that a shop owner uses to define product variants. You can define three options for a
    # product variant are option1, option2, option3. Default value is Default Title. The title field is a concatenation
    # of the option1, option2, and option3 fields. Updating the option fields updates the title field.
    Option option?;
    # The variant's presentment prices and compare-at prices in each of the shop's enabled presentment currencies.
    @jsondata:Name {value: "presentment_prices"}
    PresentmentPrices presentmentPrices?;
    # The order of the product variant in the list of product variants. The first position in the list is 1. The
    # position of variants is indicated by the order in which they are listed.
    int position?;
    # The price of the product variant.
    string price?;
    # The unique numeric identifier for the product.
    @jsondata:Name {value: "product_id"}
    int productId?;
    # This property is deprecated. Use the `requires_shipping` property on the InventoryItem resource instead.
    @jsondata:Name {value: "requires_shipping"}
    boolean requiresShipping?;
    # A unique identifier for the product variant in the shop. Required in order to connect to a FulfillmentService.
    string sku?;
    # Whether a tax is charged when the product variant is sold.
    boolean taxable?;
    # This parameter applies only to the stores that have the Avalara AvaTax app installed. Specifies the Avalara tax
    # code for the product variant.
    @jsondata:Name {value: "tax_code"}
    string taxCode?;
    # The title of the product variant. The title field is a concatenation of the option1, option2, and option3 fields.
    # You can only update title indirectly using the option fields.
    string title?;
    # The date and time when the product variant was last modified. Gets returned in ISO 8601 formatting.
    @jsondata:Name {value: "updated_at"}
    string updatedAt?;
    # The weight of the product variant in the unit system specified with weight_unit.
    int weight?;
    # The unit of measurement that applies to the product variant's weight. If you don't specify a value for
    # weight_unit, then the shop's default unit of measurement is applied. Valid values are g, kg, oz, and lb.
    @jsondata:Name {value: "weight_unit"}
    string weightUnit?;
};

public type FulfillmentEvent record {|
    # The ID for the fulfillment.
    int id?;
    # The unique numeric identifier for the order.
    @jsondata:Name {value: "order_id"}
    int orderId?;
    # The status of the fulfillment.
    string status?;
    # The date and time when the fulfillment was created. The API returns this value in ISO 8601 format
    @jsondata:Name {value: "created_at"}
    string createdAt?;
    # The type of service used.
    string 'service?;
    # The date and time (ISO 8601 format) when the fulfillment was last modified.
    @jsondata:Name {value: "updated_at"}
    string updatedAt?;
    # The name of the tracking company.
    @jsondata:Name {value: "tracking_company"}
    string trackingCompany?;
    # The current shipment status of the fulfillment.
    @jsondata:Name {value: "shipment_status"}
    string shipmentStatus?;
    # The unique identifier of the location that the fulfillment should be processed for. To find the ID of the
    # location, use the Location resource.
    @jsondata:Name {value: "location_id"}
    int locationId?;
    # Address
    @jsondata:Name {value: "origin_address"}
    Address originAddress?;
    # Email.
    string email?;
    # Address
    Address destination?;
    # A historical record of each item in the fulfillment.
    @jsondata:Name {value: "line_items"}
    LineItem[] lineItems?;
    # A tracking number, provided by the shipping company.
    @jsondata:Name {value: "tracking_number"}
    string trackingNumber?;
    # A list of tracking numbers, provided by the shipping company.
    @jsondata:Name {value: "tracking_numbers"}
    string[] trackingNumbers?;
    # The URL of tracking pages for the fulfillment.
    @jsondata:Name {value: "tracking_url"}
    string trackingUrl?;
    # The URLs of tracking pages for the fulfillment.
    @jsondata:Name {value: "tracking_urls"}
    string[] trackingUrls?;
    # A text field that provides information about the receipt
    Receipt receipt?;
    # The uniquely identifying fulfillment name, consisting of two parts separated by a .. The first part represents the
    # order name and the second part represents the fulfillment number. The fulfillment number automatically increments
    # depending on how many fulfillments are in an order (e.g. #1001.1, #1001.2).
    string name?;
    # Admin GraphQL API ID.
    @jsondata:Name {value: "admin_graphql_api_id"}
    string adminGraphqlApiId?;
    json...;
|};

# Properties
public type Property record {
    # Property name
    string name?;
    # Property value
    string value?;
};

# Refunded line item
public type RefundLineItem record {
    # The unique identifier of the line item in the refund.
    int id?;
    # The ID of the related line item in the order.
    @jsondata:Name {value: "line_item_id"}
    int lineItemId?;
    # The quantity of the associated line item that was returned.
    int quantity?;
    # How this refund line item affects inventory levels.
    @jsondata:Name {value: "restock_type"}
    string restockType?;
    # The unique identifier of the location where the items will be restocked. Required when restock_type has the value
    # return or cancel.
    @jsondata:Name {value: "location_id"}
    int locationId?;
    # The subtotal of the refund line item.
    decimal subtotal?;
    # The total tax on the refund line item.
    @jsondata:Name {value: "total_tax"}
    decimal totalTax?;
};

public type ProductEvent record {|
    # An unsigned 64-bit integer that's used as a unique identifier for the product. Each id is unique across the
    # Shopify system. No two products will have the same id, even if they're from different shops.
    int id?;
    # The name of the product.
    string title?;
    # A description of the product. Supports HTML formatting.
    @jsondata:Name {value: "body_html"}
    string bodyHtml?;
    # The name of the product's vendor.
    string vendor?;
    # A categorization for the product used for filtering and searching products.
    @jsondata:Name {value: "product_type"}
    string productType?;
    # The date and time (ISO 8601 format) when the product was created.
    @jsondata:Name {value: "created_at"}
    string createdAt?;
    # A unique human-friendly string for the product. Automatically generated from the product's title. Used by the
    # Liquid templating language to refer to objects.
    string 'handle?;
    # The date and time (ISO 8601 format) when the product was last modified. A product's updated_at value can change
    # for different reasons. For example, if an order is placed for a product that has inventory tracking set up, then
    # the inventory adjustment is counted as an update.
    @jsondata:Name {value: "updated_at"}
    string updatedAt?;
    # The date and time (ISO 8601 format) when the product was published. Can be set to null to unpublish the product
    # from the Online Store channel.
    @jsondata:Name {value: "published_at"}
    string publishedAt?;
    # The suffix of the Liquid template used for the product page. If this property is specified, then the product page
    # uses a template called "product.suffix.liquid", where "suffix" is the value of this property. If this property is
    # "" or null, then the product page uses the default template "product.liquid". (default is null)
    @jsondata:Name {value: "template_suffix"}
    string templateSuffix?;
    # The status of the product.
    string status?;
    # Whether the product is published to the Point of Sale channel.
    @jsondata:Name {value: "published_scope"}
    string publishedScope?;
    # A string of comma-separated tags that are used for filtering and search. A product can have up to 250 tags. Each
    # tag can have up to 255 characters.
    string tags?;
    # Admin GraphQL API ID
    @jsondata:Name {value: "admin_graphql_api_id"}
    string adminGraphqlApiId?;
    # An array of product variants, each representing a different version of the product. The position property is
    # read-only. The position of variants is indicated by the order in which they are listed.
    ProductVariant[] variants?;
    # The custom product properties. For example, Size, Color, and Material. Each product can have up to 3 options and
    # each option value can be up to 255 characters. Product variants are made of up combinations of option values.
    # Options cannot be created without values. To create new options, a variant with an associated option value also
    # needs to be created.
    ProductOption[] options?;
    # A list of product image objects, each one representing an image associated with the product.
    ProductImage[] images?;
    json...;
|};

# The custom product properties. For example, Size, Color, and Material. Each product can have up to 3 options and
# each option value can be up to 255 characters.
public type ProductOption record {
    # Product option ID
    int id?;
    # Product option name
    string name?;
    # Product option position
    int position?;
    # Product option product ID
    @jsondata:Name {value: "product_id"}
    int productId?;
    # Product option values
    string[] values?;
};

# The total shipping price of the order, excluding discounts and returns, in shop and presentment currencies. If
# taxes_included is set to true, then total_shipping_price_set includes taxes.
public type TotalShippingPriceSet record {
    # The price object
    @jsondata:Name {value: "shop_money"}
    Price shopMoney?;
    # The price object
    @jsondata:Name {value: "presentment_money"}
    Price presentmentMoney?;
};

# A text field that provides information about the receipt
public type Receipt record {
    # Whether the fulfillment was a testcase.
    boolean testcase?;
    # The authorization code.
    string authorization?;
};

# The current total duties charged on the order in shop and presentment currencies. The amount values associated
# with this field reflect order edits, returns, and refunds.
public type CurrentTotalDutiesSet record {
    # The current total duties charged on the order in shop and presentment currencies. The amount values associated
    # with this field reflect order edits, returns, and refunds.
    @jsondata:Name {value: "current_total_duties_set"}
    CurrentTotalDutiesSetObject currentTotalDutiesSet?;
};

# Schedule associated to the payment terms
public type PaymentSchedule record {
    # The amount that is owed according to the payment terms.
    string amount?;
    # The presentment currency for the payment.
    string currency?;
    # The date and time when the payment terms were initiated.
    @jsondata:Name {value: "issued_at"}
    string issuedAt?;
    # The date and time when the payment is due. Calculated based on issued_at and due_in_days or a customized fixed
    # date if the type is fixed.
    @jsondata:Name {value: "due_at"}
    string dueAt?;
    # The date and time when the purchase is completed. Returns null initially and updates when the payment is captured.
    @jsondata:Name {value: "completed_at"}
    string completedAt?;
    # The name of the payment method gateway.
    @jsondata:Name {value: "expected_payment_method"}
    string expectedPaymentMethod?;
};

# An object, which details a shipping method used.
public type ShippingLine record {
    # A reference to the shipping method.
    string code?;
    # The price of the shipping method after line-level discounts have been applied. Doesn't reflect cart-level or
    # order-level discounts.
    @jsondata:Name {value: "discounted_price"}
    string discountedPrice?;
    # The price of the shipping method in both shop and presentment currencies after line-level discounts have been
    # applied.
    @jsondata:Name {value: "discounted_price_set"}
    DiscountedPriceSet discountedPriceSet?;
    # The price of this shipping method in the shop currency. Can't be negative.
    string price?;
    # The price of the line item in shop and presentment currencies.
    @jsondata:Name {value: "price_set"}
    PriceSet priceSet?;
    # The source of the shipping method.
    string 'source?;
    # The title of the shipping method.
    string title?;
    # A reference to the carrier service that provided the rate. Present when the rate was computed by a third-party
    # carrier service.
    @jsondata:Name {value: "carrier_identifier"}
    string carrierIdentifier?;
    # A reference to the fulfillment service that is being requested for the shipping method. Present if the shipping
    # method requires processing by a third party fulfillment service; null otherwise.
    @jsondata:Name {value: "requested_fulfillment_service_id"}
    string requestedFulfillmentServiceId?;
};

# Attaches additional metadata to a shop's resources
public type Metafield record {
    # An identifier for the metafield (maximum of 30 characters).
    string 'key;
    # A container for a set of metadata (maximum of 20 characters). Namespaces help distinguish between metadata that
    # you created and metadata created by another individual with a similar namespace.
    string namespace;
    # Information to be stored as metadata.
    string value;
    # The value type. Valid values are string and integer.
    @jsondata:Name {value: "value_type"}
    string valueType;
    # Additional information about the metafield.
    string description?;
};

# The total discounts applied to the price of the order in shop and presentment currencies.
public type TotalDiscountsSet record {
    # The price object
    @jsondata:Name {value: "shop_money"}
    Price shopMoney?;
    # The price object
    @jsondata:Name {value: "presentment_money"}
    Price presentmentMoney?;
};

# A historical record of each item in the fulfillment.
public type LineItem record {
    # The ID of the line item within the fulfillment.
    int id?;
    # The ID of the product variant being fulfilled.
    @jsondata:Name {value: "variant_id"}
    int variantId?;
    # The title of the product.
    string title?;
    # The number of items in the fulfillment.
    int quantity?;
    # The price of the item.
    string price?;
    # The weight of the item in grams.
    int grams?;
    # The unique identifier of the item in the fulfillment.
    string sku?;
    # The title of the product variant being fulfilled.
    @jsondata:Name {value: "variant_title"}
    string variantTitle?;
    # The name of the supplier of the item.
    string vendor?;
    # The service provider who is doing the fulfillment.
    @jsondata:Name {value: "fulfillment_service"}
    string fulfillmentService?;
    # The unique numeric identifier for the product in the fulfillment.
    @jsondata:Name {value: "product_id"}
    int productId?;
    # Whether a customer needs to provide a shipping address when placing an order for this product variant.
    @jsondata:Name {value: "requires_shipping"}
    boolean requiresShipping?;
    # Whether the line item is taxable.
    boolean taxable?;
    # Whether the line item is a gift card
    @jsondata:Name {value: "gift_card"}
    boolean giftCard?;
    # The name of the product variant.
    string name?;
    # The name of the inventory management system.
    @jsondata:Name {value: "variant_inventory_management"}
    string variantInventoryManagement?;
    # Any additional properties associated with the line item.
    Property[] properties?;
    # Whether the product exists.
    @jsondata:Name {value: "product_exists"}
    boolean productExists?;
    # The amount available to fulfill. This is the quantity - max (refunded_quantity, fulfilled_quantity) -
    # pending_fulfilled_quantity - open_fulfilled_quantity.
    @jsondata:Name {value: "fulfillable_quantity"}
    int fulfillableQuantity?;
    # The total of any discounts applied to the line item.
    @jsondata:Name {value: "total_discount"}
    string totalDiscount?;
    # The status of an order in terms of the line items being fulfilled. Valid values are fulfilled, null, or partial
    @jsondata:Name {value: "fulfillment_status"}
    string fulfillmentStatus?;
    # A unique identifier for a quantity of items within a single fulfillment. An order can have multiple fulfillment
    # line items.
    @jsondata:Name {value: "fulfillment_line_item_id"}
    int fulfillmentLineItemId?;
    # A list of tax line objects, each of which details the title, price, and rate of any taxes applied to the line
    # item.
    @jsondata:Name {value: "tax_lines"}
    TaxLine[] taxLines?;
};

# Discounts applied to the order
public type DiscountCode record {
    # The value of the discount deducted from the order total. The type field determines how this value is calculated
    string amount?;
    # The discount code
    string code?;
    # The type of discount. Can be one of: percentage, shipping, fixed_amount (default) = ['fixed_amount', 'percentage',
    # 'shipping']
    string 'type?;
};

# The current total duties charged on the order in shop and presentment currencies. The amount values associated
# with this field reflect order edits, returns, and refunds.
public type CurrentTotalDutiesSetObject record {
    # The price object
    @jsondata:Name {value: "shop_money"}
    Price shopMoney?;
    # The price object
    @jsondata:Name {value: "presentment_money"}
    Price presentmentMoney?;
};

# Extra information that is added to the order. Appears in the Additional details section of an order details page.
# Each array entry must contain a hash with name and value keys.
public type NoteAttribute record {
    # Name
    string name?;
    # Value
    string value?;
};

# You can use the Fulfillment resource to view, create, modify, or delete an order's or fulfillment order's
# fulfillments. A fulfillment order represents a group of one or more items in an order that are to be fulfilled
# from the same location. A fulfillment represents work that is completed as part of a fulfillment order and can
# include one or more items. You can use the Fulfillment resource to manage fulfillments for both orders and
# fulfillment orders.
public type Fulfillment record {
    # The date and time when the fulfillment was created. The API returns this value in ISO 8601 format
    @jsondata:Name {value: "created_at"}
    string createdAt?;
    # The ID for the fulfillment.
    int id?;
    # A historical record of each item in the fulfillment.
    @jsondata:Name {value: "line_items"}
    LineItem[] lineItems?;
    # The unique identifier of the location that the fulfillment should be processed for. To find the ID of the
    # location, use the Location resource.
    @jsondata:Name {value: "location_id"}
    int locationId?;
    # The uniquely identifying fulfillment name, consisting of two parts separated by a .. The first part represents the
    # order name and the second part represents the fulfillment number. The fulfillment number automatically increments
    # depending on how many fulfillments are in an order (e.g. #1001.1, #1001.2).
    string name?;
    # Whether the customer should be notified. If set to true, then an email will be sent when the fulfillment is
    # created or updated. For orders that were initially created using the API, the default value is false. For all
    # other orders, the default value is true.
    @jsondata:Name {value: "notify_customer"}
    string notifyCustomer?;
    # The unique numeric identifier for the order.
    @jsondata:Name {value: "order_id"}
    int orderId?;
    # Address
    @jsondata:Name {value: "origin_address"}
    Address originAddress?;
    # A text field that provides information about the receipt
    Receipt receipt?;
    # The type of service used.
    string 'service?;
    # The current shipment status of the fulfillment.
    @jsondata:Name {value: "shipment_status"}
    string shipmentStatus?;
    # The status of the fulfillment.
    string status?;
    # The name of the tracking company.
    @jsondata:Name {value: "tracking_company"}
    string trackingCompany?;
    # A list of tracking numbers, provided by the shipping company.
    @jsondata:Name {value: "tracking_numbers"}
    string[] trackingNumbers?;
    # The URLs of tracking pages for the fulfillment.
    @jsondata:Name {value: "tracking_urls"}
    string[] trackingUrls?;
    # The date and time (ISO 8601 format) when the fulfillment was last modified.
    @jsondata:Name {value: "updated_at"}
    string updatedAt?;
    # The name of the inventory management service.
    @jsondata:Name {value: "variant_inventory_management"}
    string variantInventoryManagement?;
};

# The original total duties charged on the order in shop and presentment currencies.
public type OriginalTotalDutiesSetObject record {
    # The price object
    @jsondata:Name {value: "shop_money"}
    Price shopMoney?;
    # The price object
    @jsondata:Name {value: "presentment_money"}
    Price presentmentMoney?;
};

# The marketing consent information when the customer consented to receiving marketing material by SMS. The phone
# property is required to create a customer with SMS consent information and to perform an SMS update on a customer
# that doesn't have a phone number recorded. The customer must have a unique phone number associated to the record.
public type SmsMarketingConsent record {
    # The current SMS marketing state for the customer.
    string state?;
    # The marketing subscription opt-in level, as described by the M3AAWG best practices guidelines, that the customer
    # gave when they consented to receive marketing material by SMS.
    @jsondata:Name {value: "opt_in_level"}
    string optInLevel?;
    # The date and time at which the customer consented to receive marketing material by SMS. The customer's consent
    # state reflects the consent record with the most recent last_consent_updated_at date. If no date is provided, then
    # the date and time at which the consent information was sent is used.
    @jsondata:Name {value: "consent_updated_at"}
    string consentUpdatedAt?;
    # The source for whether the customer has consented to receive marketing material by SMS.
    @jsondata:Name {value: "consent_collected_from"}
    string consentCollectedFrom?;
};

# Schedule associated to the payment terms
public type Refund record {
    # The date and time (ISO 8601 format) when the refund was created.
    @jsondata:Name {value: "created_at"}
    string createdAt?;
    # The unique identifier for the refund.
    int id?;
    # An optional note attached to a refund.
    string note?;
    # A list of order adjustments attached to the refund. Order adjustments are generated to account for refunded
    # shipping costs and differences between calculated and actual refund amounts.
    @jsondata:Name {value: "order_adjustments"}
    OrderAdjustment[] orderAdjustments?;
    # The date and time (ISO 8601 format) when the refund was imported. This value can be set to a date in the past when
    # importing from other systems. If no value is provided, then it will be auto-generated as the current time in
    # Shopify. Public apps need to be granted permission by Shopify to import orders with the processed_at timestamp set
    # to a value earlier the created_at timestamp. Private apps can't be granted permission by Shopify.
    @jsondata:Name {value: "processed_at"}
    string processedAt?;
    # A list of refunded line items.
    @jsondata:Name {value: "refund_line_items"}
    RefundLineItem[] refundLineItems?;
    # The unique identifier of the user who performed the refund.
    @jsondata:Name {value: "user_id"}
    int userId?;
};

# The price object
public type Price record {
    # The variant's price or compare-at price in the presentment currency.
    string amount?;
    # The three-letter code (ISO 4217 format) for one of the shop's enabled presentment currencies.
    @jsondata:Name {value: "currency_code"}
    string currencyCode?;
};

# The discount amount allocated to the line item in shop and presentment currencies.
public type AmountSet record {
    # The price object
    @jsondata:Name {value: "shop_money"}
    Price shopMoney?;
    # The price object
    @jsondata:Name {value: "presentment_money"}
    Price presentmentMoney?;
};

public type OrderEvent record {|
    # The ID of the order, used for API purposes. This is different from the order_number property, which is the ID used
    # by the shop owner and customer.
    int id?;
    # The customer's email address.
    string email?;
    # The date and time (ISO 8601 format) when the order was closed. Returns null if the order isn't closed.
    @jsondata:Name {value: "closed_at"}
    string closedAt?;
    # The autogenerated date and time (ISO 8601 format) when the order was created in Shopify. The value for this
    # property cannot be changed.
    @jsondata:Name {value: "created_at"}
    string createdAt?;
    # The date and time (ISO 8601 format) when the order was last modified. Filtering orders by updated_at is not an
    # effective method for fetching orders because its value can change when no visible fields of an order have been
    # updated. Use the Webhook and Event APIs to subscribe to order events instead.
    @jsondata:Name {value: "updated_at"}
    string updatedAt?;
    # The order's position in the shop's count of orders. Numbers are sequential and start at 1.
    int number?;
    # An optional note that a shop owner can attach to the order.
    string note?;
    # A unique value when referencing the order.
    string token?;
    # The payment gateway used.
    string gateway?;
    # Whether this is a test order.
    boolean test?;
    # The sum of all line item prices, discounts, shipping, taxes, and tips in the shop currency. Must be positive.
    @jsondata:Name {value: "total_price"}
    string totalPrice?;
    # The price of the order in the shop currency after discounts but before shipping, duties, taxes, and tips.
    @jsondata:Name {value: "subtotal_price"}
    string subtotalPrice?;
    # The sum of all line item weights in grams. The sum is not adjusted as items are removed from the order.
    @jsondata:Name {value: "total_weight"}
    decimal totalWeight?;
    # The sum of all the taxes applied to the order in the shop currency. Must be positive.
    @jsondata:Name {value: "total_tax"}
    string totalTax?;
    # Whether taxes are included in the order subtotal.
    @jsondata:Name {value: "taxes_included"}
    boolean taxesIncluded?;
    # The three-letter code (ISO 4217 format) for the shop currency.
    string currency?;
    # The status of payments associated with the order. Can only be set when the order is created.
    @jsondata:Name {value: "financial_status"}
    string financialStatus?;
    # Confirmation status
    boolean confirmed?;
    # The total discounts applied to the price of the order in the shop currency.
    @jsondata:Name {value: "total_discounts"}
    string totalDiscounts?;
    # The sum of all line item prices in the shop currency.
    @jsondata:Name {value: "total_line_items_price"}
    string totalLineItemsPrice?;
    # A unique value when referencing the cart that's associated with the order.
    @jsondata:Name {value: "cart_token"}
    string cartToken?;
    # Whether the customer consented to receive email updates from the shop.
    @jsondata:Name {value: "buyer_accepts_marketing"}
    boolean buyerAcceptsMarketing?;
    # The order name, generated by combining the order_number property with the order prefix and suffix that are set in
    # the merchant's general settings. This is different from the id property, which is the ID of the order used by the
    # API. This field can also be set by the API to be any string value.
    string name?;
    # The website where the customer clicked a link to the shop.
    @jsondata:Name {value: "referring_site"}
    string referringSite?;
    # The URL for the page where the buyer landed when they entered the shop.
    @jsondata:Name {value: "landing_site"}
    string landingSite?;
    # The date and time when the order was canceled. Returns null if the order isn't canceled.
    @jsondata:Name {value: "cancelled_at"}
    string cancelledAt?;
    # The reason why the order was canceled.
    @jsondata:Name {value: "cancel_reason"}
    string cancelReason?;
    # The sum of all line item prices, discounts, shipping, taxes, and tips in the shop currency. Must be positive.
    @jsondata:Name {value: "total_price_usd"}
    string totalPriceUsd?;
    # A unique value when referencing the checkout that's associated with the order.
    @jsondata:Name {value: "checkout_token"}
    string checkoutToken?;
    # The reference where the customer clicked a link to the shop.
    string reference?;
    # The ID of the user logged into Shopify POS who processed the order, if applicable.
    @jsondata:Name {value: "user_id"}
    int userId?;
    # The ID of the physical location where the order was processed. If you need to reference the location against an
    # order, then use the FulfillmentOrder resource.
    @jsondata:Name {value: "location_id"}
    int locationId?;
    # The source identifier
    @jsondata:Name {value: "source_identifier"}
    string sourceIdentifier?;
    # The source url
    @jsondata:Name {value: "source_url"}
    string sourceUrl?;
    # The date and time (ISO 8601 format) when an order was processed. This value is the date that appears on your
    # orders and that's used in the analytic reports. If you're importing orders from an app or another platform, then
    # you can set processed_at to a date and time in the past to match when the original order was created.
    @jsondata:Name {value: "processed_at"}
    string processedAt?;
    # The device ID
    @jsondata:Name {value: "device_id"}
    int deviceId?;
    # The customer's phone number for receiving SMS notifications.
    string phone?;
    # The two or three-letter language code, optionally followed by a region modifier.
    @jsondata:Name {value: "customer_locale"}
    string customerLocale?;
    # The ID of the app that created the order.
    @jsondata:Name {value: "app_id"}
    int appId?;
    # The IP address of the browser used by the customer when they placed the order. Both IPv4 and IPv6 are supported.
    @jsondata:Name {value: "browser_ip"}
    string browserIp?;
    # The URL for the page where the buyer landed when they entered the shop.
    @jsondata:Name {value: "landing_site_ref"}
    string landingSiteRef?;
    # The order 's position in the shop's count of orders starting at 1001. Order numbers are sequential and start at
    # 1001.
    @jsondata:Name {value: "order_number"}
    int orderNumber?;
    # An ordered list of stacked discount applications.
    @jsondata:Name {value: "discount_applications"}
    DiscountApplication[] discountApplications?;
    # A list of discounts applied to the order.
    @jsondata:Name {value: "discount_codes"}
    DiscountCode[] discountCodes?;
    # Extra information that is added to the order. Appears in the Additional details section of an order details page.
    # Each array entry must contain a hash with name and value keys.
    @jsondata:Name {value: "note_attributes"}
    NoteAttribute[] noteAttributes?;
    # The list of payment gateways used for the order.
    @jsondata:Name {value: "payment_gateway_names"}
    string[] paymentGatewayNames?;
    # How the payment was processed. It has the following valid values
    @jsondata:Name {value: "processing_method"}
    string processingMethod?;
    # Where the order originated. Can be set only during order creation, and is not writeable afterwards. Values for
    # Shopify channels are protected and cannot be assigned by other API clients: web, pos, shopify_draft_order, iphone,
    # and android. Orders created via the API can be assigned any other string of your choice. If unspecified, then new
    # orders are assigned the value of your app's ID.
    @jsondata:Name {value: "source_name"}
    string sourceName?;
    # The order's status in terms of fulfilled line items.
    @jsondata:Name {value: "fulfillment_status"}
    string fulfillmentStatus?;
    # An array of tax line objects, each of which details a tax applicable to the order. When creating an order through
    # the API, tax lines can be specified on the order or the line items but not both. Tax lines specified on the order
    # are split across the taxable line items in the created order.
    @jsondata:Name {value: "tax_lines"}
    TaxLine[] taxLines?;
    # Tags attached to the order, formatted as a string of comma-separated values. Tags are additional short
    # descriptors, commonly used for filtering and searching. Each individual tag is limited to 40 characters in length.
    string tags?;
    # The contact email address.
    @jsondata:Name {value: "contact_email"}
    string contactEmail?;
    # The URL pointing to the order status web page, if applicable.
    @jsondata:Name {value: "order_status_url"}
    string orderStatusUrl?;
    # The presentment currency that was used to display prices to the customer.
    @jsondata:Name {value: "presentment_currency"}
    string presentmentCurrency?;
    # The total of all line item prices in shop and presentment currencies.
    @jsondata:Name {value: "total_line_items_price_set"}
    TotalLineItemsPriceSet totalLineItemsPriceSet?;
    # The total discounts applied to the price of the order in shop and presentment currencies.
    @jsondata:Name {value: "total_discounts_set"}
    TotalDiscountsSet totalDiscountsSet?;
    # The total shipping price of the order, excluding discounts and returns, in shop and presentment currencies. If
    # taxes_included is set to true, then total_shipping_price_set includes taxes.
    @jsondata:Name {value: "total_shipping_price_set"}
    TotalShippingPriceSet totalShippingPriceSet?;
    # The subtotal of the order in shop and presentment currencies after discounts but before shipping, duties, taxes,
    # and tips.
    @jsondata:Name {value: "subtotal_price_set"}
    SubtotalPriceSet subtotalPriceSet?;
    # The total price of the order in shop and presentment currencies.
    @jsondata:Name {value: "total_price_set"}
    TotalPriceSet totalPriceSet?;
    # The total tax applied to the order in shop and presentment currencies.
    @jsondata:Name {value: "total_tax_set"}
    TotalTaxSet totalTaxSet?;
    # A list of line item objects, each containing information about an item in the order.
    @jsondata:Name {value: "line_items"}
    OrderLineItem[] lineItems?;
    # An array of fulfillments associated with the order. For more information, see the Fulfillment API.
    Fulfillment[] fulfillments?;
    # A list of refunds applied to the order. For more information, see the Refund API.
    Refund[] refunds?;
    # The sum of all the tips in the order in the shop currency.
    @jsondata:Name {value: "total_tip_received"}
    string totalTipReceived?;
    # The original total duties charged on the order in shop and presentment currencies.
    @jsondata:Name {value: "original_total_duties_set"}
    OriginalTotalDutiesSet originalTotalDutiesSet?;
    # The current total duties charged on the order in shop and presentment currencies. The amount values associated
    # with this field reflect order edits, returns, and refunds.
    @jsondata:Name {value: "current_total_duties_set"}
    CurrentTotalDutiesSet currentTotalDutiesSet?;
    # The terms and conditions under which a payment should be processed.
    @jsondata:Name {value: "payment_terms"}
    PaymentTerms paymentTerms?;
    # Admin GraphQL API ID.
    @jsondata:Name {value: "admin_graphql_api_id"}
    string adminGraphqlApiId?;
    # An array of objects, each of which details a shipping method used.
    @jsondata:Name {value: "shipping_lines"}
    ShippingLine[] shippingLines?;
    # The mailing address associated with the payment method. This address is an optional field that won't be available
    # on orders that do not require a payment method.
    @jsondata:Name {value: "billing_address"}
    CustomerAddress billingAddress?;
    # The mailing address associated with the payment method. This address is an optional field that won't be available
    # on orders that do not require a payment method.
    @jsondata:Name {value: "shipping_address"}
    CustomerAddress shippingAddress?;
    # The Customer resource stores information about a shop's customers, such as their contact details, their order
    # history, and whether they've agreed to receive email marketing.
    Customer customer?;
    json...;
|};

# The original total duties charged on the order in shop and presentment currencies.
public type OriginalTotalDutiesSet record {
    # The original total duties charged on the order in shop and presentment currencies.
    @jsondata:Name {value: "original_total_duties_set"}
    OriginalTotalDutiesSetObject originalTotalDutiesSet?;
};

# A historical record of each line item.
public type OrderLineItem record {
    # The ID of the line item within the fulfillment.
    int id?;
    # The ID of the product variant being fulfilled.
    @jsondata:Name {value: "variant_id"}
    int variantId?;
    # The title of the product.
    string title?;
    # The number of items in the fulfillment.
    int quantity?;
    # The unique identifier of the item in the fulfillment.
    string sku?;
    # The title of the product variant being fulfilled.
    @jsondata:Name {value: "variant_title"}
    string variantTitle?;
    # The name of the supplier of the item.
    string vendor?;
    # The service provider who is doing the fulfillment.
    @jsondata:Name {value: "fulfillment_service"}
    string fulfillmentService?;
    # The unique numeric identifier for the product in the fulfillment.
    @jsondata:Name {value: "product_id"}
    int productId?;
    # Whether a customer needs to provide a shipping address when placing an order for this product variant.
    @jsondata:Name {value: "requires_shipping"}
    boolean requiresShipping?;
    # Whether the line item is taxable.
    boolean taxable?;
    # Whether the line item is a gift card
    @jsondata:Name {value: "gift_card"}
    boolean giftCard?;
    # The name of the product variant.
    string name?;
    # The name of the inventory management system.
    @jsondata:Name {value: "variant_inventory_management"}
    string variantInventoryManagement?;
    # Any additional properties associated with the line item.
    Property[] properties?;
    # Whether the product exists.
    @jsondata:Name {value: "product_exists"}
    boolean productExists?;
    # The amount available to fulfill. This is the quantity - max (refunded_quantity, fulfilled_quantity) -
    # pending_fulfilled_quantity - open_fulfilled_quantity.
    @jsondata:Name {value: "fulfillable_quantity"}
    int fulfillableQuantity?;
    # The price of the item.
    string price?;
    # The price of the line item in shop and presentment currencies.
    @jsondata:Name {value: "price_set"}
    PriceSet priceSet?;
    # The weight of the item in grams.
    int grams?;
    # The total of any discounts applied to the line item.
    @jsondata:Name {value: "total_discount"}
    string totalDiscount?;
    # The status of an order in terms of the line items being fulfilled. Valid values are fulfilled, null, or partial
    @jsondata:Name {value: "fulfillment_status"}
    string fulfillmentStatus?;
    # A unique identifier for a quantity of items within a single fulfillment. An order can have multiple fulfillment
    # line items.
    @jsondata:Name {value: "fulfillment_line_item_id"}
    int fulfillmentLineItemId?;
    # A list of tax line objects, each of which details a tax applied to the item.
    @jsondata:Name {value: "tax_lines"}
    TaxLine[] taxLines?;
    # The payment gateway used to tender the tip, such as shopify_payments. Present only on tips
    @jsondata:Name {value: "tip_payment_gateway"}
    string tipPaymentGateway?;
    # The payment method used to tender the tip, such as Visa. Present only on tips.
    @jsondata:Name {value: "tip_payment_method"}
    string tipPaymentMethod?;
    # The total amount allocated to the line item in the presentment currency. Instead of using this field, Shopify
    # recommends using discount_allocations, which provides the same information.
    @jsondata:Name {value: "total_discount_set"}
    TotalDiscountSet totalDiscountSet?;
    # An ordered list of amounts allocated by discount applications. Each discount allocation is associated with a
    # particular discount application.
    @jsondata:Name {value: "discount_allocations"}
    DiscountAllocations[] discountAllocations?;
    # Address
    @jsondata:Name {value: "origin_location"}
    Address originLocation?;
    # Admin GraphQL API ID
    @jsondata:Name {value: "admin_graphql_api_id"}
    string adminGraphqlApiId?;
};

# The custom properties that a shop owner uses to define product variants. You can define three options for a
# product variant are option1, option2, option3. Default value is Default Title. The title field is a concatenation
# of the option1, option2, and option3 fields. Updating the option fields updates the title field.
public type Option record {
    # Option 1
    string 'option1?;
    # Option 2
    string 'option2?;
    # Option 3
    string 'option3?;
};

# The variant's presentment prices and compare-at prices in each of the shop's enabled presentment currencies.
public type PresentmentPrice record {
    # The price object
    Price price?;
    # The price object
    @jsondata:Name {value: "compare_at_price"}
    Price compareAtPrice?;
};

# The subtotal of the order in shop and presentment currencies after discounts but before shipping, duties, taxes,
# and tips.
public type SubtotalPriceSet record {
    # The price object
    @jsondata:Name {value: "shop_money"}
    Price shopMoney?;
    # The price object
    @jsondata:Name {value: "presentment_money"}
    Price presentmentMoney?;
};

# An ordered list of amounts allocated by discount applications. Each discount allocation is associated with a
# particular discount application.
public type DiscountAllocations record {
    # The discount amount allocated to the line in the shop currency.
    string amount?;
    # The index of the associated discount application in the order's
    @jsondata:Name {value: "discount_application_index"}
    int discountApplicationIndex?;
    # The discount amount allocated to the line item in shop and presentment currencies.
    @jsondata:Name {value: "amount_set"}
    AmountSet amountSet?;
};

# The mailing address associated with the payment method. This address is an optional field that won't be available
# on orders that do not require a payment method.
public type CustomerAddress record {
    # The street address of the billing address.
    string 'address1?;
    # An optional additional field for the street address of the billing address.
    string 'address2?;
    # The city, town, or village of the billing address.
    string city?;
    # The company of the person associated with the billing address.
    string company?;
    # The name of the country of the billing address.
    string country?;
    # The two-letter code (ISO 3166-1 format) for the country of the billing address.
    @jsondata:Name {value: "country_code"}
    string countryCode?;
    # The first name of the person associated with the payment method.
    @jsondata:Name {value: "first_name"}
    string firstName?;
    # The last name of the person associated with the payment method.
    @jsondata:Name {value: "last_name"}
    string lastName?;
    # The latitude of the billing address. Shopify sends a number although its documentation shows a string.
    Latitude latitude?;
    # The longitude of the billing address. Shopify sends a number although its documentation shows a string.
    Longitude longitude?;
    # The full name of the person associated with the payment method.
    string name?;
    # The phone number at the billing address.
    string phone?;
    # The name of the region (for example, province, state, or prefecture) of the billing address.
    string province?;
    # The two-letter abbreviation of the region of the billing address.
    @jsondata:Name {value: "province_code"}
    string provinceCode?;
    # The postal code (for example, zip, postcode, or Eircode) of the billing address.
    string zip?;
};

public type Latitude string|decimal;

public type Longitude string|decimal;

# The union of every possible webhook payload type this listener can receive.
public type GenericDataType Metafield|Address|OrderAdjustment|Customer|TotalTaxSet|ProductImage|DiscountApplication|PriceSet|PaymentTerms|DiscountedPriceSet|TaxLine|CustomerEvent|TotalPriceSet|TotalLineItemsPriceSet|TotalDiscountSet|PresentmentPrices|ProductVariant|FulfillmentEvent|Property|RefundLineItem|ProductEvent|ProductOption|TotalShippingPriceSet|Receipt|CurrentTotalDutiesSet|PaymentSchedule|ShippingLine|TotalDiscountsSet|LineItem|DiscountCode|CurrentTotalDutiesSetObject|NoteAttribute|Fulfillment|OriginalTotalDutiesSetObject|SmsMarketingConsent|Refund|Price|AmountSet|OrderEvent|OriginalTotalDutiesSet|OrderLineItem|Option|PresentmentPrice|SubtotalPriceSet|DiscountAllocations|CustomerAddress;
