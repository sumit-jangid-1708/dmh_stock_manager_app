import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../view_models/controller/lead_controller.dart';

class LeadBulkUploadScreen extends StatelessWidget {
  LeadBulkUploadScreen({super.key});

  final LeadController leadController = Get.find<LeadController>();
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F8FC),
    appBar: AppBar(
      title: const Text('Bulk Upload Leads'),
      backgroundColor: const Color(0xFF1A1A4F),
      foregroundColor: Colors.white,
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF1A1A4F).withValues(alpha: .2),
            ),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFECECF8),
                child: Icon(
                  Icons.cloud_upload_outlined,
                  color: Color(0xFF1A1A4F),
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Upload checkout CSV',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select a Shopify checkout file (maximum 10 MB)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 18),
              Obx(
                () => Text(
                  leadController.selectedCsvName.value.isEmpty
                      ? 'No file selected'
                      : leadController.selectedCsvName.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: leadController.pickLeadCsv,
                icon: const Icon(Icons.file_open_outlined),
                label: const Text('CHOOSE CSV FILE'),
              ),
              const SizedBox(height: 10),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        leadController.selectedCsvFile.value == null ||
                            leadController.isBulkUploading.value
                        ? null
                        : leadController.uploadLeadCsv,
                    icon: leadController.isBulkUploading.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.cloud_upload_outlined),
                    label: Text(
                      leadController.isBulkUploading.value
                          ? 'UPLOADING...'
                          : 'UPLOAD LEADS',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CSV MAPPING',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A4F),
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Shipping Name  →  Shipping Name\nPhone  →  Country Code + Phone\nShipping Address  →  Address 1/2\nCity / ZIP  →  City / ZIP\nProvince  →  State\nCountry  →  Country + Dial Code\nSKU / Name  →  Selected Products',
                style: TextStyle(height: 1.8, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
