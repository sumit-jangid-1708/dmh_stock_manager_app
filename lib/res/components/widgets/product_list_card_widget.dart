import 'package:dmj_stock_manager/model/product_model.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../model/hsn_model.dart';

class ProductCard extends StatelessWidget {
  final int count;
  final ProductModel product;
  final VoidCallback onShare;
  final VoidCallback onView;

  const ProductCard({
    super.key,
    required this.count,
    required this.product,
    required this.onShare,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final itemController = Get.find<ItemController>();
    final imageList = product.productImageVariants;

    // HSN Code निकालो ID से
    String hsnDisplay = "N/A";
    if (product.hsnId != null) {
      final hsnModel = itemController.hsnList.firstWhereOrNull(
            (h) => h.id == product.hsnId,
      );
      hsnDisplay = hsnModel?.hsnCode ?? "HSN ID: ${product.hsnId}";
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageList.isNotEmpty
                  ? GestureDetector(
                onTap: () => _showImageDialog(context, imageList),
                child: Image.network(
                  _getImageUrl(imageList.first),
                  width: 90,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 90,
                    height: 110,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              )
                  : Container(
                width: 90,
                height: 110,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Text("No Image", style: TextStyle(color: Colors.grey)),
              ),
            ),

            const SizedBox(width: 14),

            // 📝 Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // SKU
                  Text(
                    "SKU: ${product.sku}",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),

                  // Material | Size | Color
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.material,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        " • ${product.size} • ${product.color}",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A4F)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // HSN + Action Buttons (Proper Spacing)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // HSN Chip
                      if (product.hsnId != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A4F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF1A1A4F), width: 1),
                          ),
                          child: Text(
                            hsnDisplay,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A4F),
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),

                      // Action Buttons (Share & Barcode)
                      Row(
                        children: [
                          _buildActionButton(icon: FontAwesomeIcons.image, onTap: onShare),
                          const SizedBox(width: 10),
                          _buildActionButton(icon: FontAwesomeIcons.barcode, onTap: onView),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Functions
  String _getImageUrl(dynamic imageItem) {
    if (imageItem is String) {
      return "https://traders.testwebs.in$imageItem";
    } else if (imageItem is Map<String, dynamic> && imageItem.containsKey('image')) {
      return "https://traders.testwebs.in${imageItem['image']}";
    }
    return "https://via.placeholder.com/150"; // Fallback
  }

  Widget _buildActionButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A4F),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: FaIcon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  void _showImageDialog(BuildContext context, List<dynamic> images) {
    final validImages = images
        .where((item) => item is String || (item is Map && item.containsKey('image')))
        .toList();

    if (validImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No images available")));
      return;
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: validImages.length,
              itemBuilder: (_, index) {
                return InteractiveViewer(
                  child: Image.network(
                    _getImageUrl(validImages[index]),
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, progress) =>
                    progress == null ? child : const Center(child: CircularProgressIndicator(color: Colors.white)),
                    errorBuilder: (_, __, ___) => const Icon(Icons.error, color: Colors.white),
                  ),
                );
              },
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:dmj_stock_manager/model/product_model.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//
// class ProductCard extends StatelessWidget {
//   final int count;
//   final ProductModel product;
//   final VoidCallback onShare;
//   final VoidCallback onView;
//
//   const ProductCard({
//     super.key,
//     required this.count,
//     required this.product,
//     required this.onShare,
//     required this.onView,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final imageList = product.productImageVariants;
//
//     // Debug prints to inspect imageList
//     print("imageList type: ${imageList.runtimeType}");
//     print("imageList content: $imageList");
//     if (imageList.isNotEmpty) {
//       print("First item type: ${imageList.first.runtimeType}");
//       print("First item: ${imageList.first}");
//     }
//
//     return Card(
//       color: Colors.white,
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 🔹 Image (Left Side)
//             SizedBox(
//               width: 80, // Adjustable width for image
//               height: 100, // Adjustable height for image
//               child: imageList.isNotEmpty
//                   ? GestureDetector(
//                       onTap: () => _showImageDialog(context, imageList),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.network(
//                           _getImageUrl(imageList.first),
//                           width: 120,
//                           height: 120,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stack) => Container(
//                             width: 120,
//                             height: 120,
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade200,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             alignment: Alignment.center,
//                             child: const Text(
//                               "Error",
//                               style: TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     )
//                   : Container(
//                       width: 120,
//                       height: 120,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade200,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       alignment: Alignment.center,
//                       child: const Text(
//                         "No Image",
//                         style: TextStyle(color: Colors.grey, fontSize: 12),
//                       ),
//                     ),
//             ),
//             const SizedBox(width: 12), // Space between image and details
//             // 🔹 Details (Right Side)
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Product Name
//                   Text(
//                     product.name,
//                     style: const TextStyle(
//                       fontSize: 16, // Adjustable
//                       fontWeight: FontWeight.bold,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//
//                   // SKU
//                   Text(
//                     product.sku,
//                     style: const TextStyle(
//                       fontSize: 13, // Adjustable
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//
//                   // Material | Size | Color
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           product.material,
//                           style: const TextStyle(
//                             fontSize: 12, // Adjustable
//                             color: Colors.grey,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         "${product.size} | ${product.color}",
//                         style: const TextStyle(
//                           fontSize: 12, // Adjustable
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF1A1A4F),
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//
//                   // Barcode Button
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         if (product.hsnCode != null &&
//                             product.hsnCode!.isNotEmpty)
//                           Text(
//                             product.hsnCode!,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF1A1A4F),
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//
//                         _buildActionButton(
//                           icon: FontAwesomeIcons.image,
//                           onTap: onShare,
//                         ),
//                         const SizedBox(width: 10),
//                         _buildActionButton(
//                           icon: FontAwesomeIcons.barcode,
//                           onTap: onView,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Helper to get image URL from either Map or String
//   String _getImageUrl(dynamic imageItem) {
//     if (imageItem is String) {
//       return "https://traders.testwebs.in$imageItem";
//     } else if (imageItem is Map<String, dynamic> &&
//         imageItem.containsKey('image')) {
//       return "https://traders.testwebs.in/${imageItem['image']}";
//     }
//     return "https://traders.testwebs.in/placeholder.jpg"; // Fallback URL
//   }
//
//   Widget _buildActionButton({
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: const Color(0xFF1A1A4F),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: FaIcon(
//           icon,
//           size: 14, // Adjustable
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
//
//   // 🔹 Image Slider Dialog
//   void _showImageDialog(BuildContext context, List<dynamic> images) {
//     // Filter valid images (only strings or maps with 'image' key)
//     final validImages = images
//         .where(
//           (item) =>
//               item is String ||
//               (item is Map<String, dynamic> && item.containsKey('image')),
//         )
//         .toList();
//
//     if (validImages.isEmpty) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("No Images"),
//           content: const Text("No valid images available to display."),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       );
//       return;
//     }
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           backgroundColor: Colors.black,
//           insetPadding: const EdgeInsets.all(10),
//           child: Stack(
//             children: [
//               PageView.builder(
//                 itemCount: validImages.length,
//                 itemBuilder: (context, index) {
//                   final imageUrl = _getImageUrl(validImages[index]);
//                   return InteractiveViewer(
//                     child: Image.network(
//                       imageUrl,
//                       fit: BoxFit.contain,
//                       loadingBuilder: (context, child, progress) {
//                         if (progress == null) return child;
//                         return const Center(
//                           child: CircularProgressIndicator(color: Colors.white),
//                         );
//                       },
//                       errorBuilder: (context, error, stack) => const Center(
//                         child: Icon(Icons.broken_image, color: Colors.white),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               Positioned(
//                 right: 8,
//                 top: 8,
//                 child: IconButton(
//                   icon: const Icon(Icons.close, color: Colors.white),
//                   onPressed: () => Navigator.of(context).pop(),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
