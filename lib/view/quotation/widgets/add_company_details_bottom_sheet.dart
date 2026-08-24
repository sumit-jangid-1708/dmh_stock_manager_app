import 'package:dmj_stock_manager/res/components/widgets/app_gradient _button.dart';
import 'package:dmj_stock_manager/res/components/widgets/custom_text_field.dart';
import 'package:dmj_stock_manager/view_models/controller/quotation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddCompanyDetailsBottomSheet extends StatelessWidget {
  const AddCompanyDetailsBottomSheet({super.key});

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
              controller.editingCompanyId.value != null
                  ? "Edit Company Details"
                  : "Company Details",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            )),
            const SizedBox(height: 4),
            Text(
              "Add your business information for the quotation",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            
            AppTextField(
              controller: controller.companyLabelController,
              hintText: "Label (e.g. My Primary Business)",
              prefixIcon: Icons.bookmark_border,
            ),
            const SizedBox(height: 16),
            
            AppTextField(
              controller: controller.companyNameController,
              hintText: "Company Name",
              prefixIcon: Icons.business,
            ),
            const SizedBox(height: 16),
            
            AppTextField(
              controller: controller.companyAddressController,
              hintText: "Full Address",
              prefixIcon: Icons.location_on_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            AppTextField(
              controller: controller.companyGstinController,
              hintText: "GSTIN",
              prefixIcon: Icons.receipt_long,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: controller.companyPhoneController,
                    hintText: "Phone Number",
                    prefixIcon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: controller.companyEmailController,
                    hintText: "Email Address",
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            AppTextField(
              controller: controller.companyTermsController,
              hintText: "Standard Terms & Conditions",
              prefixIcon: Icons.gavel_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            Obx(() => AppGradientButton(
              onPressed: controller.isSavingCompany.value
                  ? null
                  : () => controller.saveCompany(),
              text: controller.isSavingCompany.value
                  ? "SAVING..."
                  : (controller.editingCompanyId.value != null
                      ? "UPDATE DETAILS"
                      : "SAVE DETAILS"),
              width: double.infinity,
              height: 56,
            )),
          ],
        ),
      ),
    );
  }
}
