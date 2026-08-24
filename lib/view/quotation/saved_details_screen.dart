import 'package:dmj_stock_manager/view/quotation/widgets/add_bank_details_bottom_sheet.dart';
import 'package:dmj_stock_manager/view/quotation/widgets/add_company_details_bottom_sheet.dart';
import 'package:dmj_stock_manager/view_models/controller/quotation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const _primaryColor = Color(0xFF1A1A4F);

class SavedDetailsScreen extends StatefulWidget {
  const SavedDetailsScreen({super.key});

  @override
  State<SavedDetailsScreen> createState() => _SavedDetailsScreenState();
}

class _SavedDetailsScreenState extends State<SavedDetailsScreen> {
  final controller = Get.find<QuotationController>();

  @override
  void initState() {
    super.initState();
    controller.getCompanyList();
    controller.getBankList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            'Saved Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(text: "Company Details", icon: Icon(Icons.business_outlined)),
              Tab(text: "Bank Details", icon: Icon(Icons.account_balance_outlined)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _CompanyDetailsTab(),
            _BankDetailsTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------- COMPANY TAB ----------------

class _CompanyDetailsTab extends StatelessWidget {
  const _CompanyDetailsTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuotationController>();

    return Obx(() {
      if (controller.isCompanyListLoading.value && controller.companiesList.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: _primaryColor));
      }

      return Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => controller.getCompanyList(),
            child: controller.companiesList.isEmpty
                ? ListView(
              padding: const EdgeInsets.symmetric(vertical: 120),
              children: const [
                _EmptyState(
                  icon: Icons.business_outlined,
                  message: "No company details added yet",
                ),
              ],
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: controller.companiesList.length,
              itemBuilder: (context, index) {
                final c = controller.companiesList[index];
                return _DetailCard(
                  icon: Icons.business,
                  label: c.label ?? "",
                  title: c.companyName ?? "-",
                  rows: [
                    if ((c.address ?? "").isNotEmpty)
                      _InfoRow(icon: Icons.location_on_outlined, text: c.address!),
                    if ((c.gstin ?? "").isNotEmpty)
                      _InfoRow(icon: Icons.receipt_long_outlined, text: "GSTIN: ${c.gstin}"),
                    if ((c.phone ?? "").isNotEmpty)
                      _InfoRow(icon: Icons.phone_outlined, text: c.phone!),
                    if ((c.email ?? "").isNotEmpty)
                      _InfoRow(icon: Icons.email_outlined, text: c.email!),
                  ],
                  onEdit: () {
                    controller.prefillCompanyForEdit(c);
                    Get.bottomSheet(
                      const AddCompanyDetailsBottomSheet(),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _AddNewButton(
              label: "Add Company Details",
              onTap: () {
                controller.clearCompanyDetails();
                Get.bottomSheet(
                  const AddCompanyDetailsBottomSheet(),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

// ---------------- BANK TAB ----------------

class _BankDetailsTab extends StatelessWidget {
  const _BankDetailsTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuotationController>();

    return Obx(() {
      if (controller.isBankListLoading.value && controller.banksList.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: _primaryColor));
      }

      return Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => controller.getBankList(),
            child: controller.banksList.isEmpty
                ? ListView(
              padding: const EdgeInsets.symmetric(vertical: 120),
              children: const [
                _EmptyState(
                  icon: Icons.account_balance_outlined,
                  message: "No bank details added yet",
                ),
              ],
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: controller.banksList.length,
              itemBuilder: (context, index) {
                final b = controller.banksList[index];
                final accNum = b.accountNumber ?? "";
                final masked = accNum.length > 4
                    ? "•••• ${accNum.substring(accNum.length - 4)}"
                    : accNum;
                return _DetailCard(
                  icon: Icons.account_balance,
                  label: b.label ?? "",
                  title: b.bankName ?? "-",
                  rows: [
                    if ((b.accountName ?? "").isNotEmpty)
                      _InfoRow(icon: Icons.person_outline, text: b.accountName!),
                    if (accNum.isNotEmpty)
                      _InfoRow(icon: Icons.numbers, text: "A/C: $masked"),
                    if ((b.ifsc ?? "").isNotEmpty)
                      _InfoRow(icon: Icons.code, text: "IFSC: ${b.ifsc}"),
                    if ((b.branch ?? "").isNotEmpty)
                      _InfoRow(icon: Icons.location_city_outlined, text: b.branch!),
                  ],
                  onEdit: () {
                    controller.prefillBankForEdit(b);
                    Get.bottomSheet(
                      const AddBankDetailsBottomSheet(),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _AddNewButton(
              label: "Add Bank Details",
              onTap: () {
                controller.clearBankDetails();
                Get.bottomSheet(
                  const AddBankDetailsBottomSheet(),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

// ---------------- SHARED WIDGETS ----------------

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;
  final List<_InfoRow> rows;
  final VoidCallback onEdit;

  const _DetailCard({
    required this.icon,
    required this.label,
    required this.title,
    required this.rows,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryColor.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _primaryColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (label.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.edit_outlined, color: Colors.grey.shade500, size: 20),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
              ),
            ],
          ),
          if (rows.isNotEmpty) const Divider(height: 24),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddNewButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddNewButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _primaryColor,
      borderRadius: BorderRadius.circular(14),
      elevation: 4,
      shadowColor: _primaryColor.withOpacity(0.4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
