import 'package:flutter/material.dart';

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
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Row (Avatar, Title, Actions)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Initials Avatar
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Vendor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (firmName != null && firmName!.isNotEmpty)
                      Text(
                        "Firm: $firmName",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    if (gstNumber != null && gstNumber!.isNotEmpty)
                      Text(
                        "GST: $gstNumber",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    if (address.isNotEmpty && pinCode.isNotEmpty)
                      Text(
                        "$address $pinCode",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    if (city.isNotEmpty && state.isNotEmpty && country.isNotEmpty)
                      Text(
                        "$city-$state-$country",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),

              // Action Buttons
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     IconButton(
              //       icon: const Icon(
              //         Icons.delete_outline,
              //         color: Colors.red,
              //         size: 20,
              //       ),
              //       padding: EdgeInsets.zero,
              //       constraints: const BoxConstraints(),
              //       onPressed: onDelete,
              //     ),
              //     IconButton(
              //       icon: const Icon(
              //         Icons.edit,
              //         color: Colors.black87,
              //         size: 20,
              //       ),
              //       padding: EdgeInsets.zero,
              //       constraints: const BoxConstraints(),
              //       onPressed: onEdit,
              //     ),
              //   ],
              // ),
            ],
          ),

          if (phoneNumber.isNotEmpty && countryCode.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, color: Color(0xFF1A1A4F), size: 18),
                const SizedBox(width: 8),
                Text(
                  "$countryCode $phoneNumber",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],

          if (email != null && email!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.email, color: Color(0xFF1A1A4F), size: 18),
                const SizedBox(width: 8),
                Text(email!, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
