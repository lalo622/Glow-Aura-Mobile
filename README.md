# Glow Aura — Skincare & Cosmetics E-commerce Mobile App

Glow Aura is a Flutter-based mobile application that provides AI-powered skin analysis, personalized skincare recommendations, cosmetic product shopping, and order management in a single platform.

---

## Project Overview

Glow Aura consists of two main components:

- **Flutter Mobile Application** (this repository) — Customer-facing application
- **ASP.NET Core Web API** — Backend services

---

## Architecture

Feature-first + MVVM

```text
UI
│
▼
ViewModel (Riverpod StateNotifier)
│
▼
Service Layer (Dio)
│
▼
Backend API (ASP.NET Core)
```

---

## Tech Stack

| Group | Technology |
|--------|------------|
| Core | Flutter (Dart) |
| State Management | Riverpod (`StateNotifierProvider`) |
| Networking | Dio (singleton `ApiClient.instance.dio`), automatic token refresh on 401 |
| Routing | GoRouter |
| Local Storage | Drift (SQLite) — cart and session cache |
| Error Handling | `safeCall` / `SafeResult<T>` / `AppException` |
| Camera / ML | Google ML Kit Face Detection, custom blur detection |
| Secure Storage | `flutter_secure_storage` |
| Backend | ASP.NET Core Web API + MongoDB |

---

## Requirements

Before running the application, ensure you have the following installed:

- Flutter SDK 3.x or later (stable channel)
- Dart SDK 3.x or later
- Android Studio or Xcode (for an emulator or physical device)

> **Note:** For the best experience, especially when testing the AI skin analysis and camera features, running the application on a physical device is recommended.
---

## Major Packages

| Package | Purpose |
|---------|---------|
| `dio` | HTTP client |
| `flutter_riverpod` | State management |
| `go_router` | Navigation |
| `google_mlkit_face_detection` | Face detection |
| `camera` | Camera access |
| `drift` | Local SQLite database |
| `flutter_secure_storage` | Secure storage |
| `image` | Image processing |

---

## Installation

Clone the repository and install the required dependencies.

```bash
git clone https://github.com/lalo622/Glow-Aura-Mobile.git
cd Glow-Aura-Mobile
flutter pub get
```

If you encounter dependency or version issues:

```bash
flutter clean
flutter pub get
```

---

## Running the App

```bash
flutter run
```

---

## Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## Project Structure

```text
lib/
├── core/          # Networking, error handling, theme, router
├── features/      # Feature modules (auth, camera, cart, checkout, profile, ...)
├── shared/        # Reusable widgets
└── main.dart      # Application entry point
```

---

## Key Features

### Authentication

- Login and registration with JWT authentication
- Automatic access token refresh

### AI Skin Analysis

- Real-time face detection using Google ML Kit
- Automatic image quality assessment
- Burst capture to select the sharpest image
- AI-powered skin analysis via an external YOLO inference service

### Product Catalog

- Browse and search skincare products

### Cart

- Local-first shopping cart using Drift (SQLite)

### Checkout

- Real-time order preview
- Order placement
- Payment Methods
  - Cash on Delivery (Available)
  - PayOS (Available)

### Profile

- User information
- Order history
- Application settings

---

## Representative API Endpoints

| Feature | Endpoint |
|---------|----------|
| Login | `POST /api/Auth/login` |
| Register | `POST /api/Auth/register` |
| Products | `GET /api/Product` |
| Checkout Preview | `POST /api/Checkout/preview` |
| Checkout | `POST /api/Checkout` |

---

## Authors

- **Trần Gia Tiến** 
