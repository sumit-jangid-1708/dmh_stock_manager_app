import 'package:dmj_stock_manager/view_models/controller/history_controller.dart';
import 'package:flutter/material.dart';

class HistoryRow extends StatelessWidget {
  final HistoryModel data;
  const HistoryRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFDDDDDD))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(data.dateTime.toString().substring(0, 16))),
          Expanded(child: Text(data.action)),
          Expanded(child: Text(data.sku)),
          Expanded(
              child: Text(
            data.details,
            style: const TextStyle(color: Colors.green),
          )),
          Expanded(
              child: Text(
            data.alert,
            style: const TextStyle(color: Colors.red),
          )),
        ],
      ),
    );
  }
}
