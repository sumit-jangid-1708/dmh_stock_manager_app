import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppLists{

  static final _storage = GetStorage();
  static const _key = "materials";
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
 /// Basic Colors List
  static const List<String> colors = [
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


  /// Clothing Sizes
  static const List<String> sizes = [
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

   /// Clothing Materials
  // Default materials
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

  // Load materials (saved + default)
  static List<String> get materials {
    final stored = _storage.read<List>(_key)?.cast<String>() ?? [];
    return [...defaultMaterials, ...stored];
  }

  // Add new material and save it
  static void addMaterial(String material) {
    final stored = _storage.read<List>(_key)?.cast<String>() ?? [];
    stored.add(material);
    _storage.write(_key, stored);
  }
}