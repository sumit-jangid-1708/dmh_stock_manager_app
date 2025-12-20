import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppLists {
  static final _storage = GetStorage();

  // Storage keys
  static const _materialKey = "materials";
  static const _colorKey = "colors";
  static const _sizeKey = "sizes";

  /// Product Unit List
  static const List<String> productUnit = [
    'kg',
    'g',
    'L',
    'ml',
    'm',
    'cm',
    'mm',
    'pcs',
    'box',
    'dozen',
    'pack',
    'bottle',
    'can',
    'jar',
    'bag',
    'roll',
    'sheet',
    'pair',
    'set',
    'unit',
  ];

  // ============ COLORS ============
  /// Default Colors List
  static List<String> defaultColors = [
    "Red",
    "Blue",
    "Green",
    "Black",
    "White",
    "Yellow",
    "Orange",
    "Purple",
    "Pink",
    "Grey",
    "Brown",
    "Beige",
    "Maroon",
    "Navy",
    "Olive",
    "Teal",
    "Cyan",
  ];

  // Load colors (default + saved)
  static List<String> get colors {
    final stored = _storage.read<List>(_colorKey)?.cast<String>() ?? [];
    return [...defaultColors, ...stored];
  }

  // Add new color and save it
  static void addColor(String color) {
    final stored = _storage.read<List>(_colorKey)?.cast<String>() ?? [];
    stored.add(color);
    _storage.write(_colorKey, stored);
  }

  // ============ SIZES ============
  /// Default Clothing Sizes
  static List<String> defaultSizes = [
    "XS",
    "S",
    "M",
    "L",
    "XL",
    "XXL",
    "3XL",
    "4XL",
    "Free Size",
    "One Size",
  ];

  // Load sizes (default + saved)
  static List<String> get sizes {
    final stored = _storage.read<List>(_sizeKey)?.cast<String>() ?? [];
    return [...defaultSizes, ...stored];
  }

  // Add new size and save it
  static void addSize(String size) {
    final stored = _storage.read<List>(_sizeKey)?.cast<String>() ?? [];
    stored.add(size);
    _storage.write(_sizeKey, stored);
  }

  // ============ MATERIALS ============
  /// Default Clothing Materials
  static List<String> defaultMaterials = [
    "Cotton",
    "Polyester",
    "Linen",
    "Silk",
    "Denim",
    "Wool",
    "Leather",
    "Nylon",
    "Rayon",
    "Viscose",
    "Acrylic",
    "Spandex",
    "Georgette",
    "Chiffon",
    "Velvet",
  ];

  // Load materials (default + saved)
  static List<String> get materials {
    final stored = _storage.read<List>(_materialKey)?.cast<String>() ?? [];
    return [...defaultMaterials, ...stored];
  }

  // Add new material and save it
  static void addMaterial(String material) {
    final stored = _storage.read<List>(_materialKey)?.cast<String>() ?? [];
    stored.add(material);
    _storage.write(_materialKey, stored);
  }
}