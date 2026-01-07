import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart';

class AddVendorFormBottomSheet extends StatelessWidget {
  final VendorController vendorController = Get.find<VendorController>();
  final _formKey = GlobalKey<FormState>();

  AddVendorFormBottomSheet({super.key});

  // --- Theme Decoration Helper (Matches Order & Item Sheets) ---
  InputDecoration _getDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF1A1A4F), size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1A1A4F), width: 1),
      ),
    );
  }

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
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // SECTION 1: BASIC & CONTACT
                    _buildSectionTitle("Contact Information", Icons.contact_phone_outlined),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: vendorController.vendorNameController.value,
                      decoration: _getDecoration("Vendor Name*", Icons.business_outlined),
                      validator: (value) => value == null || value.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 12),
                    IntlPhoneField(
                      decoration: _getDecoration("Phone Number", Icons.phone_android_outlined).copyWith(prefixIcon: null),
                      initialCountryCode: 'IN',
                      onChanged: (phone) {
                        vendorController.countryCode.value = phone.countryCode;
                        vendorController.phoneNumber.value = phone.number;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: vendorController.emailController.value,
                      decoration: _getDecoration("Email Address*", Icons.email_outlined),
                    ),

                    const SizedBox(height: 24),

                    // SECTION 2: LOCATION
                    _buildSectionTitle("Location Details", Icons.location_on_outlined),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: vendorController.addressController.value,
                      decoration: _getDecoration("Street Address", Icons.map_outlined),
                    ),
                    const SizedBox(height: 12),

                    // The Picker
                    CountryStateCityPicker(
                      country: vendorController.countryController.value,
                      state: vendorController.stateController.value,
                      city: vendorController.cityController.value,
                      dialogColor: Colors.white,
                      textFieldDecoration: _getDecoration("Select Location", Icons.public_outlined).copyWith(
                        suffixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1A1A4F)),
                        prefixIcon: const Icon(Icons.public, color: Color(0xFF1A1A4F), size: 20),
                      ),
                    ),

                    const SizedBox(height: 12),
                    TextFormField(
                      controller: vendorController.pinCodeController.value,
                      keyboardType: TextInputType.number,
                      decoration: _getDecoration("Pin Code", Icons.pin_drop_outlined),
                    ),

                    const SizedBox(height: 24),

                    // SECTION 3: BUSINESS & TAX
                    _buildSectionTitle("Tax Information", Icons.receipt_long_outlined),
                    const SizedBox(height: 12),
                    _buildGstToggle(),

                    Obx(() {
                      if (vendorController.isWithGst.value) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: vendorController.firmNameController.value,
                                  decoration: _getDecoration("Firm Name", Icons.account_balance_outlined),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: vendorController.gstNumberController.value,
                                  textCapitalization: TextCapitalization.characters,
                                  maxLength: 15,
                                  // Add formatters for better UX
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Z]')), // Only allow valid GST chars
                                    // UpperCaseTextFormatter(), // Custom formatter to force uppercase
                                  ],
                                  decoration: _getDecoration("GST Number", Icons.verified_user_outlined).copyWith(counterText: ""),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) return "GST Number required";
                                    // The regex you wrote is accurate
                                    final gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$');
                                    if (!gstRegex.hasMatch(value.trim())) return "Invalid GST Format";
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    const SizedBox(height: 32),

                    // SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A4F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (vendorController.isWithGst.value) {
                            if (_formKey.currentState?.validate() ?? false) {
                              vendorController.addVendor();
                            }
                          } else {
                            vendorController.addVendor();
                          }
                        },
                        child: const Text(
                          'Save Vendor',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
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
          child: const Icon(Icons.group_add_outlined, color: Color(0xFF1A1A4F)),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add New Vendor", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Register a new supplier to stock", style: TextStyle(fontSize: 12, color: Colors.grey)),
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
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildGstToggle() {
    return Obx(() => Container(
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
    ));
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
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
// import 'package:country_state_city_pro/country_state_city_pro.dart';
//
// class AddVendorFormBottomSheet extends StatelessWidget {
//   final VendorController vendorController = Get.find<VendorController>();
//   final _formKey = GlobalKey<FormState>();
//   AddVendorFormBottomSheet({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         vendorController.clearForm(); // 👈 form reset
//         return true;
//       },
//       child: Padding(
//         padding: EdgeInsets.only(
//           left: 16,
//           right: 16,
//           top: 20,
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Add New Vendor",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "Add a new vendor to your system",
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//                 const SizedBox(height: 20),
//
//                 // Vendor Name
//                 buildTextField(
//                   label: "Vendor Name*",
//                   hint: "eg. Rajasthani Crafts",
//                   inputController:
//                       vendorController.vendorNameController.value,
//                   validator: (value) => value == null || value.isEmpty
//                       ? "Vendor Name required"
//                       : null,
//                 ),
//
//                 // Phone
//                 IntlPhoneField(
//                   decoration: InputDecoration(
//                     hintText: "Phone number",
//                     filled: true,
//                     fillColor: Colors.grey.withOpacity(0.1),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       borderSide: BorderSide(
//                         width: 2,
//                         color: const Color(0xFF1A1A4F),
//                       ),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 14,
//                     ),
//                   ),
//                   initialCountryCode: 'IN',
//                   onChanged: (phone) {
//                     vendorController.countryCode.value = phone.countryCode;
//                     vendorController.phoneNumber.value = phone.number;
//                   },
//                 ),
//                 // Email
//                 buildTextField(
//                   label: "Email*",
//                   hint: "eg. example@gmail.com",
//                   inputController: vendorController.emailController.value,
//                   validator: (value) => value == null || value.isEmpty
//                       ? "Email required"
//                       : null,
//                 ),
//                 // Address
//                 buildTextField(
//                   label: "Address",
//                   hint: "eg. 123 Street, City",
//                   inputController: vendorController.addressController.value,
//                 ),
//
//                 // Country
//                 // const Text(
//                 //   "Country",
//                 //   style: TextStyle(fontWeight: FontWeight.w500),
//                 // ),
//                 // const SizedBox(height: 6),
//                 CountryStateCityPicker(
//                   country: vendorController.countryController.value,
//                   state: vendorController.stateController.value,
//                   city: vendorController.cityController.value,
//                   dialogColor: Colors.grey.shade200,
//                   textFieldDecoration: InputDecoration(
//                     fillColor: Colors.grey.withOpacity(0.1),
//                     filled: true,
//                     suffixIcon: const Icon(
//                       Icons.arrow_drop_down,  // 👈 Flutter का proper dropdown icon
//                       size: 28,
//                       color: Colors.black87,
//                     ),
//                     suffixIconConstraints: const BoxConstraints(
//                       minHeight: 32,
//                       minWidth: 48,
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       vertical: 14,
//                       horizontal: 12,
//                     ),
//                     border: const OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(8)),
//                       borderSide: BorderSide(
//                         width: 1.2,
//                         color: Color(0xFF1A1A4F),
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//                 // Pin Code
//                 buildTextField(
//                   label: "Pin Code",
//                   hint: "eg. 302001",
//                   inputController: vendorController.pinCodeController.value,
//                 ),
//                 // GST Toggle
//                 Obx(
//                   () => Row(
//                     children: [
//                       Expanded(
//                         child: RadioListTile<bool>(
//                           title: const Text("Without GST"),
//                           value: false,
//                           groupValue: vendorController.isWithGst.value,
//                           onChanged: (val) =>
//                               vendorController.isWithGst.value = val!,
//                         ),
//                       ),
//                       Expanded(
//                         child: RadioListTile<bool>(
//                           title: const Text("With GST"),
//                           value: true,
//                           groupValue: vendorController.isWithGst.value,
//                           onChanged: (val) =>
//                               vendorController.isWithGst.value = val!,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Conditional Fields
//                 Obx(() {
//                   if (vendorController.isWithGst.value) {
//                     return Column(
//                       children: [
//                         buildTextField(
//                           label: "Firm Name",
//                           hint: "eg. ABC Traders",
//                           inputController:
//                               vendorController.firmNameController.value,
//                         ),
//                         Form(
//                           key: _formKey,
//                           child: buildTextField(
//                             label: "GST Number",
//                             hint: "eg. 22AAAAA0000A1Z5",
//                             inputController:
//                                 vendorController.gstNumberController.value,
//                             textCapitalization: TextCapitalization.characters,
//                             maxLength: 15,
//                             validator: (value) {
//                               if (value == null || value.trim().isEmpty) {
//                                 return "GST Number is required";
//                               }
//                               final gstRegex = RegExp(
//                                 r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
//                               );
//                               if (!gstRegex.hasMatch(value.trim())) {
//                                 return "Invalid GST Number format";
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//                       ],
//                     );
//                   }
//                   return const SizedBox.shrink(); // empty space if without GST
//                 }),
//
//                 const SizedBox(height: 20),
//
//                 // Submit
//                 SizedBox(
//                   width: double.infinity,
//                   height: 48,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF1A1A4F),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     onPressed: () {
//                       if(vendorController.isWithGst.value) {
//                         if (_formKey.currentState?.validate() ?? false) {
//                           vendorController.addVendor();
//                         }
//                       }else {
//                         vendorController.addVendor();
//                       }
//                     },
//                     child: const Text(
//                       'Add Vendor',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildTextField({
//     required String label,
//     required String hint,
//     required TextEditingController inputController,
//     FormFieldValidator<String>? validator, // optional validator
//     TextCapitalization textCapitalization = TextCapitalization.none,
//     int? maxLength,
//     TextInputType keyboardType = TextInputType.text,
//     bool obscureText = false,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
//         const SizedBox(height: 6),
//         TextFormField(
//           controller: inputController,
//           textCapitalization: textCapitalization,
//           maxLength: maxLength,
//           keyboardType: keyboardType,
//           obscureText: obscureText,
//           decoration: InputDecoration(
//             hintText: hint,
//             counterText: "", // hide default counter if maxLength set
//             // filled: true,
//             // fillColor: Colors.grey.withOpacity(0.1),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(width: 2, color: Color(0xFF1A1A4F)),
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 14,
//             ),
//           ),
//           validator: validator, // works only because this is TextFormField
//         ),
//         const SizedBox(height: 12),
//       ],
//     );
//   }
// }
