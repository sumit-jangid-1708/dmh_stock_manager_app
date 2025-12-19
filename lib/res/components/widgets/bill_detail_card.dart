import 'package:flutter/material.dart';

class BillingCard extends StatelessWidget {
  final String invoiceId;
  final String vendorCustomerName;
  final double billAmount;
  final double paidAmount; // Added to match the screenshot content
  final String paidDate;
  final String dueDate;
  final String status; // Pending, Overdue, Paid
  final String transactionType; // Purchase or Sale

  const BillingCard({
    super.key,
    required this.invoiceId,
    required this.vendorCustomerName,
    required this.billAmount,
    required this.paidAmount,
    required this.paidDate,
    required this.dueDate,
    required this.status,
    required this.transactionType,
  });

  // Helper to determine the status tag color
  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.yellow.shade100; // Light yellow for background
      case 'overdue':
        return Colors.red.shade100; // Light red for background
      default:
        return Colors.grey.shade100;
    }
  }

  // Helper to determine the transaction type tag color (based on a generic scheme)
  Color _getTypeTagColor() {
    return transactionType.toLowerCase() == 'purchase'
        ? Colors.grey.shade200
        : Colors.grey.shade200;
  }

  // Helper for the consistent text/amount row
  Widget _buildAmountRow(String label, double amount, {required bool isOutstanding, required bool isPaidAmount}) {
    // Determine the color for the amount value
    Color amountColor = Colors.black;
    if (isOutstanding && amount > 0) {
      amountColor = Colors.red.shade700; // Red for outstanding amounts
    } else if (isPaidAmount && amount == 0) {
      amountColor = Colors.red.shade700; // Red for zero paid amount
    } else if (isOutstanding && amount == 0) {
      amountColor = Colors.red.shade700;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          Text(
            amount == 0 ? '₹0' : '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: amountColor,
              fontWeight: isOutstanding || isPaidAmount ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate outstanding amount
    double outstandingAmount = billAmount - paidAmount;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0, // Match the subtle look in the screenshot
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200), // Subtle border
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Row 1: Invoice ID, Purchase/Sale Tag, Status Tag ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      invoiceId,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getTypeTagColor(),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        transactionType,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.black, // Dark text on light grey
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: Colors.black, // Dark text for status tag
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // --- Row 2: Vendor/Customer Name ---
            Text(
              vendorCustomerName,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 12),

            // --- Row 3: Bill Amount ---
            _buildAmountRow("₹ Bill Amount", billAmount, isOutstanding: false, isPaidAmount: false),

            // --- Row 4: Paid Amount (Added to match screenshot) ---
            _buildAmountRow("₹ Paid Amount", paidAmount, isOutstanding: false, isPaidAmount: true),

            // --- Row 5: Outstanding Amount ---
            _buildAmountRow("₹ Outstanding", outstandingAmount, isOutstanding: true, isPaidAmount: false),

            const SizedBox(height: 12),

            // --- Row 6: Dates ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Paid Date', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(
                          paidDate,
                          style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Due Date', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(
                          dueDate,
                          style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            Divider(
              thickness: 2,
              // height: 10,
              color: Colors.grey.shade200,
            ),
            // --- Row 7: View Details Button ---
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Action when the button is pressed
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100, // Light grey background
                  foregroundColor: Colors.black, // Dark text/icon color
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 48), // Full width and height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                label: const Text(
                  "View Details",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}