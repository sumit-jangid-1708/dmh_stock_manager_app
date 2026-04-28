# DMJ Stock Manager

A comprehensive Flutter application for managing inventory, purchases, and orders. This project provides a robust solution for tracking stock levels, managing vendors, and handling billing with features like barcode scanning and PDF generation.

## 🚀 Features

- **Inventory Management**: Track products and stock levels efficiently.
- **Purchase Tracking**: Manage purchase bills, vendors, and payment statuses (Paid/Unpaid).
- **Order Management**: Handle customer orders with status logging and tracking.
- **Barcode & QR Integration**: Scan and generate barcodes/QR codes for SKUs and products.
- **Reporting**: Export data to Excel and generate PDF reports/bills for printing.
- **User Authentication**: Secure login with OTP/Pinput support.
- **Modern UI**: Built with GetX for state management and a clean, responsive design.

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [GetX](https://pub.dev/packages/get)
- **HTTP Client**: [http](https://pub.dev/packages/http)
- **Local Storage**: [Get Storage](https://pub.dev/packages/get_storage)
- **Scanning**: [Mobile Scanner](https://pub.dev/packages/mobile_scanner)
- **PDF & Printing**: [pdf](https://pub.dev/packages/pdf) & [printing](https://pub.dev/packages/printing)
- **Exports**: [Syncfusion Flutter Xlsio](https://pub.dev/packages/syncfusion_flutter_xlsio)

## 📦 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Dart SDK

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   ```

2. **Navigate to the project directory**
   ```bash
   cd dmh_app_second
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── data/           # API exceptions and network services
├── model/          # Data models (Order, Product, Purchase, Vendor)
├── res/            # Resources (Components, Colors, Constants)
├── utils/          # Utility classes and helpers
├── view/           # UI Screens
└── view_models/    # GetX Controllers and business logic
```

## 📄 License

This project is private and intended for internal use.
