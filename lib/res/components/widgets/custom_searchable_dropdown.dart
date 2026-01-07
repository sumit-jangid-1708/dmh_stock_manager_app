// widgets/custom_searchable_dropdown.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSearchableDropdown<T> extends StatelessWidget {
  final List<T> items;
  final Rx<T?> selectedItem;
  final String Function(T) itemAsString;
  final String hintText;
  final IconData? prefixIcon;
  final bool enableSearch;
  final String searchHint;
  final void Function(T?)? onChanged;
  final Color? fillColor;
  final Color? borderColor;
  final Color? iconColor;
  final double? height;
  final Widget Function(T)? customItemBuilder;

  const CustomSearchableDropdown({
    Key? key,
    required this.items,
    required this.selectedItem,
    required this.itemAsString,
    this.hintText = "Select Item",
    this.prefixIcon,
    this.enableSearch = true,
    this.searchHint = "Search...",
    this.onChanged,
    this.fillColor,
    this.borderColor,
    this.iconColor,
    this.height,
    this.customItemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showSearchDialog(context),
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: fillColor ?? Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor ?? Colors.grey.shade200),
        ),
        child: Row(
          children: [
            if (prefixIcon != null) ...[
              Icon(prefixIcon, color: iconColor ?? const Color(0xFF1A1A4F), size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Obx(() => Text(
                selectedItem.value != null
                    ? itemAsString(selectedItem.value as T)
                    : hintText,
                style: TextStyle(
                  fontSize: 14,
                  color: selectedItem.value != null
                      ? Colors.black87
                      : Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              )),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: iconColor ?? Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => _SearchDialog<T>(
        items: items,
        selectedItem: selectedItem,
        itemAsString: itemAsString,
        hintText: hintText,
        prefixIcon: prefixIcon,
        enableSearch: enableSearch,
        searchHint: searchHint,
        customItemBuilder: customItemBuilder,
        onChanged: onChanged,
      ),
    );
  }
}

// ✅ Separate StatefulWidget for proper lifecycle management
class _SearchDialog<T> extends StatefulWidget {
  final List<T> items;
  final Rx<T?> selectedItem;
  final String Function(T) itemAsString;
  final String hintText;
  final IconData? prefixIcon;
  final bool enableSearch;
  final String searchHint;
  final Widget Function(T)? customItemBuilder;
  final void Function(T?)? onChanged;

  const _SearchDialog({
    Key? key,
    required this.items,
    required this.selectedItem,
    required this.itemAsString,
    required this.hintText,
    this.prefixIcon,
    required this.enableSearch,
    required this.searchHint,
    this.customItemBuilder,
    this.onChanged,
  }) : super(key: key);

  @override
  State<_SearchDialog<T>> createState() => _SearchDialogState<T>();
}

class _SearchDialogState<T> extends State<_SearchDialog<T>> {
  late TextEditingController searchCtrl;
  late RxList<T> filteredItems;

  @override
  void initState() {
    super.initState();
    searchCtrl = TextEditingController();
    filteredItems = RxList<T>.from(widget.items);
    searchCtrl.addListener(_filterItems);
  }

  void _filterItems() {
    final query = searchCtrl.text.toLowerCase();
    if (query.isEmpty) {
      filteredItems.assignAll(widget.items);
    } else {
      filteredItems.assignAll(
        widget.items
            .where((item) =>
            widget.itemAsString(item).toLowerCase().contains(query))
            .toList(),
      );
    }
  }

  @override
  void dispose() {
    searchCtrl.removeListener(_filterItems);
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.7,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (widget.prefixIcon != null) ...[
                    Icon(widget.prefixIcon, color: const Color(0xFF1A1A4F)),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      widget.hintText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Search Bar (Conditional)
            if (widget.enableSearch)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: searchCtrl,
                      builder: (_, value, __) {
                        return value.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => searchCtrl.clear(),
                        )
                            : const SizedBox.shrink();
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

            if (widget.enableSearch) const SizedBox(height: 16),

            // Items List with proper constraints
            Flexible(
              child: Obx(() {
                if (filteredItems.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "No items found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: filteredItems.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final isSelected = widget.selectedItem.value == item;

                    return ListTile(
                      leading: isSelected
                          ? const Icon(
                        Icons.check_circle,
                        color: Color(0xFF1A1A4F),
                      )
                          : Icon(
                        Icons.circle_outlined,
                        color: Colors.grey.shade400,
                      ),
                      title: widget.customItemBuilder != null
                          ? widget.customItemBuilder!(item)
                          : Text(
                        widget.itemAsString(item),
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        widget.selectedItem.value = item;
                        widget.onChanged?.call(item);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}