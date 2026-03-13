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
  final bool enabled; // ✅ Added enabled parameter

  const CustomSearchableDropdown({
    super.key,
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
    this.enabled = true, // ✅ Default to true
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: enabled
          ? () => _showSearchBottomSheet(context)
          : null, // ✅ Conditional onTap
      child: Container(
        height: height ?? 56,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: enabled
              ? (fillColor ?? Colors.grey.shade50)
              : Colors.grey.shade200, // ✅ Disabled color
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled
                ? (borderColor ?? Colors.grey.shade200)
                : Colors.grey.shade300, // ✅ Disabled border
          ),
        ),
        child: Row(
          children: [
            if (prefixIcon != null) ...[
              Icon(
                prefixIcon,
                color: enabled
                    ? (iconColor ?? const Color(0xFF1A1A4F))
                    : Colors.grey.shade400, // ✅ Disabled icon color
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Obx(
                () => Text(
                  selectedItem.value != null
                      ? itemAsString(selectedItem.value as T)
                      : hintText,
                  style: TextStyle(
                    fontSize: 14,
                    color: enabled
                        ? (selectedItem.value != null
                              ? Colors.black87
                              : Colors.grey.shade600)
                        : Colors.grey.shade500, // ✅ Disabled text color
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: enabled
                  ? (iconColor ?? Colors.grey)
                  : Colors.grey.shade400, // ✅ Disabled arrow color
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchBottomSheet(BuildContext context) {
    if (!enabled) return; // ✅ Don't open if disabled

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return _SearchListContent<T>(
              items: items,
              selectedItem: selectedItem,
              itemAsString: itemAsString,
              hintText: hintText,
              prefixIcon: prefixIcon,
              searchHint: searchHint,
              enableSearch: enableSearch,
              customItemBuilder: customItemBuilder,
              onChanged: onChanged,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }
}

// ✅ Separate Stateful widget with search functionality
class _SearchListContent<T> extends StatefulWidget {
  final List<T> items;
  final Rx<T?> selectedItem;
  final String Function(T) itemAsString;
  final String hintText;
  final IconData? prefixIcon;
  final String searchHint;
  final bool enableSearch;
  final Widget Function(T)? customItemBuilder;
  final void Function(T?)? onChanged;
  final ScrollController scrollController;

  const _SearchListContent({
    required this.items,
    required this.selectedItem,
    required this.itemAsString,
    required this.hintText,
    this.prefixIcon,
    required this.searchHint,
    required this.enableSearch,
    this.customItemBuilder,
    this.onChanged,
    required this.scrollController,
  });

  @override
  State<_SearchListContent<T>> createState() => _SearchListContentState<T>();
}

class _SearchListContentState<T> extends State<_SearchListContent<T>> {
  late TextEditingController _searchController;
  late RxList<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = RxList<T>.from(widget.items);

    if (widget.enableSearch) {
      _searchController.addListener(_filterItems);
    }
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      _filteredItems.assignAll(widget.items);
    } else {
      _filteredItems.assignAll(
        widget.items.where((item) {
          return widget.itemAsString(item).toLowerCase().contains(query);
        }).toList(),
      );
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  Icon(
                    widget.prefixIcon,
                    color: const Color(0xFF1A1A4F),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    widget.hintText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A4F),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ✅ Search Bar with controller
          if (widget.enableSearch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF1A1A4F),
                  ),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (_, value, __) {
                      return value.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () => _searchController.clear(),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

          if (widget.enableSearch) const SizedBox(height: 12),

          // List of items
          Expanded(
            child: Obx(() {
              if (_filteredItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No items found",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                controller: widget.scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _filteredItems.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isSelected = widget.selectedItem.value == item;

                  return ListTile(
                    leading: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF1A1A4F),
                            size: 24,
                          )
                        : Icon(
                            Icons.circle_outlined,
                            color: Colors.grey.shade400,
                            size: 24,
                          ),
                    title: widget.customItemBuilder != null
                        ? widget.customItemBuilder!(item)
                        : Text(
                            widget.itemAsString(item),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFF1A1A4F)
                                  : Colors.black87,
                            ),
                          ),
                    onTap: () {
                      widget.selectedItem.value = item;
                      widget.onChanged?.call(item);
                      Navigator.pop(context);
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    tileColor: isSelected
                        ? const Color(0xFF1A1A4F).withOpacity(0.05)
                        : null,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
