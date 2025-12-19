import 'dart:io';
import 'package:dmj_stock_manager/model/product_model.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ImageShareDialog extends StatelessWidget {
  final ItemController itemController = Get.find<ItemController>();
  final ProductModel product;

  ImageShareDialog({super.key, required this.product});

  final RxList<String> selectedImages = <String>[].obs;

  Future<void> _shareImages() async {
    if (selectedImages.isEmpty) {
      Get.snackbar("No Image Selected", "Please select at least one image to share.",
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.white30);
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final List<XFile> filesToShare = [];

      for (String url in selectedImages) {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final file = File('${tempDir.path}/${url.split('/').last}');
          await file.writeAsBytes(response.bodyBytes);
          filesToShare.add(XFile(file.path));
        }
      }

      if (filesToShare.isNotEmpty) {
        await Share.shareXFiles(filesToShare, text: "Check out these product images!");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to share images: $e",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = product.productImageVariants;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Select Image to Share",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Image list
            if (images.isEmpty)
              const Text("No images found for this product.")
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: images.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final imageUrl =
                        "https://traders.testwebs.in${images[index].toString()}";

                    return Obx(() {
                      final isSelected = selectedImages.contains(imageUrl);
                      return ListTile(
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                        title: Text("Image ${index + 1}"),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (_) {
                            if (isSelected) {
                              selectedImages.remove(imageUrl);
                            } else {
                              selectedImages.add(imageUrl);
                            }
                          },
                          activeColor: const Color(0xFF1A1A4F),
                        ),
                        onTap: () {
                          if (isSelected) {
                            selectedImages.remove(imageUrl);
                          } else {
                            selectedImages.add(imageUrl);
                          }
                        },
                      );
                    });
                  },
                ),
              ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A4F),
                  ),
                  onPressed: _shareImages,
                  child: const Text(
                    "Share",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
