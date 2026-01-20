import 'package:flutter/material.dart';

class BillingFilterBottomSheet extends StatelessWidget {
  const BillingFilterBottomSheet({super.key});

  // Reusable widget for the dropdown selection
  Widget _buildDropdownField({
    required String label,
    required String hintText,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    // A placeholder variable for the selected item in a real app
    String? selectedValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100, // Light grey background
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: selectedValue,
            decoration: const InputDecoration(
              border: InputBorder.none, // Removes the default underline
              contentPadding: EdgeInsets.zero,
            ),
            hint: Text(
              hintText,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (String? newValue) {
              // In a real app, you would update the state here
              // selectedValue = newValue;
              onChanged(newValue);
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Reusable widget for the date input field
  Widget _buildDateField({required String label}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100, // Light grey background
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Text(
                'DD/MM/YYYY',
                style: TextStyle(color: Colors.black54),
              ),
            ),
            // TODO: In a real app, replace Text with a TextField and date picker logic
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Static data placeholders for the dropdowns
    final List<String> vendorList = ['Vendor A', 'Vendor B', 'Vendor C'];
    final List<String> typeList = ['Purchase', 'Sale'];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Keep the sheet content compact
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Vendor Filter ---
          _buildDropdownField(
            label: 'All Vendors',
            hintText: '--Select Vendors--',
            items: vendorList,
            onChanged: (val) => debugPrint('Vendor selected: $val'),
          ),

          // --- Type Filter ---
          _buildDropdownField(
            label: 'All Types',
            hintText: '--Select Type--', // Changed hint to reflect "Type"
            items: typeList,
            onChanged: (val) => debugPrint('Type selected: $val'),
          ),

          // --- Date Range Filters ---
          const SizedBox(height: 8),
          Row(
            children: [
              _buildDateField(label: 'Paid Date'),
              const SizedBox(width: 16),
              _buildDateField(label: 'Due Date'),
            ],
          ),
          const SizedBox(height: 30),

          // --- Apply Filter Button ---
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement filter logic and close the sheet
                Navigator.pop(context); // Closes the bottom sheet
                debugPrint('Filter applied!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A4F), // Dark navy color
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Apply Filter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}