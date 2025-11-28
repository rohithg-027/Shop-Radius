import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CategoryIcon {
  static final Map<String, IconData> _icons = {
    // Products
    'groceries': Iconsax.box,
    'bakery': Iconsax.cake,
    'dairy': Iconsax.cup,
    'fresh meat': Icons.kebab_dining,
    'stationery': Iconsax.edit,
    'gift shops': Iconsax.gift,
    'clothing': Icons.checkroom,
    'medicine': Iconsax.health,

    // Services
    'salon': Icons.cut,
    'mechanic': Iconsax.setting_2,
    'cyber café': Iconsax.monitor,
    'laundry': Icons.local_laundry_service,
    'gaming': Iconsax.gameboy,
    'pet shop': Icons.pets,
    'home repair': Iconsax.home_2,
    'electrician': Iconsax.flash_1,

    'default': Iconsax.category,
  };

  static IconData getIcon(String? iconName) {
    return _icons[iconName?.toLowerCase()] ?? _icons['default']!;
  }
}