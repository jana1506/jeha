# Laza - E-commerce Mobile App 🛍️

A full-featured e-commerce mobile application built with Flutter, Firebase, and the Platzi Fake Store API. Features include user authentication, product browsing with search and filtering, shopping cart, favorites, order management, and secure checkout.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 📱 Screenshots

[Add your app screenshots here]

```
screenshots/
├── login.png
├── home.png
├── product_detail.png
├── cart.png
├── checkout.png
└── orders.png
```

---

## ✨ Features

### Authentication
- ✅ Email/Password signup and login (Firebase Auth)
- ✅ Email validation with proper error handling
- ✅ Password strength indicator
- ✅ Auto-login (persistent session)
- ✅ Secure logout functionality

### Product Browsing
- ✅ Browse all products from Platzi Fake Store API
- ✅ Real-time search functionality
- ✅ Category filtering (All, Clothes, Electronics, Furniture, Shoes, Others)
- ✅ Combined search + category filters
- ✅ Product details with image gallery
- ✅ Swipe through product images

### Shopping Experience
- ✅ Add products to cart
- ✅ Update quantities
- ✅ Remove items from cart
- ✅ Add/remove favorites (wishlist)
- ✅ Real-time price calculation
- ✅ Empty state handling

### Checkout & Orders
- ✅ Delivery address management
- ✅ Payment card management (last 4 digits stored securely)
- ✅ Order creation and tracking
- ✅ Order history with status
- ✅ Order confirmation screen

### User Profile
- ✅ Sidebar navigation drawer
- ✅ View order count
- ✅ Manage payment cards
- ✅ Access favorites/wishlist
- ✅ User verification badge

---

## 🏗️ Architecture

```
lib/
├── features/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── product/
│   │   └── product_detail_screen.dart
│   ├── cart/
│   │   └── cart_screen.dart
│   ├── favorites/
│   │   └── favorites_screen.dart
│   ├── checkout/
│   │   ├── address_screen.dart
│   │   ├── payment_screen.dart
│   │   ├── add_card_screen.dart
│   │   └── order_confirmation_screen.dart
│   ├── orders/
│   │   └── orders_screen.dart
│   └── profile/
│       └── app_drawer.dart
├── services/
│   ├── api_service.dart
│   ├── auth_service.dart
│   └── database_service.dart
└── main.dart
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / Xcode (for mobile development)
- Firebase account
- Git

### 1. Install Flutter

#### Windows
```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
# Extract to C:\src\flutter
# Add to PATH: C:\src\flutter\bin

# Verify installation
flutter doctor
```

#### macOS
```bash
# Download Flutter SDK
cd ~/development
unzip ~/Downloads/flutter_macos_*.zip

# Add to PATH in ~/.zshrc or ~/.bash_profile
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

#### Linux
```bash
# Download Flutter SDK
cd ~/development
tar xf ~/Downloads/flutter_linux_*.tar.xz

# Add to PATH in ~/.bashrc
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

### 2. Clone the Repository

```bash
git clone https://github.com/yourusername/laza-ecommerce.git
cd laza-ecommerce
```

### 3. Install Dependencies

```bash
# Get Flutter packages
flutter pub get

# For iOS (macOS only)
cd ios
pod install
cd ..
```

### 4. Firebase Setup

#### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add Project"
3. Enter project name: `laza-ecommerce`
4. Follow the setup wizard

#### Step 2: Add Firebase to Your App

##### Android Setup
1. In Firebase Console, click "Add app" → Android
2. Register app with package name: `com.example.flutter_application_1`
3. Download `google-services.json`
4. Place file in: `android/app/google-services.json`

##### iOS Setup (macOS only)
1. In Firebase Console, click "Add app" → iOS
2. Register app with Bundle ID: `com.example.flutterApplication1`
3. Download `GoogleService-Info.plist`
4. Place file in: `ios/Runner/GoogleService-Info.plist`

##### Web Setup
1. In Firebase Console, click "Add app" → Web
2. Register app and copy configuration
3. Add to `web/index.html`:

```html
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js"></script>

<script>
  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_STORAGE_BUCKET",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID"
  };
  firebase.initializeApp(firebaseConfig);
