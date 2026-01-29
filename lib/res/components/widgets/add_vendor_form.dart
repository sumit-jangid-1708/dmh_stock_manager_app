import 'package:dmj_stock_manager/utils/utils.dart';
import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart';

import 'custom_text_field.dart';

class AddVendorFormBottomSheet extends StatelessWidget {
  final VendorController vendorController = Get.find<VendorController>();

  AddVendorFormBottomSheet({super.key});


  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) vendorController.clearForm();
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            Flexible(
              child: Form(
                key: vendorController.formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),

                      // SECTION 1: BASIC & CONTACT
                      _buildSectionTitle(
                        "Contact Information",
                        Icons.contact_phone_outlined,
                      ),
                      const SizedBox(height: 12),

                      // ✅ Using AppTextField
                      AppTextField(
                        controller: vendorController.vendorNameController.value,
                        hintText: "Vendor Name*",
                        prefixIcon: Icons.business_outlined,
                        validator: (value) =>
                        value == null || value.isEmpty ? "Required" : null,
                      ),

                      const SizedBox(height: 12),

                      IntlPhoneField(
                        decoration: Utils.inputDecoration(
                          "Phone Number",
                          Icons.phone_android_outlined,
                        ).copyWith(prefixIcon: null),
                        initialCountryCode: 'IN',
                        onChanged: (phone) {
                          vendorController.countryCode.value = phone.countryCode;
                          vendorController.phoneNumber.value = phone.number;
                        },
                      ),

                      const SizedBox(height: 12),

                      // ✅ Using AppTextField
                      AppTextField(
                        controller: vendorController.emailController.value,
                        hintText: "Email Address*",
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 24),

                      // SECTION 2: LOCATION
                      _buildSectionTitle(
                        "Location Details",
                        Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 12),

                      // ✅ Using AppTextField
                      AppTextField(
                        controller: vendorController.addressController.value,
                        hintText: "Street Address",
                        prefixIcon: Icons.map_outlined,
                        maxLines: 2,
                      ),

                      const SizedBox(height: 12),

                      // CountryStateCityPicker (Can't use AppTextField - special widget)
                      CountryStateCityPicker(
                        country: vendorController.countryController.value,
                        state: vendorController.stateController.value,
                        city: vendorController.cityController.value,
                        dialogColor: Colors.white,
                        textFieldDecoration: Utils.inputDecoration(
                          "Select Location",
                          Icons.public_outlined,
                        ).copyWith(
                          suffixIcon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF1A1A4F),
                          ),
                          prefixIcon: const Icon(
                            Icons.public,
                            color: Color(0xFF1A1A4F),
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ✅ Using AppTextField
                      AppTextField(
                        controller: vendorController.pinCodeController.value,
                        hintText: "Pin Code",
                        prefixIcon: Icons.pin_drop_outlined,
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 24),

                      // SECTION 3: BUSINESS & TAX
                      _buildSectionTitle(
                        "Tax Information",
                        Icons.receipt_long_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildGstToggle(),

                      // ✅ GST Fields with AnimatedSize for smooth transition
                      Obx(() {
                        return AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: vendorController.isWithGst.value
                              ? Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              children: [
                                // ✅ Using AppTextField
                                AppTextField(
                                  controller: vendorController
                                      .firmNameController.value,
                                  hintText: "Firm Name",
                                  prefixIcon: Icons.account_balance_outlined,
                                ),

                                const SizedBox(height: 12),

                                // ✅ GST Number field with special formatting
                                // Using TextFormField with custom decoration because of special requirements
                                TextFormField(
                                  controller: vendorController
                                      .gstNumberController.value,
                                  textCapitalization:
                                  TextCapitalization.characters,
                                  maxLength: 15,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9A-Z]'),
                                    ),
                                  ],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "GST Number",
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.verified_user_outlined,
                                      color: Color(0xFF1A1A4F),
                                      size: 20,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    contentPadding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF1A1A4F),
                                        width: 1.5,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.redAccent,
                                        width: 1,
                                      ),
                                    ),
                                    counterText: "",
                                    errorText: vendorController
                                        .gstError.value.isEmpty
                                        ? null
                                        : vendorController.gstError.value,
                                  ),
                                  onChanged: vendorController.validateGST,
                                ),
                              ],
                            ),
                          )
                              : const SizedBox.shrink(),
                        );
                      }),

                      const SizedBox(height: 32),

                      // SUBMIT BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1A4F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (vendorController.formKey.currentState
                                ?.validate() ??
                                false) {
                              vendorController.addVendor();
                            }
                          },
                          child: const Text(
                            'Save Vendor',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A4F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.group_add_outlined,
            color: Color(0xFF1A1A4F),
          ),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add New Vendor",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Register a new supplier to stock",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildGstToggle() {
    return Obx(
          () => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _gstOption("Without GST", false),
            _gstOption("With GST", true),
          ],
        ),
      ),
    );
  }

  Widget _gstOption(String label, bool value) {
    bool isSelected = vendorController.isWithGst.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => vendorController.isWithGst.value = value,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1A1A4F) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}