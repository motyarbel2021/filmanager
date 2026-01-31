# 🎯 FilaManager AI

**Smart visual and financial management for 3D printer filament inventory with AI-powered recognition.**

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.35.4-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)
![Material Design 3](https://img.shields.io/badge/Material%20Design-3-757575?logo=material-design)
![License](https://img.shields.io/badge/License-Private-red)

</div>

---

## 📱 About

FilaManager AI is a comprehensive mobile application designed for 3D printing enthusiasts to manage their filament inventory efficiently. With AI-powered camera recognition, natural language chatbot, and advanced financial tracking, it's the ultimate tool for filament management.

---

## ✨ Key Features

### 🎯 **Core Features**
- ✅ **Smart Inventory Management** - Track 9 essential filament parameters
- ✅ **Duplicate Prevention** - Intelligent merge system based on 5-key matching
- ✅ **Financial Tracking** - Total value, cost per gram, and detailed analytics
- ✅ **Multi-Currency Support** - USD/ILS with symbol display
- ✅ **Low Stock Alerts** - Customizable threshold notifications
- ✅ **Advanced Search & Filter** - By material, color, AMS compatibility

### 📸 **AI Camera Scanner**
- ✅ Multi-spool detection and recognition
- ✅ 10 sample variations for demo mode
- ✅ Edit before save functionality
- ✅ OCR extraction (Brand, Material, Color, Weight)
- ✅ Ready for Gemini Vision API integration

### 💬 **Natural Language Chatbot**
- ✅ Add spools with simple commands
- ✅ Search and update inventory
- ✅ Financial queries
- ✅ Auto-fill missing data

### 📊 **Statistics & Analytics**
- ✅ Total inventory value display
- ✅ Breakdown by material type
- ✅ Average cost per spool
- ✅ Visual charts and summaries

### 📤 **Export System**
- ✅ CSV Full Data export
- ✅ CSV Summary export
- ✅ JSON backup format
- ✅ Text format for sharing
- ✅ Copy to clipboard functionality

### 🔐 **User Authentication**
- ✅ Email + Password registration
- ✅ Secure login system
- ✅ SHA-256 password encryption
- ✅ Local storage with Hive
- ✅ User profile management

---

## 🏗️ Architecture

### **Tech Stack**
```yaml
Framework: Flutter 3.35.4
Language: Dart 3.9.2
UI: Material Design 3
State Management: Stateful Widgets
Local Storage: Hive 2.2.3 + hive_flutter 1.1.0
Authentication: Custom Email Auth with crypto
```

### **Key Dependencies**
```yaml
dependencies:
  flutter:
    sdk: flutter
  hive: 2.2.3
  hive_flutter: 1.1.0
  shared_preferences: 2.5.3
  image_picker: 1.0.7
  camera: 0.11.0+2
  provider: 6.1.5+1
  http: 1.5.0
  crypto: 3.0.3
  intl: ^0.19.0
  cupertino_icons: ^1.0.8
```

---

## 📊 Data Model

### **Filament Entity** (9 Fields)
```dart
{
  id: String (UUID)
  brand: String (eSun, Bambu Lab, Polymaker, etc.)
  material: String (PLA, PETG, ABS, ASA, TPU, PA-CF)
  subType: String (Silk, Matte, Gradient, Carbon Fiber, High Speed)
  weight: int (1000, 500, 250 grams)
  colorName: String (Red, Blue, Galaxy Purple, etc.)
  colorHex: String (#FF0000, #0000FF, etc.)
  quantity: int (number of spools)
  cost: double (price per spool)
  currency: String (USD, ILS)
  amsCompatible: bool (AMS System compatibility)
  lastUpdated: DateTime (auto-timestamp)
}
```

### **Unique Key** (Duplicate Prevention)
```
brand + material + subType + weight + colorName
```

---

## 🚀 Getting Started

### **Prerequisites**
```bash
Flutter SDK: 3.35.4
Dart SDK: 3.9.2
Android SDK: API 21+ (Android 5.0+)
Java: OpenJDK 17.0.2
```

### **Installation**

#### **1. Clone Repository**
```bash
git clone <repository-url>
cd flutter_app
```

#### **2. Install Dependencies**
```bash
flutter pub get
```

#### **3. Run on Device**
```bash
# Web preview
flutter run -d chrome

# Android device
flutter run -d android

# Build APK
flutter build apk --release
```

### **Web Preview**
The app is also available as a Progressive Web App (PWA):
- Add to home screen for app-like experience
- Offline capability with Hive storage
- Portrait-optimized UI

---

## 📱 App Structure

```
lib/
├── models/
│   ├── filament.dart          # Filament data model
│   └── user.dart              # User authentication model
├── screens/
│   ├── login_screen.dart      # User login
│   ├── register_screen.dart   # User registration
│   ├── inventory_screen.dart  # Main inventory view
│   ├── add_filament_screen.dart # Manual entry form
│   ├── camera_scan_screen.dart  # AI camera scanner
│   ├── chatbot_screen.dart    # NL chatbot interface
│   ├── stats_screen.dart      # Statistics & analytics
│   ├── alerts_screen.dart     # Low stock alerts
│   └── export_screen.dart     # Export functionality
├── services/
│   ├── filament_service.dart  # Business logic
│   ├── auth_service.dart      # Authentication
│   ├── ai_service.dart        # AI detection
│   ├── alerts_service.dart    # Notifications
│   └── export_service.dart    # Export formats
├── widgets/
│   └── filament_card.dart     # Reusable card component
└── main.dart                  # App entry point
```

---

## 🎨 UI/UX Highlights

### **Design System**
- **Primary Color**: Blue (#2196F3)
- **Secondary Color**: Orange (#FF9800)
- **Typography**: Material Design 3 default
- **Icons**: Material Icons
- **Animations**: Fade, Slide, Hero transitions

### **Mobile Optimization**
- ✅ Portrait-only orientation lock
- ✅ Touch-optimized buttons (48x48 minimum)
- ✅ Bottom navigation for easy reach
- ✅ Floating Action Button for primary action
- ✅ Pull-to-refresh support
- ✅ Responsive layout for various screen sizes

---

## 🔐 Security

### **Authentication**
- SHA-256 password hashing
- Secure local storage with Hive
- Session management
- Logout functionality

### **Data Privacy**
- No cloud sync (all data local)
- No analytics or tracking
- Offline-first architecture
- User data never leaves device

---

## 📤 Export Formats

### **1. CSV Full Data**
All filament records with complete details for spreadsheet import.

### **2. CSV Summary**
Condensed view with essential information.

### **3. JSON Backup**
Complete data structure for backup and migration.

### **4. Text Format**
Human-readable format for quick sharing.

---

## 🔔 Alert System

### **Low Stock Notifications**
- Customizable threshold (1-5 spools)
- Out of stock category
- Low stock category
- Badge counter display
- Quick restock functionality

---

## 🎯 Future Enhancements (Phase 3)

### **Planned Features**
- 🔍 Barcode/QR code scanning
- 📊 Print usage tracking
- 💱 Real-time currency conversion
- ☁️ Optional cloud backup (Firebase)
- 📈 Monthly expense reports
- 📅 Usage timeline and history
- 🔗 Google Sheets OAuth integration
- 🌍 Multi-language support
- 🎨 Custom themes and dark mode

---

## 🤝 Contributing

This is a private project. For feature requests or bug reports, please contact the project owner.

---

## 📄 License

Private - All Rights Reserved

---

## 👤 Author

**FilaManager AI Team**

---

## 📞 Support

For issues or questions:
1. Check the MOBILE_OPTIMIZATION.md guide
2. Review GEMINI_API_INTEGRATION.md for AI setup
3. Contact project maintainer

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design guidelines
- Hive for efficient local storage
- Community for feedback and support

---

<div align="center">

**Built with ❤️ using Flutter**

</div>
