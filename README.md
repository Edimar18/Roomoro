md
# Roomoro

ROOMORO is a Flutter mobile app, powered by Firebase and flutter_map, to solve housing accessibility in Cagayan de Oro City. It's a centralized platform connecting tenants with affordable boarding houses and pads, featuring detailed listings, integrated maps, and a two-way rating system for verified landlords and tenants.

## Key Features & Benefits

*   **Centralized Housing Platform:** Aggregates boarding house and pad listings in Cagayan de Oro City.
*   **Detailed Listings:** Provides comprehensive information about each listing, including photos, amenities, and pricing.
*   **Integrated Maps:** Uses `flutter_map` to display listings on a map, enabling location-based searching.
*   **Two-Way Rating System:** Allows both tenants and landlords to rate each other, fostering trust and accountability.
*   **Firebase Integration:** Leverages Firebase for authentication, database management, and storage.
*   **Affordable Housing Focus:** Prioritizes affordable housing options to improve accessibility for students and young professionals.

## Prerequisites & Dependencies

Before you begin, ensure you have the following installed:

*   **Flutter SDK:** [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
*   **Dart SDK:** Included with Flutter SDK.
*   **Android Studio/Xcode:** For building and running the app on emulators/simulators.
*   **Firebase Account:** A Firebase project with the necessary services enabled (Authentication, Firestore, Storage).
*   **Firebase CLI:** For managing Firebase projects from the command line.
*   **Kotlin:** Ensure Kotlin is set up in your Android Studio environment.
*   **Swift:** Ensure Swift is set up in your Xcode environment.

The following Dart packages are used in this project:

*   `flutter_map`
*   `firebase_core`
*   `firebase_auth`
*   `cloud_firestore`
*   `firebase_storage`

## Installation & Setup Instructions

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/Edimar18/Roomoro.git
    cd Roomoro
    ```

2.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Configure Firebase:**

    *   Create a Firebase project at [https://console.firebase.google.com/](https://console.firebase.google.com/).
    *   Enable Authentication, Firestore, and Storage in your Firebase project.
    *   Download the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) files from your Firebase project settings.
    *   Place the `google-services.json` file in the `android/app/` directory.
    *   Place the `GoogleService-Info.plist` file in the `ios/Runner/` directory.

4.  **Initialize Firebase in your Flutter app:**

    ```dart
    import 'package:firebase_core/firebase_core.dart';
    import 'firebase_options.dart'; // Create this file based on your Firebase project

    void main() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      runApp(MyApp());
    }
    ```

    *   You'll need to create a `firebase_options.dart` file based on your Firebase project configuration.  FlutterFire CLI can help with this: [https://firebase.google.com/docs/flutter/setup](https://firebase.google.com/docs/flutter/setup)

5.  **Run the app:**

    ```bash
    flutter run
    ```

    Choose your desired device (emulator/simulator or physical device).

## Usage Examples & API Documentation (if applicable)

(Detailed usage examples and API documentation will be added in future updates.)

For now, refer to the Flutter documentation ([https://flutter.dev/docs](https://flutter.dev/docs)) and the individual package documentation for `flutter_map`, `firebase_auth`, `cloud_firestore`, and `firebase_storage` for specific usage instructions.

## Configuration Options

*   **Firebase Configuration:**  The Firebase configuration is managed through the `google-services.json` and `GoogleService-Info.plist` files and the `firebase_options.dart` file. Make sure these are correctly configured for your Firebase project.

*   **Map Configuration:**  The initial map location and zoom level can be configured within the `flutter_map` widget.

## Contributing Guidelines

We welcome contributions to Roomoro!  Here are some guidelines to follow:

1.  **Fork the repository.**
2.  **Create a new branch for your feature or bug fix.**
3.  **Write clear and concise commit messages.**
4.  **Submit a pull request with a detailed description of your changes.**

Please adhere to the project's coding style and conventions.

## License Information

License not specified.  All rights reserved. Please contact the owner (Edimar18) for license inquiries.

## Acknowledgments

*   Flutter Team
*   Firebase Team
*   `flutter_map` contributors
*   Open-source community