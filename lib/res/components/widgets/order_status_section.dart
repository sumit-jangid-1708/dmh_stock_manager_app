import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../model/order_models/order_detail_model.dart';
import '../../../model/order_models/order_status_log_model.dart';
import '../../../view/orders/shipping_detail_form.dart';
import '../../../view_models/controller/order_controller.dart';
import 'app_gradient _button.dart';
import 'courier_return_bottom_sheet.dart';
import 'customer_return_bottom_sheet.dart';
import 'package:dmj_stock_manager/res/components/widgets/package_form_widget.dart';

class OrderStatusSection extends StatelessWidget {
  const OrderStatusSection({
    super.key,
    required this.order,
    required this.orderId,
  });

  final OrderDetailsModel order; // fallback only
  final int orderId;

  // ── Status meta ───────────────────────────────────────────────────────────

  static const _statusLabels = {
    1: 'In Process',
    2: 'Packed',
    3: 'In Transit',
    4: 'Delivered',
    5: 'Courier Return',
    6: 'Customer Return',
  };
  static const _statusColors = {
    1: Color(0xFFFFF3CD),
    2: Color(0xFFD1ECF1),
    3: Color(0xFFCCE5FF),
    4: Color(0xFFD4EDDA),
    5: Color(0xFFF8D7DA),
    6: Color(0xFFFDE8D8),
  };
  static const _statusTextColors = {
    1: Color(0xFF7D5A00),
    2: Color(0xFF0C5460),
    3: Color(0xFF004085),
    4: Color(0xFF155724),
    5: Color(0xFF721C24),
    6: Color(0xFF7B3206),
  };
  static const _statusIcons = {
    1: Icons.settings_outlined,
    2: Icons.inventory_2_outlined,
    3: Icons.local_shipping_outlined,
    4: Icons.check_circle_outline,
    5: Icons.assignment_return_outlined,
    6: Icons.keyboard_return_outlined,
  };

  String _label(int s) => _statusLabels[s] ?? 'Unknown';
  Color _bg(int s) => _statusColors[s] ?? Colors.grey.shade100;
  Color _textColor(int s) => _statusTextColors[s] ?? Colors.grey.shade700;
  IconData _icon(int s) => _statusIcons[s] ?? Icons.info_outline;

  // ── ✅ KEY: Derive current status from logs API, not from order model ──────
  // Latest log by createdAt = current status
  int _currentStatusFromLogs(List<OrderStatusLog> logs) {
    if (logs.isEmpty) return order.orderStatus; // fallback to model
    final latest = logs.reduce(
          (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
    );
    return latest.status;
  }

  // Find log for a specific status step
  OrderStatusLog? _logFor(List<OrderStatusLog> logs, int status) =>
      logs.firstWhereOrNull((l) => l.status == status);

  String _formatLogDate(DateTime? dt) {
    if (dt == null) return 'Pending...';
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt.toLocal());
  }

  String _formatDate(DateTime dt) =>
      DateFormat('dd/MM/yyyy - HH:mm').format(dt.toLocal());

  // ── Timeline builder — uses real log timestamps ───────────────────────────

  List<_TimelineStep> _buildTimeline(
      int currentStatus, DateTime createdAt, List<OrderStatusLog> logs) {
    final steps = <_TimelineStep>[];

    // Step 0: Order Created (always present)
    steps.add(_TimelineStep(
      icon: Icons.add_circle_outline,
      title: 'Order Created',
      subtitle: DateFormat('dd MMM yyyy, hh:mm a').format(createdAt.toLocal()),
      isDone: true,
    ));

    // Step 1 → 2: Packed
    if (currentStatus >= 2) {
      final log = _logFor(logs, 2);
      steps.add(_TimelineStep(
        icon: Icons.inventory_2_outlined,
        title: 'Packed',
        subtitle: _formatLogDate(log?.createdAt),
        isDone: true,
      ));
    }

    // Step 2 → 3: In Transit
    if (currentStatus >= 3) {
      final log = _logFor(logs, 3);
      steps.add(_TimelineStep(
        icon: Icons.local_shipping_outlined,
        title: 'In Transit',
        subtitle: _formatLogDate(log?.createdAt),
        isDone: true,
      ));
    }

    // Terminal: Delivered
    if (currentStatus == 4) {
      final log = _logFor(logs, 4);
      steps.add(_TimelineStep(
        icon: Icons.check_circle_outline,
        title: 'Delivered',
        subtitle: _formatLogDate(log?.createdAt),
        isDone: true,
        isLast: true,
      ));
    }

    // Terminal: Courier Return
    if (currentStatus == 5) {
      final log = _logFor(logs, 5);
      steps.add(_TimelineStep(
        icon: Icons.assignment_return_outlined,
        title: 'Courier Return',
        subtitle: _formatLogDate(log?.createdAt),
        isDone: true,
        isReturn: true,
        isLast: true,
      ));
    }

    // Terminal: Customer Return
    if (currentStatus == 6) {
      final log = _logFor(logs, 6);
      steps.add(_TimelineStep(
        icon: Icons.keyboard_return_outlined,
        title: 'Customer Return',
        subtitle: _formatLogDate(log?.createdAt),
        isDone: true,
        isReturn: true,
        isLast: true,
      ));
    }

    // Pending next step
    if (currentStatus == 1) {
      steps.add(_TimelineStep(
        icon: Icons.inventory_2_outlined,
        title: 'Pack the Order',
        subtitle: 'Pending',
        isDone: false,
        isLast: true,
      ));
    } else if (currentStatus == 2) {
      steps.add(_TimelineStep(
        icon: Icons.local_shipping_outlined,
        title: 'Create Shipment',
        subtitle: 'Pending',
        isDone: false,
        isLast: true,
      ));
    } else if (currentStatus == 3) {
      steps.add(_TimelineStep(
        icon: Icons.check_circle_outline,
        title: 'Delivered / Returned',
        subtitle: 'Pending',
        isDone: false,
        isLast: true,
      ));
    }

    return steps;
  }

