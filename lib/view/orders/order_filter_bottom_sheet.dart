import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../view_models/controller/order_controller.dart';
import '../../view_models/controller/home_controller.dart';

class OrderFilterBottomSheet extends StatelessWidget {
  const OrderFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController orderController = Get.find<OrderController>();
    final HomeController homeController = Get.find<HomeController>();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Handle ──
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 16, 8),
                child: Row(
                  children: [
                    const Text(
                      "Filters",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A4F),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.black54),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // ── Filter Options ──
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  children: [
                    // ── Channel Section ──
                    _buildSectionTitle("Channel"),
                    Obx(() => Column(
                      children: [
                        _buildRadioOption<String?>(
                          "All Channels",
                          null,
                          orderController.selectedChannelFilter.value,
                          (val) => orderController.selectedChannelFilter.value = val,
                        ),
                        ...homeController.channels.map((channel) {
                          return _buildRadioOption<String?>(
                            channel.name,
                            channel.name,
                            orderController.selectedChannelFilter.value,
                            (val) => orderController.selectedChannelFilter.value = val,
                          );
                        }),
                      ],
                    )),
                    const SizedBox(height: 24),
                    
                    // ── Date Section ──
                    _buildSectionTitle("Date"),
                    Obx(() => Column(
                      children: [
                        _buildRadioOption<String>(
                          "All Time",
                          'all',
                          orderController.selectedDateFilter.value,
                          (val) => orderController.selectedDateFilter.value = val!,
                        ),
                        _buildRadioOption<String>(
                          "Today",
                          'today',
                          orderController.selectedDateFilter.value,
                          (val) => orderController.selectedDateFilter.value = val!,
                        ),
                        _buildRadioOption<String>(
                          "Yesterday",
                          'yesterday',
                          orderController.selectedDateFilter.value,
                          (val) => orderController.selectedDateFilter.value = val!,
                        ),
                        _buildRadioOption<String>(
                          "Last 7 Days",
                          'last7days',
                          orderController.selectedDateFilter.value,
                          (val) => orderController.selectedDateFilter.value = val!,
                        ),
                        _buildRadioOption<String>(
                          "This Month",
                          'thisMonth',
                          orderController.selectedDateFilter.value,
                          (val) => orderController.selectedDateFilter.value = val!,
                        ),
                        _buildRadioOption<String>(
                          "Custom Date Range",
                          'custom',
                          orderController.selectedDateFilter.value,
                          (val) async {
                            final range = await showDateRangePicker(
                              context: context,
                              initialDateRange: orderController.customDateRange.value,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF1A1A4F),
                                      onPrimary: Colors.white,
                                      onSurface: Color(0xFF1A1A4F),
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFF1A1A4F),
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (range != null) {
                              orderController.customDateRange.value = range;
                              orderController.selectedDateFilter.value = 'custom';
                            }
                          },
                        ),
                        if (orderController.selectedDateFilter.value == 'custom' &&
                            orderController.customDateRange.value != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 48, top: 4),
                            child: Text(
                              "${DateFormat('dd MMM yyyy').format(orderController.customDateRange.value!.start)} - ${DateFormat('dd MMM yyyy').format(orderController.customDateRange.value!.end)}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1A1A4F),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    )),
                    const SizedBox(height: 24),

                    // ── Sort Section ──
                    _buildSectionTitle("Sort"),
                    Obx(() => Column(
                      children: [
                        _buildRadioOption<String>(
                          "Newest First",
                          'newest',
                          orderController.selectedSort.value,
                          (val) => orderController.selectedSort.value = val!,
                        ),
                        _buildRadioOption<String>(
                          "Oldest First",
                          'oldest',
                          orderController.selectedSort.value,
                          (val) => orderController.selectedSort.value = val!,
                        ),
                      ],
                    )),
                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // ── Bottom Action Footer ──
              _buildBottomButtons(context, orderController),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildRadioOption<T>(String label, T value, T groupValue, Function(T) onTap) {
    final isSelected = value == groupValue;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => onTap(value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1A1A4F) : Colors.grey.shade300,
                    width: isSelected ? 6 : 2,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF1A1A4F) : Colors.black87,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_rounded, color: Color(0xFF1A1A4F), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, OrderController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                controller.clearFilters();
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFF1A1A4F), width: 1.5),
              ),
              child: const Text(
                "Reset",
                style: TextStyle(
                  color: Color(0xFF1A1A4F),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                controller.applyFilters();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A4F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Apply",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
