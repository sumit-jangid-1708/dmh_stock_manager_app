import 'package:get/get.dart';


class HistoryController extends GetxController {
  var historyList = <HistoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  void fetchHistory() {
    // Mock data - replace with API call later
    historyList.assignAll(List.generate(10, (index) {
      return HistoryModel(
        dateTime: DateTime.now(),
        action: "Stock add",
        sku: "SKU123",
        details: "+50 unit",
        alert: "Low Stock",
      );
    }));
  }

  void clearHistory() {
    historyList.clear();
  }
}

class HistoryModel {
  final DateTime dateTime;
  final String action;
  final String sku;
  final String details;
  final String alert;

  HistoryModel({
    required this.dateTime,
    required this.action,
    required this.sku,
    required this.details,
    required this.alert,
  });
}