import 'package:flutter/material.dart';

class PastProductsTable extends StatelessWidget {
  final List<Map<String, String>> pastProducts;
  const PastProductsTable({super.key, required this.pastProducts});

   @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:  Color(0xfff8f8f8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Past Products",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12,),
           // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A4F),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text("PO-#", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white))),
                Expanded(flex: 3, child: Text("Date", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white))),
                Expanded(flex: 2, child: Text("items", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white))),
                Expanded(flex: 2, child: Text("Total", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white))),
                Expanded(flex: 3, child: Text("Status", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white))),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Table Rows
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:pastProducts.length,
            itemBuilder: (context, index) {
              final product = pastProducts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                child: Row(
                   children: [
                    Expanded(flex: 3, child: Text(product["po"] ?? "",style: TextStyle(fontSize: 10))),
                    Expanded(flex: 3, child: Text(product["date"] ?? "",style: TextStyle(fontSize: 10))),
                    Expanded(flex: 2, child: Text(product["items"] ?? "",style: TextStyle(fontSize: 10))),
                    Expanded(flex: 2, child: Text(product["total"] ?? "",style: TextStyle(fontSize: 10))),
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product["status"] ?? "",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 10
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}