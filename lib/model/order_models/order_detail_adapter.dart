import 'order_detail_by_id_model.dart';
import 'order_detail_ui_model.dart';
import 'order_model.dart';

class OrderDetailAdapter {
  /// ✅ Merge OLD API (OrderDetailModel) + NEW API (OrderBarcodeResponse)
  static OrderDetailUIModel merge(
    OrderDetailModel oldOrder,
    OrderBarcodeResponse barcodeResponse,
  ) {
    return OrderDetailUIModel(
      // ✅ All header/detail fields from OLD API
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

      // ✅ Items from NEW API (OrderBarcodeResponse with barcodes)
      items: _buildItemsWithBarcodes(oldOrder.items, barcodeResponse.barcodes),
    );
  }

  /// ✅ Helper: Combine old order items with new barcode data
  static List<OrderItemUIModel> _buildItemsWithBarcodes(
    List<OrderItem> oldItems,
    List<ProductBarcodeGroup> barcodeGroups,
  ) {
    return oldItems.map((orderItem) {
      // ✅ Find matching barcode group for this product
      final barcodeGroup = barcodeGroups.firstWhere(
        (group) => group.productId == orderItem.product.id,
        orElse: () => ProductBarcodeGroup(
          productId: orderItem.product.id,
          productName: orderItem.product.name,
          barcodes: [],
        ),
      );

      return OrderItemUIModel(
        productId: orderItem.product.id,
        productName: orderItem.product.name,
        sku: orderItem.product.sku,
        quantity: orderItem.quantity,
        unitPrice: double.tryParse(orderItem.unitPrice) ?? 0.0,
        // stockLeft: 0, // ✅ Not available in OrderBarcodeResponse
        barcodes: barcodeGroup.barcodes,
      );
    }).toList();
  }
}

// import 'order_detail_by_id_model.dart';
// import 'order_detail_ui_model.dart';
// import 'order_model.dart';
//
// class OrderDetailAdapter {
//
//   static OrderDetailUIModel merge(
//       OrderDetailModel oldOrder,
//       OrderDetailByIdModel newOrder,
//       ) {
//     return OrderDetailUIModel(
//       orderId: oldOrder.id,
//       customerName: oldOrder.customerName,
//       customerEmail: oldOrder.customerEmail,
//       createdAt: oldOrder.createdAt,
//       remarks: oldOrder.remarks,
//       channel: oldOrder.channel,
//       countryCode: oldOrder.countryCode,
//       mobile: oldOrder.mobile,
//       channelOrderId: oldOrder.channelOrderId,
//       paymentMethod: oldOrder.paymentMethod,
//       paymentDate: oldOrder.paymentDate,
//       paidStatus: oldOrder.paidStatus,
//       transactionId: oldOrder.transactionId,
//
//       items: newOrder.items.map((item) {
//         return OrderItemUIModel(
//           productId: item.productId,
//           productName: item.productName,
//           sku: item.sku,
//           quantity: item.orderedQuantity,
//           unitPrice: item.unitPrice,
//           stockLeft: item.stockLeft,
//           barcodes: item.barcodes,
//         );
//       }).toList(),
//     );
//   }
// }
