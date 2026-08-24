class GetQuotationDetailsResponseModel {
  final List<QuotationDetailsModel>? data;
  final int? count;
  final int? page;
  final int? limit;
  final bool? hasNext;

  GetQuotationDetailsResponseModel({
    this.data,
    this.count,
    this.page,
    this.limit,
    this.hasNext,
  });

  factory GetQuotationDetailsResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return GetQuotationDetailsResponseModel(
      data: (json['data'] as List?)
          ?.map(
            (e) => QuotationDetailsModel.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList(),
      count: json['count'],
      page: json['page'],
      limit: json['limit'],
      hasNext: json['has_next'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((e) => e.toJson()).toList(),
      'count': count,
      'page': page,
      'limit': limit,
      'has_next': hasNext,
    };
  }
}

class QuotationDetailsModel {
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

  QuotationDetailsModel({
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
  });

  factory QuotationDetailsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return QuotationDetailsModel(
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
    };
  }
}