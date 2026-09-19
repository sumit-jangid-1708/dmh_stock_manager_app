import 'package:dmj_stock_manager/model/product_models/product_model.dart';
import 'package:dmj_stock_manager/model/quotation_models/bank_model.dart';
import 'package:dmj_stock_manager/model/quotation_models/company_model.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient _button.dart';
import 'package:dmj_stock_manager/res/components/widgets/custom_searchable_dropdown.dart';
import 'package:dmj_stock_manager/res/components/widgets/custom_text_field.dart';
import 'package:dmj_stock_manager/view_models/controller/quotation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateQuotationScreen extends StatelessWidget {
  final bool isEdit;
  final int? quotId;
  const CreateQuotationScreen({super.key, this.isEdit = false, this.quotId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuotationController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Quotation' : 'Create Quotation'),
        backgroundColor: const Color(0xFF1A1A4F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isEdit)
                Obx(
                  () => controller.hasDraft.value
                      ? Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A4F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF1A1A4F).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.drafts_outlined,
                              color: Color(0xFF1A1A4F),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "You have a saved draft",
                                style: TextStyle(
                                  color: Color(0xFF1A1A4F),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => controller.restoreDraft(),
                              child: const Text(
                                "RESTORE",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              onPressed: () => controller.clearDraft(),
                              icon: const Icon(Icons.close, color: Colors.red),
                              tooltip: "Discard Draft",
                            ),
                          ],
                        ),
                      )
                      : const SizedBox.shrink(),
                ),
              _buildSectionHeader("Quotation Information"),
              _buildCard([
                CustomSearchableDropdown<CompanyModel>(
                  items: controller.companiesList,
                  selectedItem: controller.selectedCompany,
                  itemAsString: (company) => company.label?.isNotEmpty == true
                      ? "${company.label} - ${company.companyName ?? ''}"
                      : company.companyName ?? "Unnamed Company",
                  hintText: "Select Company Profile *",
                  prefixIcon: Icons.business_outlined,
                  searchHint: "Search company profiles...",
                ),
                const SizedBox(height: 16),
                CustomSearchableDropdown<BankModel>(
                  items: controller.banksList,
                  selectedItem: controller.selectedBankAccount,
                  itemAsString: (bank) {
                    final account = bank.accountNumber ?? "";
                    final suffix = account.length > 4
                        ? account.substring(account.length - 4)
                        : account;
                    final name = bank.label?.isNotEmpty == true
                        ? bank.label!
                        : bank.bankName ?? "Unnamed Bank";
                    return suffix.isEmpty ? name : "$name - •••• $suffix";
                  },
                  hintText: "Select Bank Account *",
                  prefixIcon: Icons.account_balance_outlined,
                  searchHint: "Search bank accounts...",
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: controller.quotationNumberController,
                  hintText: "Quotation Number",
                  prefixIcon: Icons.numbers,
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: controller.quoteDateController,
                        hintText: "Quote Date",
                        prefixIcon: Icons.calendar_today,
                        readOnly: true,
                        onTap: () => controller.chooseDate(
                          context,
                          controller.quoteDateController,
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: controller.validUntilController,
                        hintText: "Valid Until",
                        prefixIcon: Icons.event_available,
                        readOnly: true,
                        onTap: () => controller.chooseDate(
                          context,
                          controller.validUntilController,
                        ),
                      ),
                    ),
                  ],
                ),
              ]),

              _buildSectionHeader("Customer Details (Billing)"),
              _buildCard([
                AppTextField(
                  controller: controller.customerNameController,
                  hintText: "Customer Name",
                  prefixIcon: Icons.person,
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: controller.customerPhoneController,
                        hintText: "Phone",
                        prefixIcon: Icons.phone,
                        suffixIcon: Icons.contacts_outlined,
                        onSuffixTap: controller.pickContactNumber,
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            value!.isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: controller.customerEmailController,
                        hintText: "Email",
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: controller.customerAddressController,
                  hintText: "Billing Address",
                  prefixIcon: Icons.location_on,
                  maxLines: 2,
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: controller.customerGstinController,
                  hintText: "GSTIN",
                  prefixIcon: Icons.receipt_long,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomSearchableDropdown<String>(
                        items: controller.statesList,
                        selectedItem: controller.selectedCustomerState,
                        itemAsString: (item) => item,
                        hintText: "Select State",
                        prefixIcon: Icons.map,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: controller.customerStateCodeController,
                        hintText: "State Code",
                        prefixIcon: Icons.code,
                      ),
                    ),
                  ],
                ),
              ]),

              Obx(
                () => Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Checkbox(
                        value: controller.isSameAsBilling.value,
                        onChanged: (val) => controller.toggleSameAsBilling(val),
                        activeColor: const Color(0xFF1A1A4F),
                      ),
                      const Text(
                        "Consignee details same as billing details",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A4F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _buildSectionHeader("Consignee Details (Shipping)"),
              Obx(
                () => _buildCard([
                  AppTextField(
                    controller: controller.consigneeNameController,
                    hintText: "Consignee Name",
                    prefixIcon: Icons.person_outline,
                    enabled: !controller.isSameAsBilling.value,
                    validator: (value) =>
                        !controller.isSameAsBilling.value && value!.isEmpty
                        ? "Required"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: controller.consigneeAddressController,
                    hintText: "Shipping Address",
                    prefixIcon: Icons.local_shipping,
                    maxLines: 2,
                    enabled: !controller.isSameAsBilling.value,
                    validator: (value) =>
                        !controller.isSameAsBilling.value && value!.isEmpty
                        ? "Required"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: controller.consigneeGstinController,
                    hintText: "Consignee GSTIN",
                    prefixIcon: Icons.receipt,
                    enabled: !controller.isSameAsBilling.value,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomSearchableDropdown<String>(
                          items: controller.statesList,
                          selectedItem: controller.selectedConsigneeState,
                          itemAsString: (item) => item,
                          hintText: "Select State",
                          prefixIcon: Icons.map_outlined,
                          enabled: !controller.isSameAsBilling.value,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: controller.consigneeStateCodeController,
                          hintText: "State Code",
                          prefixIcon: Icons.code_off,
                          enabled: !controller.isSameAsBilling.value,
                        ),
                      ),
                    ],
                  ),
                ]),
              ),

              _buildSectionHeader("Shipping & Payment Terms"),
              _buildCard([
                CustomSearchableDropdown<String>(
                  items: controller.paymentTermsOptions,
                  selectedItem: controller.selectedPaymentTerms,
                  itemAsString: (item) => item,
                  hintText: "Payment Terms",
                  prefixIcon: Icons.payment,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: controller.buyerReferenceController,
                        hintText: "Buyer Ref",
                        prefixIcon: Icons.tag,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: controller.otherReferencesController,
                        hintText: "Other Ref",
                        prefixIcon: Icons.more_horiz,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomSearchableDropdown<String>(
                        items: controller.dispatchThroughOptions,
                        selectedItem: controller.selectedDispatchedThrough,
                        itemAsString: (item) => item,
                        hintText: "Dispatched Through",
                        prefixIcon: Icons.local_shipping_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: controller.destinationController,
                        hintText: "Destination",
                        prefixIcon: Icons.place,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomSearchableDropdown<String>(
                  items: controller.deliveryTermsOptions,
                  selectedItem: controller.selectedDeliveryTerms,
                  itemAsString: (item) => item,
                  hintText: "Delivery Terms",
                  prefixIcon: Icons.assignment_turned_in,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: controller.shipmentDetailsController,
                        hintText: "Shipment Details",
                        prefixIcon: Icons.info_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: controller.shippingAmountController,
                        hintText: "Shipping Amount",
                        prefixIcon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ]),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "ITEMS",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A4F),
                        letterSpacing: 1.2,
                      ),
                    ),
                    AppGradientButton(
                      onPressed: () => controller.addItem(),
                      text: "Add Item",
                      icon: Icons.add,
                      width: 130,
                      height: 42,
                    ),
                  ],
                ),
              ),

              Obx(
                () => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.itemControllersList.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildItemCard(controller, index);
                  },
                ),
              ),

              _buildSectionHeader("Additional Notes"),
              _buildCard([
                AppTextField(
                  controller: controller.notesController,
                  hintText: "Notes / Terms & Conditions",
                  prefixIcon: Icons.note,
                  maxLines: 3,
                ),
              ]),

              const SizedBox(height: 32),
              if (!isEdit) ...[
                OutlinedButton(
                  onPressed: () {
                    controller.saveDraft();
                    Get.back();
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: const BorderSide(color: Color(0xFF1A1A4F), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "SAVE AS DRAFT",
                    style: TextStyle(
                      color: Color(0xFF1A1A4F),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Obx(
                () => AppGradientButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => isEdit
                            ? controller.updateQuotation(quotId!)
                            : controller.createQuotation(),
                  text: controller.isLoading.value
                      ? "SAVING..."
                      : (isEdit ? "UPDATE QUOTATION" : "GENERATE QUOTATION"),
                  width: double.infinity,
                  height: 56,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 24),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A4F),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildItemCard(QuotationController controller, int index) {
    final item = controller.itemControllersList[index];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A1A4F).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A4F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Item #${index + 1}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A4F),
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => controller.removeItem(index),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 22,
                ),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomSearchableDropdown<ProductModel>(
            items: controller.itemController.products,
            selectedItem: item.selectedProduct,
            itemAsString: (product) => "${product.name} (${product.sku})",
            hintText: "Select Product",
            prefixIcon: Icons.inventory_2,
            onChanged: (product) =>
                controller.onProductSelected(index, product),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: item.dueOn,
            hintText: "Due On (Date)",
            prefixIcon: Icons.timer_outlined,
            readOnly: true,
            onTap: () => controller.chooseDate(Get.context!, item.dueOn),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: item.quantity,
                  hintText: "Qty",
                  prefixIcon: Icons.shopping_basket,
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomSearchableDropdown<String>(
                  items: controller.unitOptions,
                  selectedItem: item.unit,
                  itemAsString: (val) => val,
                  hintText: "Unit",
                  prefixIcon: Icons.straighten,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: item.unitPrice,
            hintText: "Unit Price",
            prefixIcon: Icons.payments,
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? "Required" : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: item.discountPercentage,
                  hintText: "Disc %",
                  prefixIcon: Icons.percent,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomSearchableDropdown<String>(
                  items: controller.gstOptions,
                  selectedItem: item.gstPercentage,
                  itemAsString: (val) => val,
                  hintText: "GST %",
                  prefixIcon: Icons.account_balance_wallet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
