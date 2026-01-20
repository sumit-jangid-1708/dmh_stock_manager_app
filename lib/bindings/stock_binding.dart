import 'package:get/get.dart';
import '../view_models/controller/stock_controller.dart';

class StockBinding extends Bindings{
  @override
  void dependencies (){
    Get.lazyPut(()=> StockController());
  }
}