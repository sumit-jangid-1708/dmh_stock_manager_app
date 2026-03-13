// lib/res/components/widgets/multi_image_picker_widget.dart

import 'dart:io';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MultiImagePickerWidget extends StatelessWidget {
  final ItemController itemController = Get.find<ItemController>();

  // ✅ Callback to notify parent when images change
  final Function(List<File>)? onImagesSelected;

  MultiImagePickerWidget({super.key, this.onImagesSelected});

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Wrap(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF1A1A4F)),
              title: const Text("Take Photo"),
              onTap: () async {
                Navigator.pop(context);
                await itemController.pickFromCamera();

                // ✅ Notify parent with updated list
                if (onImagesSelected != null) {
                  onImagesSelected!(itemController.selectedImage.toList());
                }

                if (kDebugMode) {
                  print("📸 Camera image added. Total: ${itemController.selectedImage.length}");
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF1A1A4F)),
              title: const Text("Select from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                await itemController.pickFromGalleryMultiple();

                // ✅ Notify parent with updated list
                if (onImagesSelected != null) {
                  onImagesSelected!(itemController.selectedImage.toList());
                }

                if (kDebugMode) {
                  print("🖼️ Gallery images added. Total: ${itemController.selectedImage.length}");
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final images = itemController.selectedImage;

      // ✅ Show limit reached message
      if (images.length >= 6) {
        return Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) => _buildImageCard(images[index], index),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                  const SizedBox(width: 6),
                  Text(
                    "Maximum 6 images allowed",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: images.length + 1,
            itemBuilder: (context, index) {
              // ✅ Add button
              if (index == images.length) {
                return GestureDetector(
                  onTap: () => _showImageSourceDialog(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF1A1A4F).withOpacity(0.2),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_a_photo_outlined,
                          size: 32,
                          color: Color(0xFF1A1A4F),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${images.length}/6",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1A1A4F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // ✅ Image card
              return _buildImageCard(images[index], index);
            },
          ),

          // ✅ Image count indicator
          if (images.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.image, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  "${images.length} image${images.length > 1 ? 's' : ''} selected",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }

  Widget _buildImageCard(File image, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF1A1A4F).withOpacity(0.1),
            ),
            image: DecorationImage(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // ✅ Remove button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              itemController.removeImage(index);

              // ✅ Notify parent with updated list
              if (onImagesSelected != null) {
                onImagesSelected!(itemController.selectedImage.toList());
              }

              if (kDebugMode) {
                print("🗑️ Image removed. Remaining: ${itemController.selectedImage.length}");
              }
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // ✅ Image index badge
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "${index + 1}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}



// import 'dart:io';
// import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class MultiImagePickerWidget extends StatelessWidget {
//   final ItemController itemController = Get.find<ItemController>();
//
//   // ✅ Callback to notify parent when images change
//   final Function(List<File>)? onImagesSelected;
//
//   MultiImagePickerWidget({super.key, this.onImagesSelected});
//
//   void _showImageSourceDialog(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) {
//         return Wrap(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text("Take Photo"),
//               onTap: () async {
//                 Navigator.pop(context);
//                 await itemController.pickFromCamera();
//                 onImagesSelected?.call(itemController.selectedImage);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text("Select from Gallery"),
//               onTap: () async {
//                 Navigator.pop(context);
//                 await itemController.pickFromGalleryMultiple();
//                 onImagesSelected?.call(itemController.selectedImage);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final images = itemController.selectedImage;
//
//       return GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           crossAxisSpacing: 8,
//           mainAxisSpacing: 8,
//         ),
//         itemCount: images.length + 1,
//         itemBuilder: (context, index) {
//           if (index == images.length) {
//             return GestureDetector(
//               onTap: () => _showImageSourceDialog(context),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFCEBFC),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(
//                   Icons.add_a_photo_outlined,
//                   size: 32,
//                   color: Colors.black54,
//                 ),
//               ),
//             );
//           }
//           return Stack(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   image: DecorationImage(
//                     image: FileImage(images[index]),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 2,
//                 right: 2,
//                 child: GestureDetector(
//                   onTap: () {
//                     itemController.removeImage(index);
//                     onImagesSelected?.call(itemController.selectedImage);
//                   },
//                   child: const CircleAvatar(
//                     radius: 12,
//                     backgroundColor: Colors.black54,
//                     child: Icon(Icons.close, size: 14, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       );
//     });
//   }
// }
