# Changelog

All notable changes to the XPay Payment SDK are listed here. From 3.1118.2 the version has the form `3.<MMDD>.<N>`: `MMDD` is the release month and day (1118 is 18 November) and `N` counts the releases of that day. Versions before that (3.11.x) matched the XPay Merchant app. The number does not follow Semantic Versioning: read this file to find out whether a release changes the public API.

Entries marked **Breaking** need a change in your app.

## 3.1119.1

Adds the native iOS API. The Android API is unchanged.

### Added

1. iOS native API (`XPayPayment.initialize(config:)`, `XPayPayment.start(from:checkout:)`, `XPayCheckout`) for hosts without Flutter, added in Xcode by the URL of this repository (Swift Package Manager, product `XPayPayment`), or as the local Swift package in `xpay-payment-sdk-ios-<version>.zip`. Integration guide: [docs/ios_integration.vi.md](docs/ios_integration.vi.md) (Vietnamese).
2. iOS only: the method list shows a back button in the top left corner. It cancels the payment, like the Android system back button on that screen. Before, an iOS cashier could not leave the method list.

### Changed

1. `app_settings` is pinned to `7.0.0` (was `^8.0.3`). Version 8 dropped CocoaPods, which the native iOS build needs. The Dart API used by the SDK is the same.

### Fixed

1. iOS: when the app closes the SDK screens while XPay is authorizing the card, `start` now waits for the authorization and returns its outcome, instead of `cancelled` without an `authId` while the card may already be charged. A payment that then needs verification ends as `cancelled` with its `authId`.
2. iOS: when the app closes the SDK screens during verification, the `cancelled` result now keeps the `authId`.

## 3.1118.2

Rebuilt with Kotlin 2.2.20 so that apps on Kotlin 2.1 or 2.2 can use the Android AAR. The SDK code is the same as 3.11.16. Use this version instead of 3.11.18.

### Changed

1. The AAR and its plugins are compiled with Kotlin 2.2.20 (metadata version 2.2.0) and depend on `kotlin-stdlib` 2.2.20. Version 3.11.18 was built with Kotlin 2.3.20 and cannot be read by a Kotlin 2.1 compiler.
2. The Android library of the SDK (`android/build.gradle.kts`) pins the Kotlin Gradle plugin to 2.2.20.

## 3.11.18

Documentation release. The SDK code is the same as 3.11.16.

### Added

1. Android native integration guide: [docs/android_integration.vi.md](docs/android_integration.vi.md) (Vietnamese). It covers installing the AAR from the `maven` branch or the Release zip, manifest setup, the payment session, the API reference, error codes and troubleshooting.

### Changed

1. The README no longer lists iOS as a planned package, and points native Android partners to the new guide.

## 3.11.16

First release published on GitHub. Earlier builds were sent to partners as a zip file.

### Added

1. Payment flow driven by a ride payment session: `XPayPaymentRequest.fromSession(sessionJson)` takes the response of `POST /merchant/rides/{order_id}/payment-session` unedited.
2. A method list as the first SDK screen, built from the session's `entry_modes`: `ride_card`, `card_qr`, `manual_pan`, `chip_tap` (Android with NFC) and `token`.
3. OTP and PIN verification screens, including the recipient picker.
4. Android native API (`XPayPayment`, `XPayPaymentContract`, `XPayCheckout`) for hosts without Flutter, distributed as an AAR: `com.xperise.xpay.partner:flutter_release:3.11.16`.

### Changed

1. **Breaking:** the invoice buyer and service date were removed from the public API. `XPayPaymentRequest.fromSession` and `XPayCheckout` take only the session JSON.
