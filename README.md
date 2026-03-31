<p align="center">
  <img src="assets/images/black_car.png" width="300" alt="DriveEasy Logo">
</p>

# 🏎️ DriveEasy — Premium Car Rental Solution

[![Flutter Version](https://img.shields.io/badge/Flutter-3.10.4+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Powered-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen.svg)](http://makeapullrequest.com)

**DriveEasy** is a high-performance, feature-rich car rental mobile application built with **Flutter** and **Firebase**. It provides a seamless experience for both luxury car seekers and fleet administrators.

---

## 🌟 Key Features

### 👤 Customer Experience
*   **Smart Auth**: Email, Google, and Phone OTP authentication with secure session management.
*   **Luxury Fleet**: Browse, filter, and search through a curated list of premium vehicles.
*   **Booking Engine**: Real-time availability checks, price calculations, and multi-day booking logic.
*   **Payment & Confirmation**: Support for UPI, Cards, and Cash with instant digital receipts.
*   **Personalization**: Add cars to favorites, manage profile, and track booking history.
*   **AI Support**: Integrated Gemini-powered AI assistant for car recommendations and support.

### 🛡️ Admin Suite
*   **Live Dashboard**: Real-time stats on bookings, revenue, and fleet status.
*   **Fleet Management**: Seamlessly add, edit, or remove vehicles with high-res image uploads.
*   **Booking Management**: Approve, cancel, or update booking statuses in real-time.
*   **Role-Based Access**: Secure Admin-only routes and Firestore-level security rules.

---

## 📸 Screenshots

| Splash & Onboarding | Home & Discovery | Car Details |
| :---: | :---: | :---: |
| <img src="https://via.placeholder.com/200x400?text=Splash+Screen" width="200"> | <img src="https://via.placeholder.com/200x400?text=Home+Screen" width="200"> | <img src="https://via.placeholder.com/200x400?text=Car+Details" width="200"> |

| Booking Flow | Admin Dashboard | User Profile |
| :---: | :---: | :---: |
| <img src="https://via.placeholder.com/200x400?text=Booking" width="200"> | <img src="https://via.placeholder.com/200x400?text=Admin" width="200"> | <img src="https://via.placeholder.com/200x400?text=Profile" width="200"> |

---

## 🛠️ Tech Stack

| Technology | Usage |
| :--- | :--- |
| **Flutter** | Frontend Framework |
| **Riverpod** | State Management |
| **Firebase Auth** | User Authentication |
| **Firestore** | Real-time Database |
| **Firebase Storage** | Image & Asset Hosting |
| **GoRouter** | Declarative Navigation |
| **Google Gemini** | AI Integration |
| **Shared Prefs** | Local Persistence |

---

## 🏗️ Architecture

The project follows **Clean Architecture** patterns for scalability and maintainability:

```text
lib/
├── app/          # App-wide config, routing, and theme
├── core/         # Reusable widgets, constants, and utilities
├── data/         # Repositories, datasources, and models
├── presentation/ # UI screens, widgets, and Riverpod providers
```

---

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK `^3.10.4`
*   Firebase Project & CLI
*   Dart `^3.0.0`

### Installation

1.  **Clone the Repo**:
    ```bash
    git clone https://github.com/kenil-gopani/DriveEasy.git
    cd my_app
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration**:
    ```bash
    flutterfire configure
    ```

4.  **Environment Setup**:
    *   Create a `.env` file based on `.env.example`.
    *   Add your Gemini API Key if using AI features.

5.  **Run the Project**:
    ```bash
    flutter run
    ```

---

## ⚖️ License & Author

Distributed under the **MIT License**. Created with ❤️ by the **DriveEasy Team**.

> [!NOTE]
> This project was developed as part of a high-end mobile application development assignment to showcase Flutter's versatility.

---
<p align="center">
  <b>Built for Performance. Designed for Luxury.</b>
</p>
