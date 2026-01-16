import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final box = GetStorage();

  // Observable fields
  final RxString companyName = ''.obs;
  final RxString gstNumber = ''.obs;
  final RxString address = ''.obs;
  final RxString contactNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedData();
  }

  // Load data from storage on init
  void _loadSavedData() {
    companyName.value = box.read('companyName') ?? '';
    gstNumber.value = box.read('gstNumber') ?? '';
    address.value = box.read('address') ?? '';
    contactNumber.value = box.read('contactNumber') ?? '';
  }

  // Save all details
  Future<void> saveBusinessDetails() async {
    await box.write('companyName', companyName.value.trim());
    await box.write('gstNumber', gstNumber.value.trim());
    await box.write('address', address.value.trim());
    await box.write('contactNumber', contactNumber.value.trim());

    Get.snackbar(
      'Success ✅',
      'Business details saved successfully!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  // Clear all data (optional reset button के लिए)
  Future<void> clearBusinessDetails() async {
    await box.remove('companyName');
    await box.remove('gstNumber');
    await box.remove('address');
    await box.remove('contactNumber');

    companyName.value = '';
    gstNumber.value = '';
    address.value = '';
    contactNumber.value = '';

    Get.snackbar(
      'Cleared',
      'Business details have been reset.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
    );
  }
}