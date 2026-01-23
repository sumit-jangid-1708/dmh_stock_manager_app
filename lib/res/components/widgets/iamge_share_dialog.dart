import 'dart:io';
import 'package:dmj_stock_manager/model/product_model.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
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
      Get.snackbar(
        "Selection Required",
        "Please select at least one image.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
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
        await Share.shareXFiles(
          filesToShare,
          text: "Check out these product images!",
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to share: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = product.productImageVariants;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: Get.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Header ---
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A4F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.share_rounded,
                    color: Color(0xFF1A1A4F),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Share Product Images",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A4F),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 24),

            // --- Grid of Images ---
            if (images.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text("No images found for this product."),
              )
            else
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final imageUrl =
                        "https://traders.testwebs.in${images[index].toString()}";

                    return Obx(() {
                      final isSelected = selectedImages.contains(imageUrl);
                      return GestureDetector(
                        onTap: () => isSelected
                            ? selectedImages.remove(imageUrl)
                            : selectedImages.add(imageUrl),
                        child: Stack(
                          children: [
                            // Image Card
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF1A1A4F)
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                            // Selection Overlay
                            if (isSelected)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF1A1A4F,
                                    ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    });
                  },
                ),
              ),

            const SizedBox(height: 24),

            // --- Footer Buttons ---
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AppGradientButton(
                    onPressed: _shareImages,
                    text: "Share Now",
                    icon: Icons.ios_share_rounded,
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
