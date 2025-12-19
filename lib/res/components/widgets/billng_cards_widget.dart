import 'package:flutter/material.dart';

class BillingCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const BillingCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and icon row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                icon,
                color: const Color(0xFF1A1A4F),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class BillingCardsList extends StatelessWidget {
  const BillingCardsList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cardsData = [
      {
        "title": "Total Outstanding",
        "value": "₹1,75,000",
        "icon": Icons.currency_rupee,
      },
      {
        "title": "Vendors Pending",
        "value": "5",
        "icon": Icons.group,
      },
      {
        "title": "Bill Pending",
        "value": "7",
        "icon": Icons.receipt_long,
      },
      {
        "title": "Bills Completed",
        "value": "18",
        "icon": Icons.done_all,
      },
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cardsData.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final card = cardsData[index];
          return BillingCardWidget(
            title: card['title'],
            value: card['value'],
            icon: card['icon'],
          );
        },
      ),
    );
  }
}
