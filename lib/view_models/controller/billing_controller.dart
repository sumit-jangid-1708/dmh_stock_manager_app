// lib/view_models/controller/billing_controller.dart

import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
import 'package:dmj_stock_manager/view_models/services/billing_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/bills_model/bill_response_model.dart';
import '../../model/bills_model/company_details_model.dart';
import '../../view/billings/pdf_invoice_helper.dart';

class BillingController extends GetxController with BaseController {
  final BillingService billingService = BillingService();

  // ── Bill list & pagination ───────────────────────────────────────────────
  final bills = <BillModel>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;
  var currentPage = 1.obs;
  var totalCount = 0.obs;

  // ── Search / filter ──────────────────────────────────────────────────────
  var searchQuery = ''.obs;
  final searchController = TextEditingController();

  // ── Scroll controller for pagination ────────────────────────────────────
  final ScrollController scrollController = ScrollController();

  // ── PDF generation state ─────────────────────────────────────────────────
  /// Tracks whether a PDF is currently being generated (share or download).
  var isGeneratingPdf = false.obs;

  /// Session-level cache of the last entered company details.
  /// Pre-fills the form the next time the sheet is opened in the same session.
  CompanyDetails? _lastCompanyDetails;

  /// Expose last-used details so the UI can pre-fill the form.
  CompanyDetails? get lastCompanyDetails => _lastCompanyDetails;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    getBillDetails();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (!isLoadingMore.value && hasMore.value) {
          loadMoreBills();
        }
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  // ── Load bills ───────────────────────────────────────────────────────────

  Future<void> getBillDetails({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        bills.clear();
        hasMore.value = true;
      }
      isLoading.value = true;

      final response =
      await billingService.getBills(page: currentPage.value);
      final BillsResponseModel billResponse =
      BillsResponseModel.fromJson(response);

      totalCount.value = billResponse.count;

      if (refresh) {
        bills.value = billResponse.results;
      } else {
        bills.addAll(billResponse.results);
      }

      hasMore.value = billResponse.next != null;

      if (kDebugMode) {
        print('✅ Loaded ${billResponse.results.length} bills');
        print(
            '✅ Total: ${billResponse.count}, Has more: ${hasMore.value}');
      }
    } catch (e) {
      handleError(e, onRetry: () => getBillDetails(refresh: refresh));
      if (kDebugMode) print('🚩 Bill Error $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Load more (pagination) ───────────────────────────────────────────────

  Future<void> loadMoreBills() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      final response =
      await billingService.getBills(page: currentPage.value);
      final BillsResponseModel billResponse =
      BillsResponseModel.fromJson(response);

      bills.addAll(billResponse.results);
      hasMore.value = billResponse.next != null;

      if (kDebugMode) {
        print('✅ Loaded more: ${billResponse.results.length} bills');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Load more error: $e');
      currentPage.value--; // Rollback on failure
      handleError(e);
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ── Search / filter ──────────────────────────────────────────────────────

  void searchBills(String query) {
    searchQuery.value = query;
  }

  List<BillModel> get filteredBills {
    if (searchQuery.value.isEmpty) return bills;
    return bills.where((bill) {
      final q = searchQuery.value.toLowerCase();
      return bill.customerName.toLowerCase().contains(q) ||
          bill.mobile.contains(q) ||
          bill.id.toString().contains(q);
    }).toList();
  }

  Future<void> refreshBills() async {
    await getBillDetails(refresh: true);
  }

  // ── PDF generation (new — no Settings dependency) ───────────────────────

  /// Generates a PDF using explicitly-provided [CompanyDetails] and
  /// triggers the OS share sheet.
  ///
  /// Pass [action] as either `'share'` or `'download'`.
  Future<void> generateInvoiceWithCompanyDetails({
    required BillModel bill,
    required CompanyDetails company,
    required String action, // 'share' | 'download'
  }) async {
    assert(
    action == 'share' || action == 'download',
    'action must be "share" or "download"',
    );

    if (isGeneratingPdf.value) return; // Prevent double-tap

    try {
      isGeneratingPdf.value = true;

      // Cache for pre-filling the form next time in this session.
      _lastCompanyDetails = company;

      if (action == 'share') {
        await PdfInvoiceHelper.generateAndShare(bill, company);
      } else {
        await PdfInvoiceHelper.generateAndDownload(bill, company);
      }

      if (kDebugMode) {
        print('✅ PDF generated ($action) for bill #${bill.id}');
      }
    } catch (e, s) {
      if (kDebugMode) {
        print('❌ PDF generation error: $e');
        print('📍 $s');
      }
      handleError(e);
    } finally {
      isGeneratingPdf.value = false;
    }
  }
}