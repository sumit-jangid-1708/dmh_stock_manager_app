// lib/view_models/controller/billing_controller.dart

import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
import 'package:dmj_stock_manager/view_models/services/billing_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../model/bills_model/bill_response_model.dart';
import '../../model/bills_model/company_details_model.dart';
import '../../view/billings/pdf_invoice_helper.dart';

class BillingController extends GetxController with BaseController {
  final BillingService billingService = BillingService();
  final _box = GetStorage();

  // ── Storage keys ─────────────────────────────────────────────────────────
  static const _kNames     = 'cd_names';
  static const _kGsts      = 'cd_gsts';
  static const _kAddresses = 'cd_addresses';
  static const _kPhones    = 'cd_phones';

  // ── Bill list & pagination ───────────────────────────────────────────────
  final bills          = <BillModel>[].obs;
  var isLoading        = false.obs;
  var isLoadingMore    = false.obs;
  var hasMore          = true.obs;
  var currentPage      = 1.obs;
  var totalCount       = 0.obs;

  // ── Search ───────────────────────────────────────────────────────────────
  var searchQuery      = ''.obs;
  final searchController = TextEditingController();

  // ── Scroll ───────────────────────────────────────────────────────────────
  final ScrollController scrollController = ScrollController();

  // ── PDF state ────────────────────────────────────────────────────────────
  var isGeneratingPdf = false.obs;

  // ── Company dropdown lists (persisted across sessions) ───────────────────
  final companyNames = <String>[].obs;
  final gstNumbers   = <String>[].obs;
  final addresses    = <String>[].obs;
  final phoneNumbers = <String>[].obs;

  // ── Currently selected values ────────────────────────────────────────────
  final selectedName    = Rx<String?>(null);
  final selectedGst     = Rx<String?>(null); // nullable — GST is optional
  final selectedAddress = Rx<String?>(null);
  final selectedPhone   = Rx<String?>(null);

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadDropdownLists();
    getBillDetails();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (!isLoadingMore.value && hasMore.value) loadMoreBills();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  // ── Dropdown persistence ─────────────────────────────────────────────────

  void _loadDropdownLists() {
    companyNames.assignAll(_readList(_kNames));
    gstNumbers.assignAll(_readList(_kGsts));
    addresses.assignAll(_readList(_kAddresses));
    phoneNumbers.assignAll(_readList(_kPhones));
  }

  List<String> _readList(String key) {
    try {
      final raw = _box.read<List>(key);
      return raw?.map((e) => e.toString()).toList() ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveList(String key, List<String> list) =>
      _box.write(key, list);

  // ── Add to dropdown lists ─────────────────────────────────────────────────
  // Each method adds the value, persists, then auto-selects it.

  Future<void> addCompanyName(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty || companyNames.contains(trimmed)) return;
    companyNames.add(trimmed);
    await _saveList(_kNames, companyNames);
    selectedName.value = trimmed;
  }

  Future<void> addGstNumber(String value) async {
    final trimmed = value.trim().toUpperCase();
    if (trimmed.isEmpty || gstNumbers.contains(trimmed)) return;
    gstNumbers.add(trimmed);
    await _saveList(_kGsts, gstNumbers);
    selectedGst.value = trimmed;
  }

  Future<void> addAddress(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty || addresses.contains(trimmed)) return;
    addresses.add(trimmed);
    await _saveList(_kAddresses, addresses);
    selectedAddress.value = trimmed;
  }

  Future<void> addPhoneNumber(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty || phoneNumbers.contains(trimmed)) return;
    phoneNumbers.add(trimmed);
    await _saveList(_kPhones, phoneNumbers);
    selectedPhone.value = trimmed;
  }

  // ── Reset selections (called when sheet closes without submitting) ────────

  void resetCompanySelections() {
    selectedName.value    = null;
    selectedGst.value     = null;
    selectedAddress.value = null;
    selectedPhone.value   = null;
  }

  // ── Validation + build CompanyDetails ────────────────────────────────────

  /// Returns null if validation passes, or an error message string.
  String? validateCompanySelection() {
    if (selectedName.value == null || selectedName.value!.isEmpty) {
      return 'Please select or add a Company Name';
    }
    if (selectedAddress.value == null || selectedAddress.value!.isEmpty) {
      return 'Please select or add a Business Address';
    }
    if (selectedPhone.value == null || selectedPhone.value!.isEmpty) {
      return 'Please select or add a Contact Number';
    }
    return null;
  }

  /// Builds [CompanyDetails] from current selections.
  /// Call only after [validateCompanySelection] returns null.
  CompanyDetails buildCompanyDetails() {
    return CompanyDetails(
      name: selectedName.value!.trim(),
      gst: (selectedGst.value?.trim().isEmpty ?? true)
          ? null
          : selectedGst.value!.trim(),
      address: selectedAddress.value!.trim(),
      phone: selectedPhone.value!.trim(),
    );
  }

  // ── PDF generation ────────────────────────────────────────────────────────

  Future<void> generateInvoiceWithCompanyDetails({
    required BillModel bill,
    required CompanyDetails company,
    required String action, // 'share' | 'download'
  }) async {
    assert(action == 'share' || action == 'download');
    if (isGeneratingPdf.value) return;

    try {
      isGeneratingPdf.value = true;
      if (action == 'share') {
        await PdfInvoiceHelper.generateAndShare(bill, company);
      } else {
        await PdfInvoiceHelper.generateAndDownload(bill, company);
      }
      if (kDebugMode) print('✅ PDF generated ($action) for bill #${bill.id}');
    } catch (e, s) {
      if (kDebugMode) print('❌ PDF error: $e\n$s');
      handleError(e);
    } finally {
      isGeneratingPdf.value = false;
    }
  }

  // ── Bill loading ─────────────────────────────────────────────────────────

  Future<void> getBillDetails({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        bills.clear();
        hasMore.value = true;
      }
      isLoading.value = true;
      final response = await billingService.getBills(page: currentPage.value);
      final billResponse = BillsResponseModel.fromJson(response);
      totalCount.value = billResponse.count;
      if (refresh) {
        bills.value = billResponse.results;
      } else {
        bills.addAll(billResponse.results);
      }
      hasMore.value = billResponse.next != null;
    } catch (e) {
      handleError(e, onRetry: () => getBillDetails(refresh: refresh));
      if (kDebugMode) print('🚩 Bill Error $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreBills() async {
    if (isLoadingMore.value || !hasMore.value) return;
    try {
      isLoadingMore.value = true;
      currentPage.value++;
      final response = await billingService.getBills(page: currentPage.value);
      final billResponse = BillsResponseModel.fromJson(response);
      bills.addAll(billResponse.results);
      hasMore.value = billResponse.next != null;
    } catch (e) {
      currentPage.value--;
      handleError(e);
    } finally {
      isLoadingMore.value = false;
    }
  }

  void searchBills(String query) => searchQuery.value = query;

  List<BillModel> get filteredBills {
    if (searchQuery.value.isEmpty) return bills;
    final q = searchQuery.value.toLowerCase();
    return bills.where((b) =>
    b.customerName.toLowerCase().contains(q) ||
        b.mobile.contains(q) ||
        b.id.toString().contains(q)).toList();
  }

  Future<void> refreshBills() => getBillDetails(refresh: true);
}