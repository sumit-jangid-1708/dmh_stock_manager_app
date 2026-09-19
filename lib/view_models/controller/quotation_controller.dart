import 'dart:async';
import 'dart:io';
import 'package:dmj_stock_manager/model/product_models/product_model.dart';
import 'package:dmj_stock_manager/model/quotation_models/get_quotation_response_model.dart';
import 'package:dmj_stock_manager/model/quotation_models/quotation_detail_model.dart';
import 'package:dmj_stock_manager/utils/app_alerts.dart';
import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/services/quotation_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get_storage/get_storage.dart';

import '../../model/quotation_models/bank_model.dart';
import '../../model/quotation_models/company_model.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';

class QuotationItemControllers extends GetxController with BaseController {
  final selectedProduct = Rx<ProductModel?>(null);
  final dueOn = TextEditingController();
  final quantity = TextEditingController();
  final unit = Rx<String?>(null);
  final unitPrice = TextEditingController();
  final discountPercentage = TextEditingController();
  final gstPercentage = Rx<String?>(null);

  QuotationItemControllers({
    ProductModel? product,
    String? dueOnText,
    String? quantityText,
    String? unitText,
    String? unitPriceText,
    String? discountPercentageText,
    String? gstPercentageText,
  }) {
    selectedProduct.value = product;
    dueOn.text = dueOnText ?? "";
    quantity.text = quantityText ?? "";
    unit.value = unitText ?? product?.unit;
    unitPrice.text =
        unitPriceText ?? (product?.unitPurchasePrice.toString() ?? "");
    discountPercentage.text = discountPercentageText ?? "";
    gstPercentage.value = gstPercentageText;
  }

  void dispose() {
    dueOn.dispose();
    quantity.dispose();
    unitPrice.dispose();
    discountPercentage.dispose();
  }
}

class QuotationController extends GetxController with BaseController {
  final ItemController itemController = Get.find<ItemController>();
  final QuotationService _quotationService = QuotationService();
  final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();
  final _storage = GetStorage();
  final String _draftKey = 'quotation_draft';

  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final isListLoading = false.obs;
  final isDetailLoading = false.obs;
  final isDownloading = false.obs; // ✅ Loading for PDF actions
  final isSavingCompany = false.obs;
  final isSavingBank = false.obs;
  final hasDraft = false.obs;

  // Quotation List State
  var quotationsList = <QuotationDetailsModel>[].obs;
  var currentPage = 1.obs;
  var hasNextPage = true.obs;
  final int limit = 20;
  final listSearchController = TextEditingController();
  Timer? _debounce;
  // ✅ Saved Company / Bank Lists
  var companiesList = <CompanyModel>[].obs;
  var banksList = <BankModel>[].obs;
  final selectedCompany = Rx<CompanyModel?>(null);
  final selectedBankAccount = Rx<BankModel?>(null);
  final isCompanyListLoading = false.obs;
  final isBankListLoading = false.obs;
  final editingCompanyId = Rx<int?>(null);
  final editingBankId = Rx<int?>(null);

  // Quotation Detail State
  final quotationDetail = Rx<QuotationDetailModel?>(null);

  // Form Controllers
  final quotationNumberController = TextEditingController();
  final quoteDateController = TextEditingController();
  final validUntilController = TextEditingController();
  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final customerEmailController = TextEditingController();
  final customerAddressController = TextEditingController();
  final customerGstinController = TextEditingController();
  final selectedCustomerState = Rx<String?>(null);
  final customerStateCodeController = TextEditingController();
  final consigneeNameController = TextEditingController();
  final consigneeAddressController = TextEditingController();
  final consigneeGstinController = TextEditingController();
  final selectedConsigneeState = Rx<String?>(null);
  final consigneeStateCodeController = TextEditingController();
  final isSameAsBilling = false.obs;
  final selectedPaymentTerms = Rx<String?>(null);
  final buyerReferenceController = TextEditingController();
  final otherReferencesController = TextEditingController();
  final selectedDispatchedThrough = Rx<String?>(null);
  final destinationController = TextEditingController();
  final selectedDeliveryTerms = Rx<String?>(null);
  final shipmentDetailsController = TextEditingController();
  final shippingAmountController = TextEditingController();
  final notesController = TextEditingController();

