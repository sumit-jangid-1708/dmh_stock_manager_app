import 'dart:async';
import 'dart:io';
import 'package:dmj_stock_manager/model/lead_models/leads_options_model.dart';
import 'package:dmj_stock_manager/model/lead_models/leads_stats_model.dart';
import 'package:dmj_stock_manager/model/lead_models/lead_detail_model.dart';
import 'package:dmj_stock_manager/model/lead_models/lead_activity_model.dart';
import 'package:dmj_stock_manager/model/lead_models/lead_follow_up_model.dart';
import 'package:dmj_stock_manager/model/lead_models/lead_note_model.dart';
import 'package:dmj_stock_manager/model/lead_models/lead_status_history_model.dart';
import 'package:dmj_stock_manager/model/product_models/product_model.dart';
import 'package:dmj_stock_manager/view_models/controller/base_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/services/leads_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../model/lead_models/lead_model.dart';
import '../../utils/app_alerts.dart';

class LeadController extends GetxController with BaseController {
  final LeadsService _leadsService = LeadsService();
  final leads = <LeadModel>[].obs;
  final leadDetail = Rxn<LeadDetailModel>();
  final leadActivities = <LeadActivityModel>[].obs;
  final leadFollowUps = <LeadFollowUpModel>[].obs;
  final leadNotes = <LeadNoteModel>[].obs;
  final leadStatusHistory = <LeadStatusHistoryModel>[].obs;
  final followUps = <LeadFollowUpModel>[].obs;
  final selectedFollowUp = Rxn<LeadFollowUpModel>();

  // Dynamic options from API
  final leadOptions = Rxn<LeadsOptionsModel>();
  final leadStats = Rxn<LeadStatsModel>();

  final isLoading = false.obs;
  final isDetailLoading = false.obs;
  final isSaving = false.obs;
  final isFollowUpLoading = false.obs;
  final isFollowUpSaving = false.obs;
  final isBulkUploading = false.obs;
  final selectedCsvFile = Rxn<File>();
  final selectedCsvName = ''.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalCount = 0.obs;
  final followUpCount = 0.obs;
  final followUpPage = 1.obs;
  final followUpPages = 1.obs;
  final followUpSection = 'upcoming'.obs;
  final selectedView = 'all'.obs;
  final searchController = TextEditingController();

  // Filter variables using dynamic model types
  final leadStatusFilter = Rxn<LeadOption>();
  final leadPriorityFilter = Rxn<LeadOption>();
  final leadSourceFilter = Rxn<LeadOption>();
  final leadEmployeeFilter = Rxn<Employee>();
  final leadSortFilter = Rxn<LeadOption>();
  final followUpStatusFilter = Rxn<LeadOption>();
  final followUpEmployeeFilter = Rxn<Employee>();
  final followUpLeadFilter = Rxn<LeadModel>();
  final followUpStartDate = Rxn<DateTime>();
  final followUpEndDate = Rxn<DateTime>();
  final sortOptions = <LeadOption>[
    LeadOption(value: '-created_at', label: 'Newest First'),
    LeadOption(value: 'created_at', label: 'Oldest First'),
    LeadOption(value: 'full_name', label: 'Name A-Z'),
    LeadOption(value: '-full_name', label: 'Name Z-A'),
  ];

  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final countryCodeController = TextEditingController(text: '+91');
  final phoneController = TextEditingController();
  final shippingPhoneController = TextEditingController();
  final emailController = TextEditingController();
  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final cityController = TextEditingController();
  final zipController = TextEditingController();
  final provinceController = TextEditingController();
  final provinceNameController = TextEditingController();
  final countryController = TextEditingController(text: 'India');
  final selectedCountry = Rxn<Country>();
  final selectedEditStatus = Rxn<LeadOption>();

