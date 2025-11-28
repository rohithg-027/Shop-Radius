# LocaLink - Hyperlocal Marketplace & Services

A comprehensive Flutter mobile application that connects nearby shops and local service providers with customers.

## Features

### Customer App
- ✅ **Browse Nearby Shops** - Discover shops within 5km radius
- ✅ **Product Categories** - Groceries, Bakery, Dairy, Stationeries, Gifts, Meat, Clothing, Pharma
- ✅ **Shopping Cart** - Add/remove items, manage quantities
- ✅ **Order Placement** - Delivery address & payment method selection
- ✅ **Order Tracking** - Real-time order status (Pending → Accepted → Completed)
- ✅ **User Profile** - View and update personal information

### Vendor App
- ✅ **Vendor Onboarding** - Register shop with category selection
- ✅ **Dashboard** - Business analytics and statistics
- ✅ **Order Management** - View and update order statuses
- ✅ **Service Categories** - Saloon, Mechanic, Cyber Cafe, Pet Care, Tailors
- ✅ **Product Management** - Add/edit/delete products

### Authentication
- ✅ **Role-based Login** - Separate flows for Customer & Vendor
- ✅ **Sign-up Screen** - Create new accounts
- ✅ **Profile Management** - Update user information

### UI/UX
- ✅ **Material 3 Design** - Modern, minimal interface
- ✅ **Smooth Animations** - Transitions and interactions
- ✅ **Responsive Layout** - Optimized for all screen sizes
- ✅ **Custom Theme** - Primary: #2563eb, Secondary: #1e293b, Background: #f8fafc

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── constants/
│   ├── app_constants.dart            # Constants & configs
│   └── theme.dart                    # Material 3 theme
├── models/                           # Data models
│   ├── product.dart
│   ├── service.dart
│   ├── order.dart
│   ├── cart_item.dart
│   ├── user.dart
│   ├── vendor.dart
│   ├── shop.dart
│   └── service_booking.dart
├── providers/                        # State management (Provider)
│   ├── auth_provider.dart
│   ├── cart_provider.dart
│   ├── data_provider.dart
│   ├── vendor_provider.dart
│   └── shop_provider.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── customer/
│   │   ├── customer_home_screen.dart
│   │   ├── product_list_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── order_confirmation_screen.dart
│   │   └── profile_screen.dart
│   └── vendor/
│       ├── vendor_onboarding_screen.dart
│       └── vendor_dashboard_screen.dart
├── widgets/                          # Reusable components
│   ├── product_card.dart
│   ├── service_card.dart
│   ├── shop_card.dart
│   └── category_chip.dart
└── data/
    └── dummy_data.dart              # Mock data for development
```

## Getting Started

### Prerequisites
- Flutter SDK (3.10+)
- Dart SDK (3.10+)
- Android Studio or Xcode

### Installation

1. **Clone the repository**
```bash
cd flutter_application_1
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

## Key Technologies

- **Flutter** - UI framework
- **Provider** - State management
- **Material 3** - Design system
- **UUID** - Unique ID generation
- **Intl** - Internationalization

## App Flow

### Customer Journey
1. Login/Signup → Role Selection (Customer)
2. Home Screen → Browse Shops & Categories
3. Product Details → Add to Cart
4. Checkout → Enter Delivery Details
5. Order Confirmation → Order Status Tracking
6. Profile Management

### Vendor Journey
1. Login/Signup → Role Selection (Vendor)
2. Vendor Onboarding → Shop Registration
3. Dashboard → Business Analytics
4. Order Management → Update Status
5. Product Management → Add/Edit/Delete

## Dummy Data

The app uses local dummy data for:
- 20+ Products across 8 categories
- 10+ Services across 5 categories
- 8 Nearby shops
- 5 Registered vendors

All data is stored in `lib/data/dummy_data.dart`.

## Color Scheme

- **Primary**: #2563eb (Blue)
- **Secondary**: #1e293b (Slate)
- **Background**: #F8fafc (Light)
- **Success**: #22c55e (Green)
- **Error**: #ef4444 (Red)
- **Warning**: #f59e0b (Amber)

## Future Enhancements

- Real-time order notifications
- Payment gateway integration
- User reviews and ratings
- Wishlist feature
- Order history
- Real location services
- Multiple language support
- Dark mode

## License

This project is licensed under the MIT License.

## Support

For issues or feature requests, please contact the development team.