  // ── Timeline bottom sheet ─────────────────────────────────────────────────

  void _showTimeline(BuildContext context) {
    final ctrl = Get.find<OrderController>();
    final logs = ctrl.orderStatusLogs.toList();
    // ✅ Status derived from logs at tap time
    final currentStatus = _currentStatusFromLogs(logs);
    final createdAt =
        ctrl.orderDetail.value?.createdAt ?? order.createdAt;
    final steps = _buildTimeline(currentStatus, createdAt, logs);

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Order Timeline',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${steps.where((s) => s.isDone).length} of ${steps.length} steps completed',
                style:
                TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: logs.isEmpty
              // ✅ Show empty state if no logs yet
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_toggle_off,
                        size: 40, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'No status logs found',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: steps.length,
                itemBuilder: (_, i) =>
                    _TimelineItemWidget(step: steps[i]),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ── Next step buttons — driven by log-derived status ─────────────────────

  Widget _buildNextStepButtons(BuildContext context, int currentStatus) {
    final ctrl = Get.find<OrderController>();

    switch (currentStatus) {
      case 1:
        return AppGradientButton(
          onPressed: () =>
              PackOrderBottomSheet.show(context, orderId: orderId),
          text: 'Pack the Order',
          icon: Icons.inventory_2_outlined,
          width: double.infinity,
          height: 50,
        );

      case 2:
        return AppGradientButton(
          onPressed: () =>
              showShippingDetailsBottomSheet(context, orderId),
          text: 'Create Shipment',
          icon: Icons.local_shipping_outlined,
          width: double.infinity,
          height: 50,
        );

      case 3:
        return Column(
          children: [
            AppGradientButton(
              onPressed: () async => ctrl.updateOrderStatus(
                orderId: orderId,
                status: 4,
                note: "Delivered",
              ),
              text: 'Mark as Delivered',
              icon: Icons.check_circle_outline,
              width: double.infinity,
              height: 50,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppGradientButton(
                    onPressed: () {
                      final o = ctrl.orders
                          .firstWhereOrNull((o) => o.id == orderId);
                      if (o != null) showCourierReturnDialog(context, o);
                    },
                    text: 'Courier Return',
                    height: 50,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppGradientButton(
                    onPressed: () {
                      final o = ctrl.orders
                          .firstWhereOrNull((o) => o.id == orderId);
                      if (o != null) showCustomerReturnDialog(context, o);
                    },
                    text: 'Customer Return',
                    height: 50,
                  ),
                ),
              ],
            ),
          ],
        );

      case 4:
        return AppGradientButton(
          onPressed: () {
            final o =
            ctrl.orders.firstWhereOrNull((o) => o.id == orderId);
            if (o != null) showCustomerReturnDialog(context, o);
          },
          text: 'Customer Return',
          icon: Icons.keyboard_return_outlined,
          width: double.infinity,
          height: 50,
        );

      default: // 5, 6 — terminal, no button
        return const SizedBox.shrink();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OrderController>();

    return Obx(() {
      final logs = ctrl.orderStatusLogs; // ✅ reactive list from logs API
      final isLoadingLogs = ctrl.isLoadingStatusLogs.value;

      // ✅ Derive EVERYTHING from logs — not from order.orderStatus
      final currentStatus = _currentStatusFromLogs(logs.toList());
      final createdAt =
          ctrl.orderDetail.value?.createdAt ?? order.createdAt;

      final statusBg = _bg(currentStatus);
      final statusTextColor = _textColor(currentStatus);
      final statusIcon = _icon(currentStatus);
      final statusLabel = _label(currentStatus);

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section header ──
            Row(
              children: [
                Icon(statusIcon, size: 18, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Order Status',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                // ✅ Small loading indicator while logs refresh
                if (isLoadingLogs)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF1A1A4F)),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Status pill (tap → timeline) ──
            GestureDetector(
              onTap: () => _showTimeline(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 16, color: statusTextColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: statusTextColor,
                            ),
                          ),
                          Text(
                            _formatDate(createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: statusTextColor.withOpacity(0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.history_rounded,
                        size: 16,
                        color: statusTextColor.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text(
                      'View Log',
                      style: TextStyle(
                        fontSize: 11,
                        color: statusTextColor.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Packed dimensions card (shown when status >= 2) ───────────
            if (currentStatus >= 2) ...[
              const SizedBox(height: 12),
              Builder(builder: (_) {
                final packedLog =
                logs.firstWhereOrNull((l) => l.status == 2);
                final extra = packedLog?.extraData;
                if (extra == null) return const SizedBox.shrink();
                if (!extra.hasDimensions &&
                    (extra.image == null || extra.image!.isEmpty)) {
                  return const SizedBox.shrink();
                }
                return _PackedInfoCard(extra: extra);
              }),
            ],

            const SizedBox(height: 16),

            // ── Next step or terminal message ─────────────────────────────
            if (currentStatus < 5) ...[
              Text(
                'Next Step',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 10),
              // ✅ Passes log-derived status — buttons now match API truth
              _buildNextStepButtons(context, currentStatus),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 16, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Text(
                      'No further action required',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

// ── Packed Info Card ──────────────────────────────────────────────────────────

class _PackedInfoCard extends StatelessWidget {
  const _PackedInfoCard({required this.extra});
  final OrderStatusExtraData extra;

  @override
  Widget build(BuildContext context) {
    final dims = [
      if (extra.height?.isNotEmpty == true)
        _DimEntry('Height', '${extra.height} cm'),
      if (extra.width?.isNotEmpty == true)
        _DimEntry('Width', '${extra.width} cm'),
      if (extra.length?.isNotEmpty == true)
        _DimEntry('Length', '${extra.length} cm'),
      if (extra.weight?.isNotEmpty == true)
        _DimEntry('Weight', '${extra.weight} kg'),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1E0FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 14, color: Color(0xFF004085)),
              SizedBox(width: 6),
              Text(
                'Package Details',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF004085),
                ),
              ),
            ],
          ),
          if (dims.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
              dims.map((d) => _DimChip(label: d.label, value: d.value)).toList(),
            ),
          ],
          if (extra.image?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                extra.image!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                  height: 120,
                  color: Colors.grey.shade200,
                  child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorBuilder: (_, __, ___) => Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: Colors.grey)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DimEntry {
  final String label;
  final String value;
  const _DimEntry(this.label, this.value);
}

class _DimChip extends StatelessWidget {
  const _DimChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1E0FF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ',
              style:
              const TextStyle(fontSize: 11, color: Color(0xFF555577))),
          Text(value,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A4F))),
        ],
      ),
    );
  }
}

// ── Timeline data model ───────────────────────────────────────────────────────

class _TimelineStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDone;
  final bool isReturn;
  final bool isLast;

  const _TimelineStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDone,
    this.isReturn = false,
    this.isLast = false,
  });
}

// ── Timeline item widget ──────────────────────────────────────────────────────

class _TimelineItemWidget extends StatelessWidget {
  const _TimelineItemWidget({required this.step});
  final _TimelineStep step;

  @override
  Widget build(BuildContext context) {
    final dotColor = step.isReturn
        ? Colors.red.shade400
        : step.isDone
        ? const Color(0xFF1A1A4F)
        : Colors.grey.shade300;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: dotColor, shape: BoxShape.circle),
                  child: Icon(step.icon,
                      size: 15,
                      color:
                      step.isDone ? Colors.white : Colors.grey.shade400),
                ),
                if (!step.isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: step.isDone
                            ? const Color(0xFF1A1A4F).withOpacity(0.2)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: step.isDone
                          ? Colors.black87
                          : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(step.subtitle,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}