  final selectedProducts = <ProductModel>[].obs;
  final editingLeadId = Rxn<int>();
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(
        const Duration(milliseconds: 350),
        () => loadLeads(refresh: true),
      );
    });
    loadInitial();
  }

  Future<void> getLeadOptions() async {
    try {
      final response = await _leadsService.getLeadsOption();
      if (response != null) {
        leadOptions.value = LeadsOptionsModel.fromJson(response);
        if (selectedCountry.value == null) {
          selectedCountry.value = leadOptions.value?.countries.firstWhereOrNull(
            (country) => country.name.toLowerCase() == 'india',
          );
        }
      }
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> getLeadStats() async {
    try {
      final response = await _leadsService.getLeadsStats();
      if (response != null) {
        final data = response['data'] is Map ? response['data'] : response;
        leadStats.value = LeadStatsModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> loadInitial() async {
    try {
      isLoading.value = true;
      await Future.wait([getLeadOptions(), getLeadStats(), loadLeads()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadLeads({bool refresh = false, bool showLoader = true}) async {
    if (refresh) currentPage.value = 1;

    Map<String, dynamic> filters = {
      'view': selectedView.value,
      'sort': leadSortFilter.value?.value ?? '-created_at',
      'page': currentPage.value.toString(),
      'page_size': '25',
    };

    if (searchController.text.trim().isNotEmpty) {
      filters['search'] = searchController.text.trim();
    }
    if (leadStatusFilter.value != null) {
      filters['status'] = leadStatusFilter.value!.value;
    }
    if (leadPriorityFilter.value != null) {
      filters['priority'] = leadPriorityFilter.value!.value;
    }
    if (leadSourceFilter.value != null) {
      filters['source'] = leadSourceFilter.value!.value;
    }
    if (leadEmployeeFilter.value != null) {
      filters['assigned_to'] = leadEmployeeFilter.value!.id.toString();
    }
    if (startDate.value != null) {
      filters['date_from'] = DateFormat('yyyy-MM-dd').format(startDate.value!);
    }
    if (endDate.value != null) {
      filters['date_to'] = DateFormat('yyyy-MM-dd').format(endDate.value!);
    }

    try {
      if (showLoader) isLoading.value = true;
      final response = await _leadsService.getLeads(filters);
      final leadData = GetLeadsModel.fromJson(response);
      leads.assignAll(leadData.results);
      totalCount.value = leadData.count;
      currentPage.value = leadData.page;
      totalPages.value = leadData.pages;
    } catch (e) {
      handleError(e, onRetry: () => loadLeads(refresh: refresh));
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  Future<void> changePage(int page) async {
    currentPage.value = page;
    await loadLeads();
  }

  void clearFilters() {
    leadStatusFilter.value = null;
    leadPriorityFilter.value = null;
    leadSourceFilter.value = null;
    leadEmployeeFilter.value = null;
    leadSortFilter.value = null;
    startDate.value = null;
    endDate.value = null;
    selectedView.value = 'all';
    searchController.clear();
    loadLeads(refresh: true);
  }

  void clearForm() {
    editingLeadId.value = null;
    for (final c in [
      nameController,
      phoneController,
      shippingPhoneController,
      emailController,
      address1Controller,
      address2Controller,
      cityController,
      zipController,
      provinceController,
      provinceNameController,
    ]) {
      c.clear();
    }
    countryCodeController.text = '+91';
    countryController.text = 'India';
    selectedCountry.value = leadOptions.value?.countries.firstWhereOrNull(
      (country) => country.name.toLowerCase() == 'india',
    );
    selectedEditStatus.value = null;
    selectedProducts.clear();
  }

  void prepareEdit(LeadDetailModel l) {
    clearForm();
    editingLeadId.value = l.id;
    nameController.text = l.shippingName.isEmpty ? l.fullName : l.shippingName;
    countryCodeController.text = l.countryCode;
    phoneController.text = l.phone;
    shippingPhoneController.text = l.shippingPhone;
    emailController.text = l.email;
    address1Controller.text = l.shippingAddress1;
    address2Controller.text = l.shippingAddress2;
    cityController.text = l.shippingCity;
    zipController.text = l.shippingZip;
    provinceController.text = l.shippingProvince;
    provinceNameController.text = l.shippingProvinceName;
    countryController.text = l.shippingCountry;
    selectedCountry.value = leadOptions.value?.countries.firstWhereOrNull(
      (country) => country.dialCode == l.countryCode,
    );
    selectedEditStatus.value = leadOptions.value?.statuses.firstWhereOrNull(
      (status) => status.value == l.status,
    );
    final productIds = l.products
        .whereType<Map>()
        .map(
          (product) => int.tryParse(
            (product['id'] ?? product['product_id'] ?? '').toString(),
          ),
        )
        .whereType<int>()
        .toSet();
    selectedProducts.assignAll(
      Get.find<ItemController>().products.where(
        (product) => productIds.contains(product.id),
      ),
    );
  }

  Map<String, dynamic> leadFormData() {
    return {
      'shipping_name': nameController.text.trim(),
      'country_code': countryCodeController.text.trim(),
      'phone': phoneController.text.trim(),
      'shipping_phone': shippingPhoneController.text.trim(),
      'email': emailController.text.trim(),
      'shipping_address1': address1Controller.text.trim(),
      'shipping_address2': address2Controller.text.trim(),
      'shipping_city': cityController.text.trim(),
      'shipping_zip': zipController.text.trim(),
      'shipping_province': provinceController.text.trim(),
      'shipping_province_name': provinceNameController.text.trim(),
      'shipping_country': countryController.text.trim(),
      'product_ids': selectedProducts.map((product) => product.id).toList(),
    };
  }

  Future<bool> saveLead() {
    if (editingLeadId.value != null) return updateLead();
    return addLead();
  }

  Future<bool> addLead() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    if (selectedProducts.isEmpty) {
      AppAlerts.error('Please select at least one product');
      return false;
    }
    final data = leadFormData();

    try {
      isSaving.value = true;
      await _leadsService.addLeads(data);
      await loadLeads(refresh: true, showLoader: false);
      await getLeadStats();
      AppAlerts.success('Lead created successfully');
      clearForm();
      return true;
    } catch (e) {
      handleError(e, onRetry: addLead);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateLead() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    if (selectedProducts.isEmpty) {
      AppAlerts.error('Please select at least one product');
      return false;
    }
    if (selectedEditStatus.value == null) {
      AppAlerts.error('Please select lead status');
      return false;
    }

    final id = editingLeadId.value!;
    final data = leadFormData();
    data['status'] = selectedEditStatus.value!.value;

    try {
      isSaving.value = true;
      await _leadsService.updateLead(id, data);
      await loadLeads(showLoader: false);
      await getLeadStats();
      await loadLead(id);
      AppAlerts.success('Lead updated successfully');
      clearForm();
      return true;
    } catch (e) {
      handleError(e, onRetry: updateLead);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> loadLead(int id) async {
    try {
      isDetailLoading.value = true;
      leadDetail.value = null;
      leadActivities.clear();
      leadFollowUps.clear();
      leadNotes.clear();
      leadStatusHistory.clear();
      final response = await _leadsService.getLead(id);
      final data = response['data'] is Map ? response['data'] : response;
      leadDetail.value = LeadDetailModel.fromJson(
        Map<String, dynamic>.from(data),
      );
      await Future.wait([
        getLeadActivities(id),
        getLeadFollowUps(id),
        getLeadNotes(id),
        getLeadStatusHistory(id),
      ]);
    } catch (e) {
      handleError(e, onRetry: () => loadLead(id));
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> getLeadActivities(int id) async {
    final response = await _leadsService.getLeadActivities(id);
    final data = LeadActivityResponse.fromJson(response);
    leadActivities.assignAll(data.results);
  }

  Future<void> getLeadFollowUps(int id) async {
    final response = await _leadsService.getLeadFollowUps(id);
    final data = LeadFollowUpResponse.fromJson(response);
    leadFollowUps.assignAll(data.results);
  }

  Future<void> getLeadNotes(int id) async {
    final response = await _leadsService.getLeadNotes(id);
    final data = LeadNoteResponse.fromJson(response);
    leadNotes.assignAll(data.results);
  }

  Future<void> getLeadStatusHistory(int id) async {
    final response = await _leadsService.getLeadStatusHistory(id);
    final data = LeadStatusHistoryResponse.fromJson(response);
    leadStatusHistory.assignAll(data.results);
  }

  Future<void> getFollowUps({bool refresh = false}) async {
    if (refresh) followUpPage.value = 1;

    Map<String, dynamic> filters = {
      'section': followUpSection.value,
      'page': followUpPage.value.toString(),
      'page_size': '25',
    };
    if (followUpStatusFilter.value != null) {
      filters['status'] = followUpStatusFilter.value!.value;
    }
    if (followUpLeadFilter.value != null) {
      filters['lead'] = followUpLeadFilter.value!.id.toString();
    }
    if (followUpEmployeeFilter.value != null) {
      filters['assigned_to'] = followUpEmployeeFilter.value!.id.toString();
    }
    if (followUpStartDate.value != null) {
      filters['date_from'] = DateFormat(
        'yyyy-MM-dd',
      ).format(followUpStartDate.value!);
    }
    if (followUpEndDate.value != null) {
      filters['date_to'] = DateFormat(
        'yyyy-MM-dd',
      ).format(followUpEndDate.value!);
    }

    try {
      isFollowUpLoading.value = true;
      final response = await _leadsService.getFollowUps(filters);
      final data = LeadFollowUpResponse.fromJson(response);
      followUps.assignAll(data.results);
      followUpCount.value = data.count;
      followUpPage.value = data.page;
      followUpPages.value = data.pages;
    } catch (e) {
      handleError(e, onRetry: () => getFollowUps(refresh: refresh));
    } finally {
      isFollowUpLoading.value = false;
    }
  }

  Future<bool> getFollowUpDetail(int id) async {
    try {
      isFollowUpLoading.value = true;
      final response = await _leadsService.getFollowUpDetail(id);
      final oldFollowUp = followUps.firstWhereOrNull((item) => item.id == id);
      final rawData = response['data'] is Map ? response['data'] : response;
      final data = Map<String, dynamic>.from(rawData);
      data['lead_name'] ??= oldFollowUp?.leadName;
      data['lead_code'] ??= oldFollowUp?.leadCode;
      selectedFollowUp.value = LeadFollowUpModel.fromJson(data);
      return true;
    } catch (e) {
      handleError(e, onRetry: () => getFollowUpDetail(id));
      return false;
    } finally {
      isFollowUpLoading.value = false;
    }
  }

  Future<bool> updateFollowUp(int id, Map<String, dynamic> data) async {
    try {
      isFollowUpSaving.value = true;
      final response = await _leadsService.updateFollowUp(id, data);
      final oldFollowUp = selectedFollowUp.value;
      final rawData = response['data'] is Map ? response['data'] : response;
      final responseData = Map<String, dynamic>.from(rawData);
      responseData['lead_name'] ??= oldFollowUp?.leadName;
      responseData['lead_code'] ??= oldFollowUp?.leadCode;
      selectedFollowUp.value = LeadFollowUpModel.fromJson(responseData);
      await getFollowUps();
      await getLeadStats();
      AppAlerts.success('Follow-up updated successfully');
      return true;
    } catch (e) {
      handleError(e, onRetry: () => updateFollowUp(id, data));
      return false;
    } finally {
      isFollowUpSaving.value = false;
    }
  }

  Future<bool> deleteFollowUp(int id) async {
    try {
      isFollowUpLoading.value = true;
      await _leadsService.deleteFollowUp(id);
      followUps.removeWhere((followUp) => followUp.id == id);
      if (followUpCount.value > 0) followUpCount.value--;
      await getLeadStats();
      AppAlerts.success('Follow-up deleted successfully');
      return true;
    } catch (e) {
      handleError(e, onRetry: () => deleteFollowUp(id));
      return false;
    } finally {
      isFollowUpLoading.value = false;
    }
  }

  void clearFollowUpFilters() {
    followUpStatusFilter.value = null;
    followUpEmployeeFilter.value = null;
    followUpLeadFilter.value = null;
    followUpStartDate.value = null;
    followUpEndDate.value = null;
    getFollowUps(refresh: true);
  }

  Future<void> changeFollowUpPage(int page) async {
    followUpPage.value = page;
    await getFollowUps();
  }

  Future<void> pickLeadCsv() async {
    try {
      final pickedFile = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (pickedFile == null || pickedFile.path == null) return;

      if (await pickedFile.length() > 10 * 1024 * 1024) {
        AppAlerts.error('CSV file size must be less than 10 MB');
        return;
      }
      selectedCsvFile.value = File(pickedFile.path!);
      selectedCsvName.value = pickedFile.name;
    } catch (e) {
      handleError(e);
    }
  }

  Future<bool> uploadLeadCsv() async {
    if (selectedCsvFile.value == null) {
      AppAlerts.error('Please choose a CSV file');
      return false;
    }

    try {
      isBulkUploading.value = true;
      await _leadsService.importLeads(selectedCsvFile.value!);
      await loadLeads(refresh: true, showLoader: false);
      await getLeadStats();
      selectedCsvFile.value = null;
      selectedCsvName.value = '';
      AppAlerts.success('Leads imported successfully');
      return true;
    } catch (e) {
      handleError(e, onRetry: uploadLeadCsv);
      return false;
    } finally {
      isBulkUploading.value = false;
    }
  }

  Future<bool> _uiOnly(String message) async {
    AppAlerts.success('$message UI ready. API not connected.');
    return true;
  }

  Future<bool> changeStatus(int id, String status, String reason) async {
    Map<String, dynamic> data = {'status': status, 'reason': reason};

    try {
      isSaving.value = true;
      await _leadsService.changeLeadStatus(id, data);
      await loadLead(id);
      await loadLeads(showLoader: false);
      await getLeadStats();
      AppAlerts.success('Lead status updated successfully');
      return true;
    } catch (e) {
      handleError(e, onRetry: () => changeStatus(id, status, reason));
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> addNote(int id, String note) async {
    Map<String, dynamic> data = {'note': note};

    try {
      isSaving.value = true;
      await _leadsService.addLeadNote(id, data);
      await loadLead(id);
      AppAlerts.success('Note added successfully');
      return true;
    } catch (e) {
      handleError(e, onRetry: () => addNote(id, note));
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> addFollowUp(int id, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      await _leadsService.addLeadFollowUp(id, data);
      await loadLead(id);
      await loadLeads(showLoader: false);
      await getLeadStats();
      AppAlerts.success('Follow-up added successfully');
      return true;
    } catch (e) {
      handleError(e, onRetry: () => addFollowUp(id, data));
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> convertLead(int id, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      await _leadsService.convertLead(id, data);
      await loadLead(id);
      await loadLeads(showLoader: false);
      await getLeadStats();
      AppAlerts.success('Lead converted successfully');
      return true;
    } catch (e) {
      handleError(e, onRetry: () => convertLead(id, data));
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> markLost(int id, String reason, String notes) =>
      _uiOnly('Mark lost');
  Future<bool> deleteLead(int id) async {
    try {
      isLoading.value = true;
      await _leadsService.deleteLead(id);
      leads.removeWhere((lead) => lead.id == id);
      if (totalCount.value > 0) totalCount.value--;
      await getLeadStats();
      AppAlerts.success('Lead deleted successfully');
      return true;
    } catch (e) {
      handleError(e, onRetry: () => deleteLead(id));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    for (final c in [
      searchController,
      nameController,
      countryCodeController,
      phoneController,
      shippingPhoneController,
      emailController,
      address1Controller,
      address2Controller,
      cityController,
      zipController,
      provinceController,
      provinceNameController,
      countryController,
    ]) {
      c.dispose();
    }
    super.onClose();
  }
}
