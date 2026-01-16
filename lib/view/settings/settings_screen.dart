import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/controller/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildAppBar(),

              // Content Area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FD),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader("Business Configuration", Icons.business_center),
                        const SizedBox(height: 16),

                        // Business Details Card
                        Obx(() => _buildBusinessCard(controller)),

                        const SizedBox(height: 30),
                        _sectionHeader("System Settings", Icons.settings),
                        const SizedBox(height: 16),
                        
                        Container(
                          width: double.infinity,
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white
                          ),
                          child: Center(
                            child: Text("System Settings will be available soon..."),
                          ),
                        )

                        // _buildSettingTile(
                        //   icon: Icons.notifications_active_rounded,
                        //   title: "Notifications",
                        //   subtitle: "Manage alerts and reminders",
                        //   gradient: const LinearGradient(
                        //     colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                        //   ),
                        //   onTap: () {
                        //     Get.snackbar(
                        //       "Coming Soon",
                        //       "Notification settings will be available soon",
                        //       backgroundColor: Colors.orange,
                        //       colorText: Colors.white,
                        //     );
                        //   },
                        // ),

                        // _buildSettingTile(
                        //   icon: Icons.security_rounded,
                        //   title: "Security & Privacy",
                        //   subtitle: "Password and permissions",
                        //   gradient: const LinearGradient(
                        //     colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        //   ),
                        //   onTap: () {
                        //     Get.snackbar(
                        //       "Coming Soon",
                        //       "Security settings will be available soon",
                        //       backgroundColor: Colors.purple,
                        //       colorText: Colors.white,
                        //     );
                        //   },
                        // ),

                        // _buildSettingTile(
                        //   icon: Icons.backup_rounded,
                        //   title: "Backup & Restore",
                        //   subtitle: "Secure your business data",
                        //   gradient: const LinearGradient(
                        //     colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                        //   ),
                        //   onTap: () {
                        //     Get.snackbar(
                        //       "Coming Soon",
                        //       "Backup feature will be available soon",
                        //       backgroundColor: Colors.green,
                        //       colorText: Colors.white,
                        //     );
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            "Settings",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A4F),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessCard(SettingsController controller) {
    final bool hasData = controller.companyName.value.isNotEmpty;

    return GestureDetector(
      onTap: () => _showBusinessDetailsBottomSheet(Get.context!, controller),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1A4F).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Business Profile",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasData ? controller.companyName.value : "Not Configured",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),

            if (hasData) ...[
              const SizedBox(height: 20),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 16),

              _buildInfoRow(Icons.receipt_long, "GST", controller.gstNumber.value),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.location_on, "Address", controller.address.value),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.phone, "Contact", controller.contactNumber.value),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? "Not set" : value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A4F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showBusinessDetailsBottomSheet(
      BuildContext context,
      SettingsController controller,
      ) {
    // Create controllers for text fields
    final nameController = TextEditingController(text: controller.companyName.value);
    final gstController = TextEditingController(text: controller.gstNumber.value);
    final addressController = TextEditingController(text: controller.address.value);
    final contactController = TextEditingController(text: controller.contactNumber.value);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Header
            // Container(
            //   padding: const EdgeInsets.all(24),
            //   decoration: BoxDecoration(
            //     gradient: const LinearGradient(
            //       colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
            //     ),
            //     borderRadius: const BorderRadius.vertical(
            //       top: Radius.circular(30),
            //     ),
            //   ),
            //   child: Row(
            //     children: [
            //       Container(
            //         padding: const EdgeInsets.all(12),
            //         decoration: BoxDecoration(
            //           color: Colors.white.withOpacity(0.2),
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //         child: const Icon(
            //           Icons.business_center,
            //           color: Colors.white,
            //           size: 24,
            //         ),
            //       ),
            //       const SizedBox(width: 16),
            //       const Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               "Business Profile",
            //               style: TextStyle(
            //                 fontSize: 22,
            //                 fontWeight: FontWeight.bold,
            //                 color: Colors.white,
            //               ),
            //             ),
            //             SizedBox(height: 4),
            //             Text(
            //               "Update your business information",
            //               style: TextStyle(
            //                 fontSize: 14,
            //                 color: Colors.white70,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // Form Fields
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildTextField(
                      "Company Name",
                      nameController,
                      Icons.business,
                      "Enter your company name",
                    ),
                    _buildTextField(
                      "GST Number",
                      gstController,
                      Icons.receipt_long,
                      "Enter GST number",
                      caps: TextCapitalization.characters,
                    ),
                    _buildTextField(
                      "Business Address",
                      addressController,
                      Icons.location_on,
                      "Enter complete address",
                      lines: 3,
                    ),
                    _buildTextField(
                      "Contact Number",
                      contactController,
                      Icons.phone,
                      "Enter contact number",
                      type: TextInputType.phone,
                    ),
                    const SizedBox(height: 30),

                    // Save Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A1A4F).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          minimumSize: const Size(double.infinity, 60),
                        ),
                        onPressed: () async {
                          // Update controller values
                          controller.companyName.value = nameController.text.trim();
                          controller.gstNumber.value = gstController.text.trim();
                          controller.address.value = addressController.text.trim();
                          controller.contactNumber.value = contactController.text.trim();

                          await controller.saveBusinessDetails();
                          Get.back();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.white),
                            SizedBox(width: 12),
                            Text(
                              "Save Changes",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      IconData icon,
      String hint, {
        int lines = 1,
        TextInputType type = TextInputType.text,
        TextCapitalization caps = TextCapitalization.none,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        maxLines: lines,
        keyboardType: type,
        textCapitalization: caps,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A4F),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF4A4ABF),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}