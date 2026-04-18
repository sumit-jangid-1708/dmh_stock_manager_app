import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../model/order_models/shipment_model.dart';
import '../../../view_models/controller/order_controller.dart';

class ShippingInfoCard extends StatelessWidget {
  const ShippingInfoCard({super.key, required this.orderId});
  final int orderId;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OrderController>();
    final orderWithShipment = ctrl.ordersWithShipments
        .firstWhereOrNull((o) => o.orderId == orderId);
    final shipments = orderWithShipment?.shipments ?? [];
    if (shipments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: shipments.map((s) => _ShipCard(shipment: s, ctrl: ctrl)).toList(),
    );
  }
}

class _ShipCard extends StatelessWidget {
  const _ShipCard({required this.shipment, required this.ctrl});
  final ShipmentModel shipment;
  final OrderController ctrl;

  @override
  Widget build(BuildContext context) {
    final courier = ctrl.courierPartners
        .firstWhereOrNull((c) => c.id == shipment.courierPartner);
    final mediator = courier?.mediators
        .firstWhereOrNull((m) => m.id == shipment.mediator);

    final shippingExp = double.tryParse(shipment.shippingExpense) ?? 0.0;
    final otherExp = double.tryParse(shipment.otherExpense) ?? 0.0;

    String formattedDate = shipment.shippingDate;
    try {
      formattedDate = DateFormat('dd MMM yyyy')
          .format(DateTime.parse(shipment.shippingDate));
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, size: 14, color: Color(0xFF1A1A4F)),
              const SizedBox(width: 6),
              const Text('Shipment Details',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A4F))),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          _Row('Courier', courier?.title ?? '—'),
          _Row('Mediator', mediator?.title ?? '—'),
          if (shipment.trackingId.isNotEmpty) _Row('Tracking ID', shipment.trackingId),
          if (shipment.shippingDate.isNotEmpty) _Row('Ship Date', formattedDate),
          if (shippingExp > 0) _Row('Shipping Exp.', '₹${shippingExp.toStringAsFixed(2)}'),
          if (otherExp > 0) _Row('Other Exp.', '₹${otherExp.toStringAsFixed(2)}'),

          if (shipment.trackingUrl.isNotEmpty) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: shipment.trackingUrl));
                Get.snackbar('Copied', 'Tracking URL copied',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                    backgroundColor: const Color(0xFF1A1A4F),
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16));
              },
              child: Row(
                children: [
                  Icon(Icons.link_rounded, size: 13, color: Colors.blue.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(shipment.trackingUrl,
                        style: TextStyle(fontSize: 11, color: Colors.blue.shade600,
                            decoration: TextDecoration.underline),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  Icon(Icons.copy_rounded, size: 13, color: Colors.grey.shade400),
                ],
              ),
            ),
          ],

          if (shipment.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note_outlined, size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Expanded(child: Text(shipment.notes,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A4F))),
          ),
        ],
      ),
    );
  }
}