</script>
```

#### Step 3: Enable Firebase Services

1. **Authentication**
   - Go to Authentication → Sign-in method
   - Enable "Email/Password"

2. **Firestore Database**
   - Go to Firestore Database
   - Create database in production mode
   - Choose location closest to your users

3. **Create Required Indexes**
   
   Go to Firestore → Indexes → Create Index:

   **Orders Index:**
   - Collection ID: `orders`
   - Fields:
     - `userId` - Ascending
     - `createdAt` - Descending

   Or click this auto-generated link after first error to create index automatically.

#### Step 4: Firestore Security Rules

Go to Firestore → Rules and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the resource
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read, write: if isAuthenticated() && isOwner(userId);
      
      // User addresses
      match /addresses/{addressId} {
        allow read, write: if isAuthenticated() && isOwner(userId);
      }
      
      // User payment cards
      match /cards/{cardId} {
        allow read, write: if isAuthenticated() && isOwner(userId);
      }
    }
    
    // Carts collection
    match /carts/{userId}/{document=**} {
      allow read, write: if isAuthenticated() && isOwner(userId);
    }
    
    // Favorites collection
    match /favorites/{userId}/{document=**} {
      allow read, write: if isAuthenticated() && isOwner(userId);
    }
    
    // Orders collection
    match /orders/{orderId} {
      allow read: if isAuthenticated() && resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      allow update: if false; // Orders cannot be updated by users
      allow delete: if false; // Orders cannot be deleted by users
    }
  }
}
```

Click **Publish** to apply the rules.

---

## 🏃 Running the App

### Run on Android Emulator
```bash
# Start Android emulator first, then:
flutter run -d android
```

### Run on iOS Simulator (macOS only)
```bash
# Start iOS simulator first, then:
flutter run -d ios
```

### Run on Web
```bash
flutter run -d chrome
# or
flutter run -d edge
```

### Run on Physical Device
```bash
# Connect device via USB, enable USB debugging, then:
flutter run
```

---

## 🏗️ Building for Production

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (macOS only)
```bash
flutter build ios --release
# Then open Xcode and archive for App Store
```

### Web
```bash
flutter build web --release
# Output: build/web/
```

---

## 🧪 Testing

### Appium Tests

**Prerequisites:**
```bash
npm install -g appium
npm install -g appium-doctor
appium-doctor --android  # Verify Android setup
```

**Test Files Location:**
```
appium_tests/
├── auth_test.js
├── cart_test.js
└── test_cases.md
```

**Run Tests:**
```bash
# Start Appium server
appium

# In another terminal, run tests
cd appium_tests
npm test

# Or run specific test
node auth_test.js
```

### Test Cases

#### Test 1: Authentication Flow
```
Steps:
1. Open app
2. Navigate to signup screen
3. Fill email and password
4. Submit signup
5. Navigate to login screen  
6. Fill credentials
7. Submit login
8. Verify user reaches home screen

Expected: User successfully authenticated and on home screen
```

#### Test 2: Cart Flow
```
Steps:
1. Open app
2. Tap on first product
3. Tap "Add to Cart" button
4. Navigate to cart screen
5. Verify product appears in cart

Expected: Product is visible in cart with correct details
```

**Test Results:**
Results are saved in: `appium_tests/results/`

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  
  # HTTP & API
  http: ^1.1.0
  
  # Date formatting
  intl: ^0.18.0
  
  # UI
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

---

## 🗄️ Firestore Database Structure

```
firestore/
├── users/
│   └── {userId}/
│       ├── email: string
│       ├── createdAt: timestamp
│       ├── addresses/
│       │   └── primary/
│       │       ├── name: string
│       │       ├── country: string
│       │       ├── city: string
│       │       ├── phone: string
│       │       └── address: string
│       └── cards/
│           └── {cardId}/
│               ├── type: string (visa/mastercard)
│               ├── owner: string
│               ├── lastFourDigits: string
│               └── expiry: string
│
├── carts/
│   └── {userId}/
│       └── items/
│           └── {productId}/
│               ├── id: number
│               ├── title: string
│               ├── price: number
│               ├── image: string
│               └── quantity: number
│
├── favorites/
│   └── {userId}/
│       └── items/
│           └── {productId}/
│               ├── id: number
│               ├── title: string
│               ├── price: number
│               ├── image: string
│               └── addedAt: timestamp
│
└── orders/
    └── {orderId}/
        ├── orderId: string
        ├── userId: string
        ├── items: array
        ├── address: object
        ├── payment: object
        ├── pricing: object
        │   ├── subtotal: number
        │   ├── shipping: number
        │   └── total: number
        ├── status: string
        ├── createdAt: timestamp
        └── updatedAt: timestamp
```

---

## 🌐 API Integration

