import 'package:dmj_stock_manager/res/components/widgets/app_gradient _button.dart';
import 'package:dmj_stock_manager/res/components/widgets/custom_text_field.dart';
import 'package:dmj_stock_manager/view_models/controller/quotation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddBankDetailsBottomSheet extends StatelessWidget {
  const AddBankDetailsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuotationController>();
    const primaryColor = Color(0xFF1A1A4F);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Obx(() => Text(
              controller.editingBankId.value != null
                  ? "Edit Bank Details"
                  : "Bank Details",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            )),
            const SizedBox(height: 4),
            Text(
              "Add bank account information for payments",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            
            AppTextField(
              controller: controller.bankLabelController,
              hintText: "Label (e.g. Primary Bank)",
              prefixIcon: Icons.bookmark_border,
            ),
            const SizedBox(height: 16),
            
            AppTextField(
              controller: controller.bankNameController,
              hintText: "Bank Name",
              prefixIcon: Icons.account_balance,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: controller.bankAccountHolderController,
              hintText: "Account Holder Name",
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            
            AppTextField(
              controller: controller.bankAccountNumberController,
              hintText: "Account Number",
              prefixIcon: Icons.numbers,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: controller.bankIfscController,
                    hintText: "IFSC Code",
                    prefixIcon: Icons.code,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: controller.bankBranchController,
                    hintText: "Branch Name",
                    prefixIcon: Icons.location_city_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            Obx(() => AppGradientButton(
              onPressed: controller.isSavingBank.value
                  ? null
                  : () => controller.saveBank(),
              text: controller.isSavingBank.value
                  ? "SAVING..."
                  : (controller.editingBankId.value != null
                      ? "UPDATE BANK DETAILS"
                      : "SAVE BANK DETAILS"),
              width: double.infinity,
              height: 56,
            )),
          ],
        ),
      ),
    );
  }
}
