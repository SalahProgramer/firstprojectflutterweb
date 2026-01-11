
String expandSizeMappings(String size) {
  if (size.isEmpty) {
    return size;
  }

  // Check for longer patterns first to avoid false matches
  if (size.contains("0XL") || size.contains("1XL")) {
    size = "$size,XL";
  }
  if (size.contains("2XL")) {
    size = "$size,XXL";
  }
  if (size.contains("3XL")) {
    size = "$size,XXXL";
  }
  if (size.contains("XXXL")) {
    size = "$size,3XL";
  }
  if (size.contains("XXL")) {
    size = "$size,2XL";
  }
  
  // Check for standalone "XL" - must be an exact match, not part of 3XL, 2XL, 1XL, 0XL, XXL, or XXXL
  final sizesList = size.split(',');
  bool hasStandaloneXL = sizesList.any((s) => s.trim() == 'XL');
  
  if (hasStandaloneXL) {
    size = "$size,0XL,1XL";
  }

  // Remove duplicates and return clean result
  final uniqueSizes = size.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toSet().toList();
  return uniqueSizes.join(',');
}

