import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/lead_models/leads_options_model.dart';
import '../../res/components/widgets/app_gradient _button.dart';
import '../../res/components/widgets/custom_searchable_dropdown.dart';
import '../../res/components/widgets/custom_text_field.dart';
import '../../view_models/controller/lead_controller.dart';
import 'widgets/lead_product_multi_select.dart';

class LeadFormScreen extends StatelessWidget {
  LeadFormScreen({super.key});

  final LeadController leadController = Get.find<LeadController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: Obx(
          () => Text(
            leadController.editingLeadId.value == null
                ? 'Add Lead'
                : 'Edit Lead',
          ),
        ),
        backgroundColor: const Color(0xFF1A1A4F),
        foregroundColor: Colors.white,
      ),
      body: Form(
          key: leadController.formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _section('CONTACT', [
                AppTextField(
                  controller: leadController.nameController,
                  hintText: 'Customer / Shipping Name *',
                  prefixIcon: Icons.person_outline,
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    SizedBox(width: 125, child: _countryCodeDropdown()),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppTextField(
                        controller: leadController.phoneController,
                        hintText: 'Phone *',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? 'Phone is required'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: leadController.shippingPhoneController,
                  hintText: 'Alternate / Shipping Phone',
                  prefixIcon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: leadController.emailController,
                  hintText: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
              ]),
              _section('SHIPPING ADDRESS', [
                AppTextField(
                  controller: leadController.address1Controller,
                  hintText: 'Address Line 1',
                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: leadController.address2Controller,
                  hintText: 'Address Line 2',
                  prefixIcon: Icons.add_location_alt_outlined,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: leadController.cityController,
                        hintText: 'City',
                        prefixIcon: Icons.location_city_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppTextField(
                        controller: leadController.zipController,
                        hintText: 'ZIP',
                        prefixIcon: Icons.pin_drop_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: leadController.provinceController,
                        hintText: 'State Code',
                        prefixIcon: Icons.code_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppTextField(
                        controller: leadController.provinceNameController,
                        hintText: 'State Name',
                        prefixIcon: Icons.map_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: leadController.countryController,
                  hintText: 'Country',
                  prefixIcon: Icons.public_outlined,
                ),
              ]),
              Obx(
                () => leadController.editingLeadId.value == null
                    ? const SizedBox.shrink()
                    : _section('LEAD STATUS', [
                        CustomSearchableDropdown<LeadOption>(
                          items:
                              leadController.leadOptions.value?.statuses ?? [],
                          selectedItem: leadController.selectedEditStatus,
                          itemAsString: (status) => status.label,
                          hintText: 'Select status',
                          prefixIcon: Icons.swap_horiz_rounded,
                          searchHint: 'Search status...',
                        ),
                      ]),
              ),
              _section('INTERESTED PRODUCTS', [LeadProductMultiSelect()]),
              const SizedBox(height: 8),
              Obx(
                () => AppGradientButton(
                  onPressed: leadController.isSaving.value
                      ? null
                      : () async {
                          if (await leadController.saveLead()) Get.back();
                        },
                  text: leadController.isSaving.value
                      ? 'SAVING...'
                      : (leadController.editingLeadId.value == null
                            ? 'CREATE LEAD'
                            : 'UPDATE LEAD'),
                  height: 54,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
    );
  }

  Widget _countryCodeDropdown() {
    return Obx(() {
      return CustomSearchableDropdown<Country>(
        items: leadController.leadOptions.value?.countries ?? [],
        selectedItem: leadController.selectedCountry,
        itemAsString: (country) => '${country.dialCode} ${country.name}',
        hintText: '+91',
        prefixIcon: Icons.flag_outlined,
        searchHint: 'Search country code...',
        onChanged: (country) {
          if (country == null) return;
          leadController.countryCodeController.text = country.dialCode;
          leadController.countryController.text = country.name;
        },
      );
    });
  }

  Widget _section(String title, List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A4F),
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    ),
  );
}
