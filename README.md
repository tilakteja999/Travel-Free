# 🧳 Travel Time — Flutter Travel & Booking Application

A 100% client-side, feature-complete **Flutter Application** designed with a unique **Retro Travel Aesthetic**. Offers destination discovery, interactive transport seat selection (Trains, Buses, Flights, Cabs, Autos), hotel room selection, local inventory availability management, dynamic pricing, and local data persistence.

---

## 🌟 Key Features

### 1. 📍 Destination Discovery & Search
- Real-time destination autocomplete & location search history.
- Automatic GPS location detection (`geolocator`) with reverse geocoding fallback (`OpenStreetMap Nominatim` & IP lookup).
- Tourist attraction guides with operating hours, ticket pricing, and guide booking sheets.

### 2. 🚆 Multi-Mode Transport & Interactive Seat Booking
- **Train Berth Booking**: Interactive 3AC/2AC/Sleeper coach berth map (Lower, Middle, Upper, Side Lower, Side Upper).
- **Bus Seat Booking**: 2+2 & 2+1 layout seat picker with aisle visualization and status tallying.
- **Flight Seat Map**: Fuselage seat layout (Window, Aisle, Middle) with small-town airport connectivity alerts.
- **Cabs & Local Autos**: On-demand city shuttle options.

### 3. 🏨 Hotel Lodging & Room Selection
- Hotel room categories (Standard, Deluxe, Executive Suite).
- Interactive room number selection grid with occupied/available status.
- Date range check-in and check-out picker (`HotelDateRangePicker`) with automatic night/day calculations.

### 4. 🏷️ Dynamic Pricing & Cost Breakdown
- Dynamic fare calculation: `Base Rate × Selected Count / Nights + GST (5-12%) + Fees - Discounts`.
- Itemized price breakdowns across seat selection, guest details, checkout payment, success e-tickets, and booking detail history.

### 5. 🔒 Local Availability & Persistence (`SharedPreferences`)
- Persistent seat and room locking upon booking completion.
- Re-releasing of seats and rooms upon booking cancellation.
- Account-bound booking history (Upcoming, Past, Cancelled) with e-ticket QR codes and PDF download simulations.

### 6. 🎛️ Reusable Filter & Sorting Workflow
- Modal bottom sheet with draft filter state and explicit **Apply Filters** button.
- Range sliders, star rating chips, AC/Sleeper toggles, amenities chips, and active count badges.
- Results header with active removable filter chips and "Clear all" recovery.

---

## 🛠️ Architecture & Tech Stack

- **Framework**: Flutter 3.x / Dart 3.x
- **Platforms**: Web, Android, Windows
- **State & Data Flow**: Clean Repository Pattern (`UI` → `Provider/Controller` → `Repository` → `SharedPreferences`)
- **Graphics**: Custom Vector Canvas Painters (`RetroVanPainter`, `TransportScenicPainter`)
- **Key Dependencies**:
  - `shared_preferences` — Local data persistence
  - `crypto` — SHA-256 password hashing & auth security
  - `geolocator` & `geocoding` — GPS location services
  - `intl` — Date & currency formatting

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.19 or higher)
- Android Studio / VS Code / IntelliJ IDEA
- Chrome / Edge (for Web build) or Android Emulator

### Installation & Run
```bash
# 1. Clone the repository
git clone https://github.com/tilakteja999/Travel.git
cd Travel

# 2. Install dependencies
flutter pub get

# 3. Run the application
flutter run
```

### Run Tests
```bash
flutter test
```

---

## 🔒 Demo Credentials
Out-of-the-box demo accounts for quick testing:
- **Email**: `user@travel.com` | **Password**: `Travel123!`
- **Mobile**: `9876543210` | **Password**: `Travel123!`
