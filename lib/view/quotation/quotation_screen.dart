import 'package:dmj_stock_manager/res/components/widgets/custom_text_field.dart';
import 'package:dmj_stock_manager/view/quotation/create_quotation_screen.dart';
import 'package:dmj_stock_manager/view/quotation/quotation_detail_screen.dart';
import 'package:dmj_stock_manager/view/quotation/saved_details_screen.dart';
import 'package:dmj_stock_manager/view/quotation/widgets/quotation_card.dart';
import 'package:dmj_stock_manager/view_models/controller/quotation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuotationScreen extends StatelessWidget {
  const QuotationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuotationController());
    final scrollController = ScrollController();
    const primaryColor = Color(0xFF1A1A4F);

    // Pagination listener
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        controller.getQuotationList();
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Quotations History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.resetForm();
          Get.to(() => const CreateQuotationScreen());
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Quote", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // 1. Top Action Buttons
          // 1. Saved Details Option
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: InkWell(
              onTap: () => Get.to(() => const SavedDetailsScreen()),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.folder_shared_outlined, color: primaryColor, size: 22),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "View Saved Company & Bank Details",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
          ),

          // 2. Custom Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: AppTextField(
              controller: controller.listSearchController,
              hintText: "Search by Quotation No. or Name",
              prefixIcon: Icons.search,
              isSearch: true,
            ),
          ),

          // 3. Quotation List
          Expanded(
            child: Obx(() {
              if (controller.isListLoading.value &&
                  controller.quotationsList.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }

              if (controller.quotationsList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No quotations found",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.getQuotationList(isRefresh: true),
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      controller.quotationsList.length +
                      (controller.hasNextPage.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < controller.quotationsList.length) {
                      final quotation = controller.quotationsList[index];
                      return QuotationCard(
                        quotation: quotation,
                        onTap: () {
                          if (quotation.id != null) {
                            Get.to(
                              () => QuotationDetailScreen(
                                quotationId: quotation.id!,
                              ),
                            );
                          }
                        },
                        onEdit: () async {
                          await controller.getQuotationDetail(quotation.id!);
                          if (controller.quotationDetail.value != null) {
                            controller.setQuotationForEdit(
                              controller.quotationDetail.value!,
                            );
                            Get.to(
                              () => CreateQuotationScreen(
                                isEdit: true,
                                quotId: quotation.id,
                              ),
                            );
                          }
                        },
                        onDelete: () =>
                            _confirmDelete(context, controller, quotation.id!),
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        ),
                      );
                    }
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1A1A4F).withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1A1A4F), size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A4F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    QuotationController controller,
    int id,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Quotation"),
        content: const Text("Are you sure you want to delete this quotation?"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteQuotation(id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
