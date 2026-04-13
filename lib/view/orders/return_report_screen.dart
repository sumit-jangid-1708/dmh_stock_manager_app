import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../model/return_report_model.dart';
import '../../view_models/controller/return_controller.dart';

class ReturnReportScreen extends StatelessWidget {
  ReturnReportScreen({super.key});

  final ReturnController controller = Get.find<ReturnController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──

            Expanded(
              child: Obx(() {
                if (controller.isReportLoading.value && controller.returnReport.value == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1A1A4F)),
                  );
                }

                final report = controller.returnReport.value;

                if (report == null || report.results.isEmpty) {
                  return _EmptyReportState();
                }

                // ── Aggregate totals across all results ──
                final totalLoss = report.results.fold(0.0, (s, r) => s + r.totalLoss);
                final netLoss = report.results.fold(0.0, (s, r) => s + r.netLoss);
                final totalRefund = report.results.fold(0.0, (s, r) => s + r.refund);
                final damageLoss = report.results.fold(0.0, (s, r) => s + r.damageLoss);
                final claimReceived = report.results.fold(0.0, (s, r) => s + r.claimReceived);

                return RefreshIndicator(
                  onRefresh: controller.getReturnReport,
                  color: const Color(0xFF1A1A4F),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ── Loss Summary Card ──
                      _LossSummaryCard(
                        totalLoss: totalLoss,
                        netLoss: netLoss,
                        totalRefund: totalRefund,
                        damageLoss: damageLoss,
                        claimReceived: claimReceived,
                        orderCount: report.count,
                      ),
                      const SizedBox(height: 20),

                      // ── Section label ──
                      Row(
                        children: [
                          const Icon(Icons.receipt_long_outlined, size: 16, color: Color(0xFF1A1A4F)),
                          const SizedBox(width: 8),
                          Text(
                            "${report.count} Order${report.count != 1 ? 's' : ''} with Returns",
                            style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A4F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Order Cards ──
                      ...report.results.map((r) => _OrderReportCard(report: r)),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loss Summary Card
// ─────────────────────────────────────────────────────────────────────────────

class _LossSummaryCard extends StatelessWidget {
  const _LossSummaryCard({
    required this.totalLoss,
    required this.netLoss,
    required this.totalRefund,
    required this.damageLoss,
    required this.claimReceived,
    required this.orderCount,
  });

  final double totalLoss, netLoss, totalRefund, damageLoss, claimReceived;
  final int orderCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Header ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.analytics_outlined, color: Colors.red.shade600, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Loss Summary", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A4F))),
                  Text("Aggregated across all return orders", style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // ── Top: Total Loss + Net Loss (big numbers) ──
          Row(
            children: [
              Expanded(
                child: _BigMetric(
                  label: "Total Loss",
                  value: "₹${totalLoss.toStringAsFixed(2)}",
                  color: Colors.red.shade600,
                  bgColor: Colors.red.shade50,
                  icon: Icons.trending_down_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BigMetric(
                  label: "Net Loss",
                  value: "₹${netLoss.toStringAsFixed(2)}",
                  color: Colors.deepOrange.shade600,
                  bgColor: Colors.deepOrange.shade50,
                  icon: Icons.remove_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Bottom: 3 small metrics ──
          Row(
            children: [
              Expanded(child: _SmallMetric(label: "Total Refund", value: "₹${totalRefund.toStringAsFixed(2)}", color: Colors.green.shade700)),
              const SizedBox(width: 8),
              Expanded(child: _SmallMetric(label: "Damage Loss", value: "₹${damageLoss.toStringAsFixed(2)}", color: Colors.orange.shade700)),
              const SizedBox(width: 8),
              Expanded(child: _SmallMetric(label: "Claim Received", value: "₹${claimReceived.toStringAsFixed(2)}", color: Colors.blue.shade700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BigMetric extends StatelessWidget {
  const _BigMetric({required this.label, required this.value, required this.color, required this.bgColor, required this.icon});

  final String label, value;
  final Color color, bgColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _SmallMetric extends StatelessWidget {
  const _SmallMetric({required this.label, required this.value, required this.color});

  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order Report Card (Expandable)
// ─────────────────────────────────────────────────────────────────────────────

class _OrderReportCard extends StatelessWidget {
  const _OrderReportCard({required this.report});

  final ReturnReport report;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy').format(report.createdAt.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: EdgeInsets.zero,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Order header ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A4F).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "#${report.orderId}",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A1A4F)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        report.customerName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A4F)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // ── Loss chips ──
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _Chip(label: "Loss ₹${report.totalLoss.toStringAsFixed(0)}", color: Colors.red.shade600, bgColor: Colors.red.shade50),
                    _Chip(label: "Refund ₹${report.refund.toStringAsFixed(0)}", color: Colors.green.shade700, bgColor: Colors.green.shade50),
                    if (report.damageLoss > 0)
                      _Chip(label: "Damage ₹${report.damageLoss.toStringAsFixed(0)}", color: Colors.orange.shade700, bgColor: Colors.orange.shade50),
                  ],
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(formattedDate, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  const SizedBox(width: 12),
                  Icon(Icons.phone_outlined, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(report.mobile, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ),
            children: [
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Order Amount ──
                    _InfoRow(icon: Icons.receipt_outlined, label: "Order Amount", value: "₹${report.totalAmount.toStringAsFixed(2)}", valueColor: const Color(0xFF1A1A4F)),
                    _InfoRow(icon: Icons.trending_down_rounded, label: "Net Loss", value: "₹${report.netLoss.toStringAsFixed(2)}", valueColor: Colors.red.shade600),
                    if (report.claimReceived > 0)
                      _InfoRow(icon: Icons.verified_outlined, label: "Claim Received", value: "₹${report.claimReceived.toStringAsFixed(2)}", valueColor: Colors.blue.shade700),

                    const SizedBox(height: 16),

                    // ── Items ──
                    _SectionHeader(icon: Icons.inventory_2_outlined, title: "Ordered Items (${report.items.length})"),
                    const SizedBox(height: 8),
                    ...report.items.map((item) => _ItemTile(item: item)),

                    const SizedBox(height: 16),

                    // ── Returns ──
                    _SectionHeader(icon: Icons.assignment_return_outlined, title: "Returns (${report.returns.length})"),
                    const SizedBox(height: 8),
                    ...report.returns.map((ret) => _ReturnTile(entry: ret)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Item Tile
// ─────────────────────────────────────────────────────────────────────────────

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item});
  final ReturnItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A4F).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_bag_outlined, size: 18, color: Color(0xFF1A1A4F)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A4F)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text("SKU: ${item.sku}", style: TextStyle(fontSize: 10, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Qty: ${item.qty}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A1A4F))),
              Text("₹${item.unitPrice.toStringAsFixed(2)}", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Return Tile
// ─────────────────────────────────────────────────────────────────────────────

class _ReturnTile extends StatelessWidget {
  const _ReturnTile({required this.entry});
  final ReturnEntry entry;

  Color get _conditionColor {
    switch (entry.condition.toUpperCase()) {
      case 'SAFE': return Colors.green.shade600;
      case 'DAMAGED': return Colors.orange.shade700;
      case 'LOST': return Colors.red.shade600;
      default: return Colors.grey;
    }
  }

  Color get _typeColor => entry.type == 'customer_return' ? Colors.purple.shade600 : Colors.blue.shade600;
  Color get _typeBg => entry.type == 'customer_return' ? Colors.purple.shade50 : Colors.blue.shade50;
  String get _typeLabel => entry.type == 'customer_return' ? 'Customer' : 'Courier';

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy, hh:mm a').format(entry.date.toLocal());
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: _typeBg, borderRadius: BorderRadius.circular(6)),
                child: Text(_typeLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _typeColor)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _conditionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _conditionColor.withOpacity(0.4)),
                ),
                child: Text(entry.condition, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _conditionColor)),
              ),
              const Spacer(),
              Text("₹${entry.refundAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(entry.product, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A4F)), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            children: [
              Text("Qty: ${entry.qty}", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              const SizedBox(width: 12),
              Icon(Icons.access_time, size: 11, color: Colors.grey.shade500),
              const SizedBox(width: 3),
              Text(date, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small helpers
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF1A1A4F)),
        const SizedBox(width: 7),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A4F))),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value, required this.valueColor});
  final IconData icon;
  final String label, value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, required this.bgColor});
  final String label;
  final Color color, bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

class _EmptyReportState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart_outlined_rounded, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("No Return Reports Found", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
          const SizedBox(height: 6),
          Text("Returns will appear here once processed", style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}