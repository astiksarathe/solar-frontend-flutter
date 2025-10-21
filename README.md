# Solar Phoenix - Flutter App

A comprehensive Flutter application that provides solar analysis dashboard and EMI calculator functionality.

## Features

### 🏠 Home Dashboard
- **Electricity Bill Analysis**: Enter consumer number to fetch and analyze electricity bill data
- **Usage Visualization**: Interactive bar charts showing 6-month consumption history
- **Consumer Details**: Display customer information including name, address, and connection type
- **Solar Recommendations**: AI-powered recommendations for optimal solar system size
- **Savings Calculator**: Estimated monthly savings and payback period visualization
- **CTA Integration**: Call-to-action for solar quote generation

### 💰 EMI Calculator
- **Dual Calculation Modes**: 
  - Calculate EMI from loan amount, interest rate, and tenure
  - Calculate tenure from loan amount, interest rate, and target EMI
- **Prepayment Support**: Factor in prepayments with flexible timing options
- **Real-time Calculations**: Debounced input with automatic calculation updates
- **Detailed Results**: Shows EMI amount, total interest, and payment breakdown
- **Theme Support**: Light and dark mode compatibility

## Technical Stack

### Frontend
- **Framework**: Flutter 3.x
- **Language**: Dart
- **Charts**: fl_chart for data visualization
- **HTTP**: http package for API communication
- **UI Components**: Material Design 3

### Backend Integration
- **API Endpoint**: `https://solar-backend-455t.vercel.app`
- **Data Format**: JSON REST API
- **Error Handling**: Comprehensive error states and user feedback

## Project Structure

```
lib/
├── main.dart                 # App entry point and navigation
├── models/                   # Data models
│   ├── bill_models.dart      # Bill analysis data structures
│   └── emi_models.dart       # EMI calculation models
├── screens/                  # UI screens
│   ├── home_screen.dart      # Solar dashboard
│   └── emi_calculator_screen.dart # EMI calculator
├── services/                 # Business logic
│   ├── bill_api_service.dart # API communication
│   └── emi_calculator_service.dart # EMI calculations
└── theme/                    # App theming
    └── app_theme.dart        # Colors and theme configuration
```

## Getting Started

### Prerequisites
- Flutter SDK 3.x
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd solar_phoenix
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Testing

Run the test suite:
```bash
flutter test
```

## API Integration

The app integrates with a solar analysis backend:

### Endpoint
```
GET /electricity-bill/analyze/{consumerNumber}
```

### Response Format
```json
{
  "success": true,
  "data": {
    "consumerDetails": { ... },
    "billAnalysis": { ... },
    "solarRecommendation": { ... }
  }
}
```

## Calculations

### EMI Formula
```
EMI = P × r × (1 + r)^n / ((1 + r)^n - 1)
```
Where:
- P = Principal loan amount
- r = Monthly interest rate
- n = Number of months

### Prepayment Impact
- **Reduce Tenure**: Maintains EMI, reduces loan duration
- **Reduce EMI**: Maintains tenure, lowers monthly payment

## License

This project is licensed under the MIT License.
