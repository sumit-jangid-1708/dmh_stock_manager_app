import 'package:flutter/material.dart';
import 'app_gradient _button.dart';

class VendorCard extends StatelessWidget {
  final String initials;
  final String vendorName;
  final String phoneNumber;
  final String countryCode;
  final String? email;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pinCode;
  final String? firmName;
  final String? gstNumber;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const VendorCard({
    super.key,
    required this.initials,
    required this.vendorName,
    required this.phoneNumber,
    required this.countryCode,
    required this.email,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pinCode,
    this.firmName,
    this.gstNumber,
    required this.isExpanded,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gradient Avatar
                    Container(
                      width: 45,
                      height: 45,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF1A1A4F).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 14),

                    // Vendor Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vendorName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          if (firmName != null && firmName!.isNotEmpty) ...[
                            SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.business, size: 14, color: Colors.grey.shade600),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    firmName!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (gstNumber != null && gstNumber!.isNotEmpty) ...[
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified, size: 12, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text(
                                    "GST: $gstNumber",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Arrow Icon
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Contact Info Section
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      // Phone
                      if (phoneNumber.isNotEmpty && countryCode.isNotEmpty)
                        _buildInfoRow(
                          Icons.phone,
                          "$countryCode $phoneNumber",
                          Colors.blue,
                        ),

                      // Email
                      if (email != null && email!.isNotEmpty) ...[
                        SizedBox(height: 10),
                        _buildInfoRow(
                          Icons.email,
                          email!,
                          Colors.orange,
                        ),
                      ],

                      // Address
                      if (address.isNotEmpty && pinCode.isNotEmpty) ...[
                        SizedBox(height: 10),
                        _buildInfoRow(
                          Icons.location_on,
                          "$address, $pinCode",
                          Colors.red,
                        ),
                      ],

                      // City/State/Country
                      if (city.isNotEmpty && state.isNotEmpty && country.isNotEmpty) ...[
                        SizedBox(height: 10),
                        _buildInfoRow(
                          Icons.public,
                          "$city, $state, $country",
                          Colors.purple,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ✅ Bottom Action Bar with Edit Button
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: AppGradientButton(
                    text: "Edit",
                    icon: Icons.edit_outlined,
                    onPressed: onEdit,
                    height: 40,
                    fontSize: 13,
                  ),
                ),
                // Uncomment if you want to add delete button
                // SizedBox(width: 12),
                // Expanded(
                //   child: AppGradientButton(
                //     text: "Delete",
                //     icon: Icons.delete_outline,
                //     onPressed: onDelete,
                //     height: 40,
                //     fontSize: 13,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}