# BasicBilling Frontend

Flutter web application for the BasicBilling service payment system. Allows users to create bills, process payments, view pending bills, and review payment history.

## Functionality

### Create Bill
Form to create a new bill with the following fields:
- **Client ID** (required, numeric)
- **Service Type** (Water, Electricity, Sewer)
- **Period** (YYYYMM format with validation)
- **Amount** (must be greater than 0)

Validates that the client exists and that no duplicate bill exists for the same client, service, and period.

### Pay Bill
Form to process a payment for an existing bill:
- **Client ID** (required, numeric)
- **Service Type** (Water, Electricity, Sewer)
- **Period** (YYYYMM format with validation)

Validates that the client and an unpaid bill exist before processing.

### View Pending Bills
Displays all pending (unpaid) bills for a given client:
- Search by Client ID
- OData sorting by date or amount
- **Inline pay action** on each bill card for quick payments (optional feature implemented)

### View Payment History
Displays chronological payment history for a given client:
- Search by Client ID
- **Filter by service type** using OData `$filter` (optional feature implemented)
- **Sort by date or amount** using OData `$orderby` (optional feature implemented)

## Tech Stack

- **Framework:** Flutter 3.41 / Dart 3.11 (Web platform)
- **State Management:** BLoC (flutter_bloc)
- **Routing:** GoRouter
- **UI:** Material Design 3
- **API Communication:** HTTP package with JWT Authorization headers
- **Data Queries:** OData ($filter, $orderby, $top, $skip)
- **Testing:** flutter_test, bloc_test, mocktail

## Prerequisites

- Flutter SDK >= 3.11.1
- A running instance of BasicBilling.API on `http://localhost:5101`

## How to Build

```bash
# Get dependencies
flutter pub get

# Build for web (production)
flutter build web
```

The production build output will be in `build/web/`.

## How to Run

```bash
# Run in development mode (opens in default browser)
flutter run -d chrome

# Or specify a browser
flutter run -d edge
```

The app will be available at the URL shown in the terminal (typically `http://localhost:PORT`).

## How to Test

```bash
# Run all tests
flutter test

# Run tests with verbose output
flutter test --reporter expanded
```

## Project Structure

```
lib/
  core/
    constants/     # API URLs and app constants
    theme/         # Material Design 3 theme configuration
  models/          # Data models (Bill, Payment)
  services/        # API service layer (AuthService, BillingService)
  repositories/    # Repository pattern (BillingRepository)
  blocs/           # BLoC state management
    create_bill/   # Create bill feature (events, states, bloc)
    pay_bill/      # Pay bill feature
    pending_bills/ # Pending bills feature
    payment_history/ # Payment history feature
  screens/         # UI screens for each feature
  main.dart        # App entry point with routing
```

## Backend API

This frontend consumes the BasicBilling.API backend:

| Endpoint | Method | Description |
|---|---|---|
| `/api/auth/token` | POST | Get JWT token (no auth required) |
| `/api/bills` | POST | Create a new bill |
| `/api/payments` | POST | Process a payment |
| `/api/clients/{id}/pending-bills` | GET | Get pending bills (supports OData) |
| `/api/clients/{id}/payment-history` | GET | Get payment history (supports OData) |

## Unimplemented Features

All required and optional features from the practice specification have been implemented. No features were left unimplemented.
