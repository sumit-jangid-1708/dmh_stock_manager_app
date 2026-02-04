import 'order_detail_by_id_model.dart';
import 'order_detail_ui_model.dart';
import 'order_model.dart';

class OrderDetailAdapter {

  static OrderDetailUIModel merge(
      OrderDetailModel oldOrder,
      OrderDetailByIdModel newOrder,
      ) {
    return OrderDetailUIModel(
      orderId: oldOrder.id,
      customerName: oldOrder.customerName,
      customerEmail: oldOrder.customerEmail,
      createdAt: oldOrder.createdAt,
      remarks: oldOrder.remarks,
      channel: oldOrder.channel,
      countryCode: oldOrder.countryCode,
      mobile: oldOrder.mobile,
      channelOrderId: oldOrder.channelOrderId,
      paymentMethod: oldOrder.paymentMethod,
      paymentDate: oldOrder.paymentDate,
      paidStatus: oldOrder.paidStatus,
      transactionId: oldOrder.transactionId,

      items: newOrder.items.map((item) {
        return OrderItemUIModel(
          productId: item.productId,
          productName: item.productName,
          sku: item.sku,
          quantity: item.orderedQuantity,
          unitPrice: item.unitPrice,
          stockLeft: item.stockLeft,
          barcodes: item.barcodes,
        );
      }).toList(),
    );
  }
}