import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/product_models/product_model.dart';


class OrderItems {
  Rxn<ProductModel> product = Rxn<ProductModel>();
  TextEditingController quantity = TextEditingController();
  TextEditingController unitPrice = TextEditingController();

  void dispose() {
    quantity.dispose();
    unitPrice.dispose();
  }
}