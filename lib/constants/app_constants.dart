class AppConstants {
  // App Name
  static const String appName = 'LocaLink';

  // Product Categories
  static const List<String> productCategories = [
    'Groceries',
    'Bakery',
    'Dairy Products',
    'Stationeries',
    'Gift Shops',
    'Meat',
    'Clothing & Accessories',
    'Pharma',
  ];

  // Service Categories
  static const List<String> serviceCategories = [
    'Saloon',
    'Mechanic Shops',
    'Cyber Cafes',
    'Pet Care',
    'Tailors',
  ];
  
  // Order Status
  static const String orderStatusPending = 'Pending';
  static const String orderStatusAccepted = 'Accepted';
  static const String orderStatusCompleted = 'Completed';
  
  // Service Status
  static const String serviceStatusAvailable = 'Available';
  static const String serviceStatusUnavailable = 'Unavailable';
  
  // Stock Status
  static const String stockStatusInStock = 'In Stock';
  static const String stockStatusOutOfStock = 'Out of Stock';
  
  // User Roles
  static const String roleCustomer = 'customer';
  static const String roleVendor = 'vendor';
  
  // Default Values
  static const double defaultDistance = 5.0; // 5 km radius
  static const int defaultCartQuantity = 1;
  
  // Animations
  static const int animationDuration = 300;
  static const int longAnimationDuration = 500;
}
