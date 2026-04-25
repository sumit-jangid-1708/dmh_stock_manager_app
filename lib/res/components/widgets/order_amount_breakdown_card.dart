// lib/res/components/widgets/order_amount_breakdown_card.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../model/order_models/order_detail_model.dart';
import '../../../view_models/controller/order_controller.dart';

class OrderAmountBreakdownCard extends StatelessWidget {
  const OrderAmountBreakdownCard({super.key, required this.order});

  final OrderDetailsModel order;

  static const Color _primary    = Color(0xFF1A1A4F);
  static const Color _labelColor = Color(0xFF6B7280); // grey-500

  @override
  Widget build(BuildContext context) {
    final orderController  = Get.find<OrderController>();
    final itemsTotal       = orderController.calculateItemsTotal(order);
    final packageExpense   = order.total.packageExpense;
    final buyerShipping    = order.total.buyerShipmentCharges;
    final shippingExpense  = order.total.shipment.shippingExpense;
    final otherExpense     = order.total.shipment.otherExpense;
    final grandTotal       = orderController.calculateGrandTotal(order);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section title ─────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                'Bill Breakdown',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Rows ─────────────────────────────────────────────────────
          _Row(label: 'Items Total',       amount: itemsTotal),
          _Row(label: 'Packaging Charge',  amount: packageExpense),
          _Row(label: 'Buyer Shipping',    amount: buyerShipping),
          _Row(label: 'Shipping Expense',  amount: shippingExpense),
          _Row(label: 'Other Charges',     amount: otherExpense),

          const SizedBox(height: 10),
          const Divider(thickness: 1),
          const SizedBox(height: 10),

          // ── Grand Total ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.currency_rupee,
                        size: 16, color: _primary),
                    const SizedBox(width: 6),
                    const Text(
                      'Grand Total',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single amount row ─────────────────────────────────────────────────────
class _Row extends StatelessWidget {
  const _Row({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    // Hide rows that are exactly 0 to keep UI clean
    if (amount == 0.0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}