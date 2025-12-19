import 'dart:io';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
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
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () async {
                Navigator.pop(context);
                await itemController.pickFromCamera();
                onImagesSelected?.call(itemController.selectedImage);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Select from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                await itemController.pickFromGalleryMultiple();
                onImagesSelected?.call(itemController.selectedImage);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final images = itemController.selectedImage;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: images.length + 1,
        itemBuilder: (context, index) {
          if (index == images.length) {
            return GestureDetector(
              onTap: () => _showImageSourceDialog(context),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEBFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  size: 32,
                  color: Colors.black54,
                ),
              ),
            );
          }
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(images[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: GestureDetector(
                  onTap: () {
                    itemController.removeImage(index);
                    onImagesSelected?.call(itemController.selectedImage);
                  },
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }
}
