import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart';

class AddVendorFormBottomSheet extends StatelessWidget {
  final VendorController vendorController = Get.find<VendorController>();
  final _formKey = GlobalKey<FormState>();
  AddVendorFormBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        vendorController.clearForm(); // 👈 form reset
        return true;
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Add New Vendor",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Add a new vendor to your system",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),

                // Vendor Name
                buildTextField(
                  label: "Vendor Name*",
                  hint: "eg. Rajasthani Crafts",
                  inputController:
                      vendorController.vendorNameController.value,
                  validator: (value) => value == null || value.isEmpty
                      ? "Vendor Name required"
                      : null,
                ),

                // Phone
                IntlPhoneField(
                  decoration: InputDecoration(
                    hintText: "Phone number",
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        width: 2,
                        color: const Color(0xFF1A1A4F),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  initialCountryCode: 'IN',
                  onChanged: (phone) {
                    vendorController.countryCode.value = phone.countryCode;
                    vendorController.phoneNumber.value = phone.number;
                  },
                ),
                // Email
                buildTextField(
                  label: "Email*",
                  hint: "eg. example@gmail.com",
                  inputController: vendorController.emailController.value,
                  validator: (value) => value == null || value.isEmpty
                      ? "Email required"
                      : null,
                ),
                // Address
                buildTextField(
                  label: "Address",
                  hint: "eg. 123 Street, City",
                  inputController: vendorController.addressController.value,
                ),

                // Country
                // const Text(
                //   "Country",
                //   style: TextStyle(fontWeight: FontWeight.w500),
                // ),
                // const SizedBox(height: 6),
                CountryStateCityPicker(
                  country: vendorController.countryController.value,
                  state: vendorController.stateController.value,
                  city: vendorController.cityController.value,
                  dialogColor: Colors.grey.shade200,
                  textFieldDecoration: InputDecoration(
                    fillColor: Colors.grey.withOpacity(0.1),
                    filled: true,
                    suffixIcon: const Icon(
                      Icons.arrow_drop_down,  // 👈 Flutter का proper dropdown icon
                      size: 28,
                      color: Colors.black87,
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minHeight: 32,
                      minWidth: 48,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(
                        width: 1.2,
                        color: Color(0xFF1A1A4F),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                // Pin Code
                buildTextField(
                  label: "Pin Code",
                  hint: "eg. 302001",
                  inputController: vendorController.pinCodeController.value,
                ),
                // GST Toggle
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text("Without GST"),
                          value: false,
                          groupValue: vendorController.isWithGst.value,
                          onChanged: (val) =>
                              vendorController.isWithGst.value = val!,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text("With GST"),
                          value: true,
                          groupValue: vendorController.isWithGst.value,
                          onChanged: (val) =>
                              vendorController.isWithGst.value = val!,
                        ),
                      ),
                    ],
                  ),
                ),
                // Conditional Fields
                Obx(() {
                  if (vendorController.isWithGst.value) {
                    return Column(
                      children: [
                        buildTextField(
                          label: "Firm Name",
                          hint: "eg. ABC Traders",
                          inputController:
                              vendorController.firmNameController.value,
                        ),
                        Form(
                          key: _formKey,
                          child: buildTextField(
                            label: "GST Number",
                            hint: "eg. 22AAAAA0000A1Z5",
                            inputController:
                                vendorController.gstNumberController.value,
                            textCapitalization: TextCapitalization.characters,
                            maxLength: 15,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "GST Number is required";
                              }
                              final gstRegex = RegExp(
                                r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
                              );
                              if (!gstRegex.hasMatch(value.trim())) {
                                return "Invalid GST Number format";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink(); // empty space if without GST
                }),

                const SizedBox(height: 20),

                // Submit
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A4F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if(vendorController.isWithGst.value) {
                        if (_formKey.currentState?.validate() ?? false) {
                          vendorController.addVendor();
                        }
                      }else {
                        vendorController.addVendor();
                      }
                    },
                    child: const Text(
                      'Add Vendor',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required String hint,
    required TextEditingController inputController,
    FormFieldValidator<String>? validator, // optional validator
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: inputController,
          textCapitalization: textCapitalization,
          maxLength: maxLength,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            counterText: "", // hide default counter if maxLength set
            // filled: true,
            // fillColor: Colors.grey.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(width: 2, color: Color(0xFF1A1A4F)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
          validator: validator, // works only because this is TextFormField
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
