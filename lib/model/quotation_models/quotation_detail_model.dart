import 'package:dmj_stock_manager/model/quotation_models/bank_model.dart';
import 'package:dmj_stock_manager/model/quotation_models/company_model.dart';

class QuotationDetailModel {
  final int? id;
  final String? number;
  final String? customerName;
  final String? customerPhone;
  final String? quoteDate;
  final String? validUntil;
  final String? subtotal;
  final String? taxTotal;
  final String? shippingAmount;
  final String? grandTotal;
  final int? itemCount;
  final String? createdAt;
  final String? detailUrl;
  final String? pdfViewUrl;
  final String? pdfDownloadUrl;

  final String? customerEmail;
  final String? customerAddress;
  final String? customerGstin;
  final String? customerState;
  final String? customerStateCode;

  final String? consigneeName;
  final String? consigneeAddress;
  final String? consigneeGstin;
  final String? consigneeState;
  final String? consigneeStateCode;

  final String? paymentTerms;
  final String? buyerReference;
  final String? otherReferences;
  final String? dispatchedThrough;
  final String? destination;
  final String? deliveryTerms;
  final String? shipmentDetails;
  final String? notes;

  final CompanyModel? companyProfile;
  final BankModel? bankAccount;
  final int? companyProfileId;
  final int? bankAccountId;

  final List<QuotationItemDetailModel>? items;

  QuotationDetailModel({
    this.id,
    this.number,
    this.customerName,
    this.customerPhone,
    this.quoteDate,
    this.validUntil,
    this.subtotal,
    this.taxTotal,
    this.shippingAmount,
    this.grandTotal,
    this.itemCount,
    this.createdAt,
    this.detailUrl,
    this.pdfViewUrl,
    this.pdfDownloadUrl,
    this.customerEmail,
    this.customerAddress,
    this.customerGstin,
    this.customerState,
    this.customerStateCode,
    this.consigneeName,
    this.consigneeAddress,
    this.consigneeGstin,
    this.consigneeState,
    this.consigneeStateCode,
    this.paymentTerms,
    this.buyerReference,
    this.otherReferences,
    this.dispatchedThrough,
    this.destination,
    this.deliveryTerms,
    this.shipmentDetails,
    this.notes,
    this.companyProfile,
    this.bankAccount,
    this.companyProfileId,
    this.bankAccountId,
    this.items,
  });

  factory QuotationDetailModel.fromJson(Map<String, dynamic> json) {
    return QuotationDetailModel(
      id: json['id'],
      number: json['number'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      quoteDate: json['quote_date'],
      validUntil: json['valid_until'],
      subtotal: json['subtotal'],
      taxTotal: json['tax_total'],
      shippingAmount: json['shipping_amount'],
      grandTotal: json['grand_total'],
      itemCount: json['item_count'],
      createdAt: json['created_at'],
      detailUrl: json['detail_url'],
      pdfViewUrl: json['pdf_view_url'],
      pdfDownloadUrl: json['pdf_download_url'],
      customerEmail: json['customer_email'],
      customerAddress: json['customer_address'],
      customerGstin: json['customer_gstin'],
      customerState: json['customer_state'],
      customerStateCode: json['customer_state_code'],
      consigneeName: json['consignee_name'],
      consigneeAddress: json['consignee_address'],
      consigneeGstin: json['consignee_gstin'],
      consigneeState: json['consignee_state'],
      consigneeStateCode: json['consignee_state_code'],
      paymentTerms: json['payment_terms'],
      buyerReference: json['buyer_reference'],
      otherReferences: json['other_references'],
      dispatchedThrough: json['dispatched_through'],
      destination: json['destination'],
      deliveryTerms: json['delivery_terms'],
      shipmentDetails: json['shipment_details'],
      notes: json['notes'],
      companyProfile: json['company_profile'] != null
          ? CompanyModel.fromJson(json['company_profile'])
          : null,
      bankAccount: json['bank_account'] != null
          ? BankModel.fromJson(json['bank_account'])
          : null,
      companyProfileId: json['company_profile_id'],
      bankAccountId: json['bank_account_id'],
      items: (json['items'] as List?)
          ?.map(
            (item) => QuotationItemDetailModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'quote_date': quoteDate,
      'valid_until': validUntil,
      'subtotal': subtotal,
      'tax_total': taxTotal,
      'shipping_amount': shippingAmount,
      'grand_total': grandTotal,
      'item_count': itemCount,
      'created_at': createdAt,
      'detail_url': detailUrl,
      'pdf_view_url': pdfViewUrl,
      'pdf_download_url': pdfDownloadUrl,
      'customer_email': customerEmail,
      'customer_address': customerAddress,
      'customer_gstin': customerGstin,
      'customer_state': customerState,
      'customer_state_code': customerStateCode,
      'consignee_name': consigneeName,
      'consignee_address': consigneeAddress,
      'consignee_gstin': consigneeGstin,
      'consignee_state': consigneeState,
      'consignee_state_code': consigneeStateCode,
      'payment_terms': paymentTerms,
      'buyer_reference': buyerReference,
      'other_references': otherReferences,
      'dispatched_through': dispatchedThrough,
      'destination': destination,
      'delivery_terms': deliveryTerms,
      'shipment_details': shipmentDetails,
      'notes': notes,
      'company_profile': companyProfile?.toJson(),
      'bank_account': bankAccount?.toJson(),
      'company_profile_id': companyProfileId,
      'bank_account_id': bankAccountId,
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }
}

class QuotationItemDetailModel {
  final int? id;
  final int? productId;
  final String? productName;
  final String? sku;
  final String? hsnCode;
  final String? dueOn;
  final String? unit;
  final String? discountPercentage;
  final String? quantity;
  final String? unitPrice;
  final String? gstPercentage;
  final String? taxableAmount;
  final String? taxAmount;
  final String? totalAmount;

  QuotationItemDetailModel({
    this.id,
    this.productId,
    this.productName,
    this.sku,
    this.hsnCode,
    this.dueOn,
    this.unit,
    this.discountPercentage,
    this.quantity,
    this.unitPrice,
    this.gstPercentage,
    this.taxableAmount,
    this.taxAmount,
    this.totalAmount,
  });

  factory QuotationItemDetailModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return QuotationItemDetailModel(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      sku: json['sku'],
      hsnCode: json['hsn_code'],
      dueOn: json['due_on'],
      unit: json['unit'],
      discountPercentage: json['discount_percentage'],
      quantity: json['quantity'],
      unitPrice: json['unit_price'],
      gstPercentage: json['gst_percentage'],
      taxableAmount: json['taxable_amount'],
      taxAmount: json['tax_amount'],
      totalAmount: json['total_amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'sku': sku,
      'hsn_code': hsnCode,
      'due_on': dueOn,
      'unit': unit,
      'discount_percentage': discountPercentage,
      'quantity': quantity,
      'unit_price': unitPrice,
      'gst_percentage': gstPercentage,
      'taxable_amount': taxableAmount,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
    };
  }
}
