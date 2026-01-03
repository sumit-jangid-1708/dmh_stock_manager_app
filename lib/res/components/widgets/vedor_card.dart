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

          // // Bottom Action Bar
          // Container(
          //   decoration: BoxDecoration(
          //     color: Colors.grey.shade100,
          //     borderRadius: BorderRadius.only(
          //       bottomLeft: Radius.circular(16),
          //       bottomRight: Radius.circular(16),
          //     ),
          //   ),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: TextButton.icon(
          //           onPressed: onEdit,
          //           icon: Icon(Icons.edit, size: 16, color: Color(0xFF1A1A4F)),
          //           label: Text(
          //             "Edit",
          //             style: TextStyle(
          //               color: Color(0xFF1A1A4F),
          //               fontSize: 13,
          //               fontWeight: FontWeight.w600,
          //             ),
          //           ),
          //         ),
          //       ),
          //       Container(width: 1, height: 30, color: Colors.grey.shade300),
          //       Expanded(
          //         child: TextButton.icon(
          //           onPressed: onDelete,
          //           icon: Icon(Icons.delete_outline, size: 16, color: Colors.red),
          //           label: Text(
          //             "Delete",
          //             style: TextStyle(
          //               color: Colors.red,
          //               fontSize: 13,
          //               fontWeight: FontWeight.w600,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
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


// import 'package:flutter/material.dart';
//
// class VendorCard extends StatelessWidget {
//   final String initials;
//   final String vendorName;
//   final String phoneNumber;
//   final String countryCode;
//   final String? email;
//   final String address;
//   final String city;
//   final String state;
//   final String country;
//   final String pinCode;
//   final String? firmName;
//   final String? gstNumber;
//   final bool isExpanded;
//   final VoidCallback onToggle;
//   final VoidCallback onDelete;
//   final VoidCallback onEdit;
//
//   const VendorCard({
//     super.key,
//     required this.initials,
//     required this.vendorName,
//     required this.phoneNumber,
//     required this.countryCode,
//     required this.email,
//     required this.address,
//     required this.city,
//     required this.state,
//     required this.country,
//     required this.pinCode,
//     this.firmName,
//     this.gstNumber,
//     required this.isExpanded,
//     required this.onToggle,
//     required this.onDelete,
//     required this.onEdit,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // First Row (Avatar, Title, Actions)
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Initials Avatar
//               Container(
//                 width: 40,
//                 height: 40,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   initials,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//
//               // Vendor Info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       vendorName,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 15,
//                       ),
//                     ),
//                     if (firmName != null && firmName!.isNotEmpty)
//                       Text(
//                         "Firm: $firmName",
//                         style: const TextStyle(
//                           fontSize: 13,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     if (gstNumber != null && gstNumber!.isNotEmpty)
//                       Text(
//                         "GST: $gstNumber",
//                         style: const TextStyle(
//                           fontSize: 13,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     if (address.isNotEmpty && pinCode.isNotEmpty)
//                       Text(
//                         "$address $pinCode",
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.black54,
//                         ),
//                       ),
//                     if (city.isNotEmpty && state.isNotEmpty && country.isNotEmpty)
//                       Text(
//                         "$city-$state-$country",
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.black54,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//
//               // Action Buttons
//               // Row(
//               //   mainAxisAlignment: MainAxisAlignment.start,
//               //   children: [
//               //     IconButton(
//               //       icon: const Icon(
//               //         Icons.delete_outline,
//               //         color: Colors.red,
//               //         size: 20,
//               //       ),
//               //       padding: EdgeInsets.zero,
//               //       constraints: const BoxConstraints(),
//               //       onPressed: onDelete,
//               //     ),
//               //     IconButton(
//               //       icon: const Icon(
//               //         Icons.edit,
//               //         color: Colors.black87,
//               //         size: 20,
//               //       ),
//               //       padding: EdgeInsets.zero,
//               //       constraints: const BoxConstraints(),
//               //       onPressed: onEdit,
//               //     ),
//               //   ],
//               // ),
//             ],
//           ),
//
//           if (phoneNumber.isNotEmpty && countryCode.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 const Icon(Icons.phone, color: Color(0xFF1A1A4F), size: 18),
//                 const SizedBox(width: 8),
//                 Text(
//                   "$countryCode $phoneNumber",
//                   style: const TextStyle(fontSize: 13),
//                 ),
//               ],
//             ),
//           ],
//
//           if (email != null && email!.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 const Icon(Icons.email, color: Color(0xFF1A1A4F), size: 18),
//                 const SizedBox(width: 8),
//                 Text(email!, style: const TextStyle(fontSize: 13)),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