  // Company Details Form Controllers
  final companyLabelController = TextEditingController();
  final companyNameController = TextEditingController();
  final companyAddressController = TextEditingController();
  final companyGstinController = TextEditingController();
  final companyPhoneController = TextEditingController();
  final companyEmailController = TextEditingController();
  final companyTermsController = TextEditingController();

  // Bank Details Form Controllers
  final bankLabelController = TextEditingController();
  final bankNameController = TextEditingController();
  final bankAccountHolderController = TextEditingController();
  final bankAccountNumberController = TextEditingController();
  final bankIfscController = TextEditingController();
  final bankBranchController = TextEditingController();

  var itemControllersList = <QuotationItemControllers>[].obs;

  // Options
  final statesList = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
  ];
  final paymentTermsOptions = [
    "Advance Payment",
    "Net 30",
    "Net 60",
    "COD",
    "7 Days",
    "15 Days",
  ];
  final dispatchThroughOptions = [
    "Private Transport",
    "Courier",
    "Air",
    "Sea",
    "Hand Delivery",
  ];
  final deliveryTermsOptions = ["Door Delivery", "Ex-Works", "FOB", "CIF"];
  final unitOptions = ["PCS", "KGS", "MTR", "BOX", "NOS", "SET"];
  final gstOptions = ["0", "5", "12", "18", "28"];

  @override
  void onInit() {
    super.onInit();
    customerNameController.addListener(_syncOnBillingChange);
    customerAddressController.addListener(_syncOnBillingChange);
    customerGstinController.addListener(_syncOnBillingChange);
    customerStateCodeController.addListener(_syncOnBillingChange);
    ever(selectedCustomerState, (_) => _syncOnBillingChange());

    listSearchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        getQuotationList(isRefresh: true);
      });
    });

    addItem();
    getQuotationList();
    getCompanyList();
    getBankList();
    checkDraft();
  }

  void _syncOnBillingChange() {
    if (isSameAsBilling.value) syncConsigneeWithBilling();
  }

  void toggleSameAsBilling(bool? value) {
    isSameAsBilling.value = value ?? false;
    if (isSameAsBilling.value) syncConsigneeWithBilling();
  }

  void syncConsigneeWithBilling() {
    consigneeNameController.text = customerNameController.text;
    consigneeAddressController.text = customerAddressController.text;
    consigneeGstinController.text = customerGstinController.text;
    selectedConsigneeState.value = selectedCustomerState.value;
    consigneeStateCodeController.text = customerStateCodeController.text;
  }

  void addItem({ProductModel? product}) {
    itemControllersList.add(QuotationItemControllers(product: product));
  }

  void removeItem(int index) {
    if (itemControllersList.length > 1) {
      itemControllersList[index].dispose();
      itemControllersList.removeAt(index);
    } else {
      AppAlerts.error("At least one item is required");
    }
  }

  void onProductSelected(int index, ProductModel? product) {
    if (product != null) {
      final item = itemControllersList[index];
      item.selectedProduct.value = product;
      item.unitPrice.text = product.unitPurchasePrice.toString();
      item.unit.value = product.unit ?? "PCS";
      if (product.hsnId != null) {
        final hsn = itemController.hsnList.firstWhereOrNull(
          (e) => e.id == product.hsnId,
        );
        if (hsn != null)
          item.gstPercentage.value = hsn.gstPercentage?.toInt().toString();
      }
    }
  }

  Future<void> chooseDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime initialDate = DateTime.now();
    try {
      if (controller.text.isNotEmpty)
        initialDate = DateFormat('yyyy-MM-dd').parse(controller.text);
    } catch (_) {}
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A1A4F),
            onPrimary: Colors.white,
            onSurface: Color(0xFF1A1A4F),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> getQuotationList({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasNextPage.value = true;
    }
    if (!hasNextPage.value && !isRefresh) return;
    if (currentPage.value == 1) isListLoading.value = true;

    try {
      final response = await _quotationService.getQuotationListApi(
        currentPage.value,
        limit,
        listSearchController.text,
      );
      final quotationModel = GetQuotationDetailsResponseModel.fromJson(
        response,
      );
      if (quotationModel.data != null) {
        if (currentPage.value == 1) {
          quotationsList.assignAll(quotationModel.data!);
        } else {
          quotationsList.addAll(quotationModel.data!);
        }
        hasNextPage.value = quotationModel.hasNext ?? false;
        if (hasNextPage.value) currentPage.value++;
      }
    } catch (e) {
      handleError(e, onRetry: () => getQuotationList(isRefresh: isRefresh));
    } finally {
      isListLoading.value = false;
    }
  }

  Future<void> getQuotationDetail(int quotId) async {
    isDetailLoading.value = true;
    quotationDetail.value = null;
    try {
      final response = await _quotationService.getQuotationDetailApi(quotId);
      quotationDetail.value = QuotationDetailModel.fromJson(response);
    } catch (e) {
      handleError(e, onRetry: () => getQuotationDetail(quotId));
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> createQuotation() async {
    if (formKey.currentState!.validate()) {
      if (!_validateSavedDetailsSelection()) return;
      if (itemControllersList.any(
        (item) => item.selectedProduct.value == null,
      )) {
        AppAlerts.error("Please select a product for all items");
        return;
      }
      isLoading.value = true;
      try {
        final Map<String, dynamic> data = _getQuotationData();
        await _quotationService.createQuotationApi(data);
        AppAlerts.success("Quotation Created Successfully");
        getQuotationList(isRefresh: true);
        clearDraft();
        resetForm(); // ✅ add this
        Get.back();
      } catch (e) {
        handleError(e);
      } finally {
        isLoading.value = false;
      }
    }
  }

  Map<String, dynamic> _getQuotationData() {
    return {
      "number": quotationNumberController.text,
      "company_profile_id": selectedCompany.value?.id,
      "bank_account_id": selectedBankAccount.value?.id,
      "quote_date": quoteDateController.text,
      "valid_until": validUntilController.text,
      "customer_name": customerNameController.text,
      "customer_phone": customerPhoneController.text,
      "customer_email": customerEmailController.text,
      "customer_address": customerAddressController.text,
      "customer_gstin": customerGstinController.text,
      "customer_state": selectedCustomerState.value,
      "customer_state_code": customerStateCodeController.text,
      "consignee_name": consigneeNameController.text,
      "consignee_address": consigneeAddressController.text,
      "consignee_gstin": consigneeGstinController.text,
      "consignee_state": selectedConsigneeState.value,
      "consignee_state_code": consigneeStateCodeController.text,
      "payment_terms": selectedPaymentTerms.value,
      "buyer_reference": buyerReferenceController.text,
      "other_references": otherReferencesController.text,
      "dispatched_through": selectedDispatchedThrough.value,
      "destination": destinationController.text,
      "delivery_terms": selectedDeliveryTerms.value,
      "shipment_details": shipmentDetailsController.text,
      "shipping_amount": shippingAmountController.text.isEmpty
          ? "0.00"
          : shippingAmountController.text,
      "notes": notesController.text,
      "items": itemControllersList
          .map(
            (item) => {
              "product_id": item.selectedProduct.value?.id,
              "due_on": item.dueOn.text,
              "quantity": item.quantity.text,
              "unit": item.unit.value,
              "unit_price": item.unitPrice.text,
              "discount_percentage": item.discountPercentage.text.isEmpty
                  ? "0"
                  : item.discountPercentage.text,
              "gst_percentage": item.gstPercentage.value,
            },
          )
          .toList(),
    };
  }

  // ✅ Reset form to blank state for a fresh "Create" quotation
  void resetForm() {
    formKey.currentState?.reset();

    quotationNumberController.clear();
    selectedCompany.value = null;
    selectedBankAccount.value = null;
    quoteDateController.clear();
    validUntilController.clear();
    customerNameController.clear();
    customerPhoneController.clear();
    customerEmailController.clear();
    customerAddressController.clear();
    customerGstinController.clear();
    selectedCustomerState.value = null;
    customerStateCodeController.clear();
    consigneeNameController.clear();
    consigneeAddressController.clear();
    consigneeGstinController.clear();
    selectedConsigneeState.value = null;
    consigneeStateCodeController.clear();
    isSameAsBilling.value = false;
    selectedPaymentTerms.value = null;
    buyerReferenceController.clear();
    otherReferencesController.clear();
    selectedDispatchedThrough.value = null;
    destinationController.clear();
    selectedDeliveryTerms.value = null;
    shipmentDetailsController.clear();
    shippingAmountController.clear();
    notesController.clear();

    // Dispose old item controllers properly before clearing
    for (var controller in itemControllersList) {
      controller.dispose();
    }
    itemControllersList.clear();
    addItem(); // ✅ start with one blank item row
  }

  // ✅ Draft Features
  void checkDraft() {
    hasDraft.value = _storage.hasData(_draftKey);
  }

  void saveDraft() {
    final Map<String, dynamic> draftData = {
      "number": quotationNumberController.text,
      "company_profile_id": selectedCompany.value?.id,
      "bank_account_id": selectedBankAccount.value?.id,
      "quote_date": quoteDateController.text,
      "valid_until": validUntilController.text,
      "customer_name": customerNameController.text,
      "customer_phone": customerPhoneController.text,
      "customer_email": customerEmailController.text,
      "customer_address": customerAddressController.text,
      "customer_gstin": customerGstinController.text,
      "customer_state": selectedCustomerState.value,
      "customer_state_code": customerStateCodeController.text,
      "consignee_name": consigneeNameController.text,
      "consignee_address": consigneeAddressController.text,
      "consignee_gstin": consigneeGstinController.text,
      "consignee_state": selectedConsigneeState.value,
      "consignee_state_code": consigneeStateCodeController.text,
      "is_same_as_billing": isSameAsBilling.value,
      "payment_terms": selectedPaymentTerms.value,
      "buyer_reference": buyerReferenceController.text,
      "other_references": otherReferencesController.text,
      "dispatched_through": selectedDispatchedThrough.value,
      "destination": destinationController.text,
      "delivery_terms": selectedDeliveryTerms.value,
      "shipment_details": shipmentDetailsController.text,
      "shipping_amount": shippingAmountController.text,
      "notes": notesController.text,
      "items": itemControllersList
          .map(
            (item) => {
              "product_id": item.selectedProduct.value?.id,
              "due_on": item.dueOn.text,
              "quantity": item.quantity.text,
              "unit": item.unit.value,
              "unit_price": item.unitPrice.text,
              "discount_percentage": item.discountPercentage.text,
              "gst_percentage": item.gstPercentage.value,
            },
          )
          .toList(),
    };
    _storage.write(_draftKey, draftData);
    checkDraft();
    resetForm();
    AppAlerts.success("Draft Saved Successfully");
  }

  void restoreDraft() {
    final draftData = _storage.read(_draftKey);
    if (draftData != null) {
      quotationNumberController.text = draftData["number"] ?? "";
      selectedCompany.value = companiesList.firstWhereOrNull(
        (c) => c.id == draftData["company_profile_id"],
      );
      selectedBankAccount.value = banksList.firstWhereOrNull(
        (b) => b.id == draftData["bank_account_id"],
      );
      quoteDateController.text = draftData["quote_date"] ?? "";
      validUntilController.text = draftData["valid_until"] ?? "";
      customerNameController.text = draftData["customer_name"] ?? "";
      customerPhoneController.text = draftData["customer_phone"] ?? "";
      customerEmailController.text = draftData["customer_email"] ?? "";
      customerAddressController.text = draftData["customer_address"] ?? "";
      customerGstinController.text = draftData["customer_gstin"] ?? "";
      selectedCustomerState.value = draftData["customer_state"];
      customerStateCodeController.text = draftData["customer_state_code"] ?? "";
      consigneeNameController.text = draftData["consignee_name"] ?? "";
      consigneeAddressController.text = draftData["consignee_address"] ?? "";
      consigneeGstinController.text = draftData["consignee_gstin"] ?? "";
      selectedConsigneeState.value = draftData["consignee_state"];
      consigneeStateCodeController.text =
          draftData["consignee_state_code"] ?? "";
      isSameAsBilling.value = draftData["is_same_as_billing"] ?? false;
      selectedPaymentTerms.value = draftData["payment_terms"];
      buyerReferenceController.text = draftData["buyer_reference"] ?? "";
      otherReferencesController.text = draftData["other_references"] ?? "";
      selectedDispatchedThrough.value = draftData["dispatched_through"];
      destinationController.text = draftData["destination"] ?? "";
      selectedDeliveryTerms.value = draftData["delivery_terms"];
      shipmentDetailsController.text = draftData["shipment_details"] ?? "";
      shippingAmountController.text = draftData["shipping_amount"] ?? "";
      notesController.text = draftData["notes"] ?? "";

      // Restore Items
      for (var controller in itemControllersList) {
        controller.dispose();
      }
      itemControllersList.clear();

      if (draftData["items"] != null) {
        for (var itemData in draftData["items"]) {
          ProductModel? product = itemController.products.firstWhereOrNull(
            (p) => p.id == itemData["product_id"],
          );
          itemControllersList.add(
            QuotationItemControllers(
              product: product,
              dueOnText: itemData["due_on"],
              quantityText: itemData["quantity"],
              unitText: itemData["unit"],
              unitPriceText: itemData["unit_price"],
              discountPercentageText: itemData["discount_percentage"],
              gstPercentageText: itemData["gst_percentage"],
            ),
          );
        }
      }
      if (itemControllersList.isEmpty) addItem();

      clearDraft();
      AppAlerts.success("Draft Restored Successfully");
    }
  }

  void clearDraft() {
    _storage.remove(_draftKey);
    hasDraft.value = false;
  }

  // ✅ Clear Company details fields
  void clearCompanyDetails() {
    editingCompanyId.value = null;
    companyLabelController.clear();
    companyNameController.clear();
    companyAddressController.clear();
    companyGstinController.clear();
    companyPhoneController.clear();
    companyEmailController.clear();
    companyTermsController.clear();
  }

  // ✅ Clear Bank details fields
  void clearBankDetails() {
    editingBankId.value = null;
    bankLabelController.clear();
    bankNameController.clear();
    bankAccountHolderController.clear();
    bankAccountNumberController.clear();
    bankIfscController.clear();
    bankBranchController.clear();
  }

  void prefillCompanyForEdit(CompanyModel company) {
    editingCompanyId.value = company.id;
    companyLabelController.text = company.label ?? "";
    companyNameController.text = company.companyName ?? "";
    companyAddressController.text = company.address ?? "";
    companyGstinController.text = company.gstin ?? "";
    companyPhoneController.text = company.phone ?? "";
    companyEmailController.text = company.email ?? "";
    companyTermsController.text = company.terms ?? "";
  }

  void prefillBankForEdit(BankModel bank) {
    editingBankId.value = bank.id;
    bankLabelController.text = bank.label ?? "";
    bankNameController.text = bank.bankName ?? "";
    bankAccountHolderController.text = bank.accountName ?? "";
    bankAccountNumberController.text = bank.accountNumber ?? "";
    bankIfscController.text = bank.ifsc ?? "";
    bankBranchController.text = bank.branch ?? "";
  }

  Future<void> deleteQuotation(int quotId) async {
    isLoading.value = true;
    try {
      await _quotationService.deleteQuotationApi(quotId);
      AppAlerts.success("Quotation Deleted Successfully");
      quotationsList.removeWhere((element) => element.id == quotId);
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Set values for edit
  void setQuotationForEdit(QuotationDetailModel data) {
    quotationNumberController.text = data.number ?? "";
    selectedCompany.value =
        data.companyProfile ??
        companiesList.firstWhereOrNull((c) => c.id == data.companyProfileId);
    selectedBankAccount.value =
        data.bankAccount ??
        banksList.firstWhereOrNull((b) => b.id == data.bankAccountId);
    quoteDateController.text = data.quoteDate ?? "";
    validUntilController.text = data.validUntil ?? "";
    customerNameController.text = data.customerName ?? "";
    customerPhoneController.text = data.customerPhone ?? "";
    customerEmailController.text = data.customerEmail ?? "";
    customerAddressController.text = data.customerAddress ?? "";
    customerGstinController.text = data.customerGstin ?? "";
    selectedCustomerState.value = data.customerState;
    customerStateCodeController.text = data.customerStateCode ?? "";
    consigneeNameController.text = data.consigneeName ?? "";
    consigneeAddressController.text = data.consigneeAddress ?? "";
    consigneeGstinController.text = data.consigneeGstin ?? "";
    selectedConsigneeState.value = data.consigneeState;
    consigneeStateCodeController.text = data.consigneeStateCode ?? "";
    selectedPaymentTerms.value = data.paymentTerms;
    buyerReferenceController.text = data.buyerReference ?? "";
    otherReferencesController.text = data.otherReferences ?? "";
    selectedDispatchedThrough.value = data.dispatchedThrough;
    destinationController.text = data.destination ?? "";
    selectedDeliveryTerms.value = data.deliveryTerms;
    shipmentDetailsController.text = data.shipmentDetails ?? "";
    shippingAmountController.text = data.shippingAmount ?? "";
    notesController.text = data.notes ?? "";

    itemControllersList.clear();
    if (data.items != null && data.items!.isNotEmpty) {
      for (var item in data.items!) {
        // Try to find the actual product from itemController if available
        ProductModel? product = itemController.products.firstWhereOrNull(
          (p) => p.id == item.productId,
        );

        // If not found, create a stub with all required fields to avoid compilation errors
        product ??= ProductModel(
          id: item.productId ?? 0,
          vendor: 0,
          prefixCode: "",
          name: item.productName ?? "",
          size: "",
          color: "",
          material: "",
          sku: item.sku.toString(),
          barcode: "",
          barcodeImage: "",
          productImageVariants: [],
          unitPurchasePrice: double.tryParse(item.unitPrice ?? "0") ?? 0,
          unit: item.unit,
        );

        itemControllersList.add(
          QuotationItemControllers(
            product: product,
            dueOnText: item.dueOn,
            quantityText: item.quantity,
            unitText: item.unit,
            unitPriceText: item.unitPrice,
            discountPercentageText: item.discountPercentage,
            gstPercentageText: item.gstPercentage,
          ),
        );
      }
    } else {
      addItem();
    }
  }

  Future<void> updateQuotation(int quotId) async {
    if (formKey.currentState!.validate()) {
      if (!_validateSavedDetailsSelection()) return;
      if (itemControllersList.any(
        (item) => item.selectedProduct.value == null,
      )) {
        AppAlerts.error("Please select a product for all items");
        return;
      }
      isLoading.value = true;
      try {
        final Map<String, dynamic> data = _getQuotationData();
        await _quotationService.updateQuotationApi(quotId, data);
        AppAlerts.success("Quotation Updated Successfully");
        getQuotationList(isRefresh: true);
        resetForm(); // ✅ add this
        Get.back();
      } catch (e) {
        handleError(e);
      } finally {
        isLoading.value = false;
      }
    }
  }

  bool _validateSavedDetailsSelection() {
    if (selectedCompany.value == null) {
      AppAlerts.error("Please select a company profile");
      return false;
    }
    if (selectedBankAccount.value == null) {
      AppAlerts.error("Please select a bank account");
      return false;
    }
    return true;
  }

  // ✅ New Robust PDF Helper: Downloads the actual file
  Future<File?> _downloadFile(String url, String fileName) async {
    try {
      isDownloading.value = true;
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File("${dir.path}/$fileName.pdf");
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
      throw "Failed to fetch file (Status: ${response.statusCode})";
    } catch (e) {
      AppAlerts.error("Download Error: $e");
      return null;
    } finally {
      isDownloading.value = false;
    }
  }

  // ✅ Download and Open PDF
  Future<void> downloadQuotationPdf(String? url) async {
    if (url == null || url.isEmpty) {
      AppAlerts.error("PDF URL not available");
      return;
    }
    final fileName = "Quotation_${quotationDetail.value?.number ?? 'Document'}";
    final file = await _downloadFile(url, fileName);
    if (file != null) {
      await OpenFile.open(file.path);
    }
  }

  // ✅ Download and Share actual PDF file
  Future<void> shareQuotationPdf(String? url, String? quotNumber) async {
    if (url == null || url.isEmpty) {
      AppAlerts.error("PDF URL not available");
      return;
    }
    final fileName = "Quotation_${quotNumber ?? 'Document'}";
    final file = await _downloadFile(url, fileName);
    if (file != null) {
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Check out this Quotation: $quotNumber');
    }
  }

  @override
  void onClose() {
    quotationNumberController.dispose();
    quoteDateController.dispose();
    validUntilController.dispose();
    customerNameController.dispose();
    customerPhoneController.dispose();
    customerEmailController.dispose();
    customerAddressController.dispose();
    customerGstinController.dispose();
    customerStateCodeController.dispose();
    consigneeNameController.dispose();
    consigneeAddressController.dispose();
    consigneeGstinController.dispose();
    consigneeStateCodeController.dispose();
    buyerReferenceController.dispose();
    otherReferencesController.dispose();
    destinationController.dispose();
    shipmentDetailsController.dispose();
    shippingAmountController.dispose();
    notesController.dispose();
    listSearchController.dispose();

    companyLabelController.dispose();
    companyNameController.dispose();
    companyAddressController.dispose();
    companyGstinController.dispose();
    companyPhoneController.dispose();
    companyEmailController.dispose();
    companyTermsController.dispose();

    bankLabelController.dispose();
    bankNameController.dispose();
    bankAccountHolderController.dispose();
    bankAccountNumberController.dispose();
    bankIfscController.dispose();
    bankBranchController.dispose();

    _debounce?.cancel();
    for (var controller in itemControllersList) controller.dispose();
    super.onClose();
  }

  // ✅ Create or Update Company API
  Future<void> saveCompany() async {
    if (companyNameController.text.trim().isEmpty) {
      AppAlerts.error("Company name is required");
      return;
    }
    isSavingCompany.value = true;
    try {
      final Map<String, dynamic> data = {
        "label": companyLabelController.text,
        "company_name": companyNameController.text,
        "address": companyAddressController.text,
        "gstin": companyGstinController.text,
        "phone": companyPhoneController.text,
        "email": companyEmailController.text,
        "terms": companyTermsController.text,
      };
      if (editingCompanyId.value != null) {
        await _quotationService.updateCompanyApi(editingCompanyId.value!, data);
        AppAlerts.success("Company details updated successfully");
      } else {
        await _quotationService.createCompanyApi(data);
        AppAlerts.success("Company details saved successfully");
      }
      clearCompanyDetails();
      await getCompanyList();
      Get.back();
    } catch (e) {
      handleError(e);
    } finally {
      isSavingCompany.value = false;
    }
  }

  // ✅ Create or Update Bank API
  Future<void> saveBank() async {
    if (bankNameController.text.trim().isEmpty) {
      AppAlerts.error("Bank name is required");
      return;
    }
    isSavingBank.value = true;
    try {
      final Map<String, dynamic> data = {
        "label": bankLabelController.text,
        "bank_name": bankNameController.text,
        "account_name": bankAccountHolderController.text,
        "account_number": bankAccountNumberController.text,
        "ifsc": bankIfscController.text,
        "branch": bankBranchController.text,
      };
      if (editingBankId.value != null) {
        await _quotationService.updateBankApi(editingBankId.value!, data);
        AppAlerts.success("Bank details updated successfully");
      } else {
        await _quotationService.createBankApi(data);
        AppAlerts.success("Bank details saved successfully");
      }
      clearBankDetails();
      await getBankList();
      Get.back();
    } catch (e) {
      handleError(e);
    } finally {
      isSavingBank.value = false;
    }
  }

  // ✅ Get Company List
  Future<void> getCompanyList() async {
    isCompanyListLoading.value = true;
    try {
      final response = await _quotationService.getCompanyList();
      final model = CompanyListModel.fromJson(response);
      companiesList.assignAll(model.data ?? []);
    } catch (e) {
      handleError(e, onRetry: () => getCompanyList());
    } finally {
      isCompanyListLoading.value = false;
    }
  }

  // ✅ Get Bank List
  Future<void> getBankList() async {
    isBankListLoading.value = true;
    try {
      final response = await _quotationService.getBankList();
      final model = BankListModel.fromJson(response);
      banksList.assignAll(model.data ?? []);
    } catch (e) {
      handleError(e, onRetry: () => getBankList());
    } finally {
      isBankListLoading.value = false;
    }
  }

  Future<void> pickContactNumber() async {
    try {
      final contact = await _contactPicker.selectContact();
      if (contact == null) return; // user ne cancel kar diya

      final numbers = contact.phoneNumbers;
      if (numbers == null || numbers.isEmpty) {
        AppAlerts.error("Is contact me phone number nahi hai");
        return;
      }

      // spaces, dashes, brackets hatao
      String number = numbers.first.replaceAll(RegExp(r'[^0-9+]'), '');

      // India country code / leading zero hatao
      if (number.startsWith('+91')) {
        number = number.substring(3);
      } else if (number.startsWith('91') && number.length == 12) {
        number = number.substring(2);
      } else if (number.startsWith('0') && number.length == 11) {
        number = number.substring(1);
      }

      customerPhoneController.text = number;

      // Customer name khali ho to contact ka naam bhar do
      final name = contact.fullName ?? "";
      if (customerNameController.text.trim().isEmpty && name.isNotEmpty) {
        customerNameController.text = name;
      }
    } catch (e) {
      print(e);
      AppAlerts.error("Contacts open nahi ho paye");
    }
  }
}
