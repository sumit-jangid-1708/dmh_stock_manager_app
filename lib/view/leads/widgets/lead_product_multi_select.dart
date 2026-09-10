import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/product_models/product_model.dart';
import '../../../view_models/controller/item_controller.dart';
import '../../../view_models/controller/lead_controller.dart';

class LeadProductMultiSelect extends StatelessWidget {
  LeadProductMultiSelect({super.key});

  final LeadController leadController = Get.find<LeadController>();
  final ItemController itemController = Get.find<ItemController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return InkWell(
        onTap: () =>
            Get.bottomSheet(_ProductBottomSheet(), isScrollControlled: true),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: Color(0xFF1A1A4F)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  itemController.isLoading.value &&
                          itemController.products.isEmpty
                      ? 'Loading products...'
                      : leadController.selectedProducts.isEmpty
                      ? 'Select interested products'
                      : '${leadController.selectedProducts.length} products selected',
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
        ),
      );
    });
  }
}

class _ProductBottomSheet extends StatelessWidget {
  _ProductBottomSheet();

  final LeadController leadController = Get.find<LeadController>();
  final ItemController itemController = Get.find<ItemController>();
  final searchText = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * .82,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Select Products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Obx(
                () =>
                    Text('${leadController.selectedProducts.length} selected'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: (value) => searchText.value = value.toLowerCase(),
            decoration: InputDecoration(
              hintText: 'Search product name or SKU',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              final products = itemController.products.where((product) {
                return product.name.toLowerCase().contains(searchText.value) ||
                    product.sku.toLowerCase().contains(searchText.value);
              }).toList();

              if (itemController.isLoading.value && products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (products.isEmpty) {
                return const Center(child: Text('No products found'));
              }

              return ListView.separated(
                itemCount: products.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) => _productTile(products[index]),
              );
            }),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A4F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('DONE'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productTile(ProductModel product) {
    return Obx(() {
      final selected = leadController.selectedProducts.any(
        (item) => item.id == product.id,
      );
      return CheckboxListTile(
        value: selected,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(product.name),
        subtitle: Text(product.sku),
        onChanged: (value) {
          if (value == true) {
            leadController.selectedProducts.add(product);
          } else {
            leadController.selectedProducts.removeWhere(
              (item) => item.id == product.id,
            );
          }
        },
      );
    });
  }
}