This app uses the [Platzi Fake Store API](https://fakeapi.platzi.com/) for product data.

**Endpoints Used:**
- `GET /api/v1/products` - Fetch all products
- `GET /api/v1/products/{id}` - Fetch single product

**API Response Structure:**
```json
{
  "id": 1,
  "title": "Product Name",
  "price": 100,
  "description": "Product description",
  "images": ["url1", "url2", "url3"],
  "category": {
    "id": 1,
    "name": "Clothes",
    "image": "url"
  }
}
```

---

## 🎨 Color Scheme

```dart
Primary Purple: #9775FA
Success Green: #34C759
Error Red: #EA4335
Text Primary: #1D1E20
Text Secondary: #8F959E
Background: #F5F6FA
Border: #E7EAEF
```

---

## 🔒 Security Features

- ✅ Firebase Authentication for user management
- ✅ Firestore security rules to protect user data
- ✅ Password hashing handled by Firebase
- ✅ Only last 4 digits of cards stored (never full card numbers)
- ✅ CVV never stored in database
- ✅ User data isolated per account
- ✅ Secure HTTPS API calls

---

## 🐛 Troubleshooting

### Common Issues

**Issue: `LateInitializationError`**
```bash
# Solution: Delete build cache and rebuild
flutter clean
flutter pub get
flutter run
```

**Issue: Firebase not connecting**
```bash
# Verify Firebase configuration files exist:
# - android/app/google-services.json
# - ios/Runner/GoogleService-Info.plist
# - web/index.html (Firebase config)
```

**Issue: Firestore permission denied**
```bash
# Solution: Check Firestore security rules are properly configured
# Go to Firebase Console → Firestore → Rules
```

**Issue: Orders not loading**
```bash
# Solution: Create the Firestore index
# Click the link in the error message or manually create index:
# Collection: orders
# Fields: userId (Ascending), createdAt (Descending)
```

---

## 📝 Project Checklist

- [x] Authentication (Login/Signup)
- [x] Product browsing with API
- [x] Search functionality
- [x] Category filtering
- [x] Product details
- [x] Shopping cart
- [x] Favorites/Wishlist
- [x] Address management
- [x] Payment card management
- [x] Checkout flow
- [x] Order creation
- [x] Order history
- [x] User profile/drawer
- [x] Firebase integration
- [x] Firestore security rules
- [x] Error handling
- [x] Loading states
- [x] Empty states
- [x] Appium tests (optional)

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - UI framework
- [Firebase](https://firebase.google.com/) - Backend services
- [Platzi Fake Store API](https://fakeapi.platzi.com/) - Product data
- [Figma Laza UI Kit](https://www.figma.com/community) - Design inspiration

---

## 📱 Screenshots Gallery

### Authentication
| Login | Signup |
|-------|--------|
| <img width="187" height="421" alt="image" src="https://github.com/user-attachments/assets/94e7312d-f635-4e6e-b64e-46bb918a7c5f" />
 |<img width="190" height="421" alt="image" src="https://github.com/user-attachments/assets/96221e1e-8f02-4f10-871b-d20bf0234e5c" />
 |

### Home & Products
| Home | Product Detail |
|------|----------------|
| <img width="191" height="422" alt="image" src="https://github.com/user-attachments/assets/7b3e4a5c-ba97-4f7b-b318-7b8655fa97bd" />
 |<img width="204" height="458" alt="image" src="https://github.com/user-attachments/assets/eaea3017-c40d-4c11-8035-3f6a2705062e" />
 |

### Cart & Checkout
| Cart |  Payment | Address |
|------|---------|---------|
|<img width="195" height="424" alt="image" src="https://github.com/user-attachments/assets/32836a99-e6be-4f2f-ace4-b934f87e06cd" />
 |<img width="206" height="458" alt="image" src="https://github.com/user-attachments/assets/615b940a-c362-4abe-af84-e2191f94449f" />
 |<img width="211" height="461" alt="image" src="https://github.com/user-attachments/assets/fd9948ad-62ba-4d67-a791-0fe484d2e027" />
 |

### Orders & Profile
| Orders | Confirmation |
|--------|--------------|
| <img width="208" height="470" alt="image" src="https://github.com/user-attachments/assets/7c95af42-9db1-451f-adea-d0e074e96bff" />
|<img width="204" height="462" alt="image" src="https://github.com/user-attachments/assets/ce5193d0-8d89-42ec-8488-ef2e136e356e" />
 |

---

## 🚀 Future Enhancements

- [ ] Push notifications for order updates
- [ ] Product reviews and ratings
- [ ] Advanced filtering options
- [ ] Order tracking with real-time updates
- [ ] Multiple delivery addresses
- [ ] Promo codes and discounts
- [ ] Social media authentication
- [ ] Dark mode support
- [ ] Multi-language support
- [ ] Payment gateway integration

---

**Made with ❤️ and Flutter**
