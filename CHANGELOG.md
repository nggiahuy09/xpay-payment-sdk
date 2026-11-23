# Changelog

All notable changes to the XPay Payment SDK are listed here. From 3.1118.2 the version has the form `3.<MMDD>.<N>`: `MMDD` is the release month and day (1118 is 18 November) and `N` counts the releases of that day. Versions before that (3.11.x) matched the XPay Merchant app. The number does not follow Semantic Versioning: read this file to find out whether a release changes the public API.

Entries marked **Breaking** need a change in your app.

## 3.1123.1

Adds payment from the rider's corporate wallet. No public type, field or method is renamed or removed, but a wallet payment succeeds without an `authId`: see **Breaking** below.

### Added

1. Corporate wallet payments. When the session response has `"payment_method": "corporate_wallet"` (a dispatch ride booked on the company's wallet), `start` lists the wallet methods instead of the card methods. The amount and trip summary stay the same.
   1. **Show QR code:** the SDK creates a QR for the locked amount, the rider scans it with the XPERISE app and pays from the company wallet. The SDK checks the payment every 3 seconds and returns as soon as it is paid.
   2. **Send code by SMS** and **Send code by email:** one row per rider and channel that XPay has on file, the booker first. The SDK sends a 6-digit code, the cashier types the code the rider reads out, and the SDK verifies it. The code screen can resend the code (40 seconds after the last send) and switch to another phone number or email.
2. Sessions without `payment_method`, or with `"payment_method": "card"`, keep the card flow.

### Changed

1. A `corporate_wallet` session with empty `entry_modes` is accepted. Before, `start` returned `failed` with `sdk_invalid_request`.
2. New dependency `pretty_qr_code` `^3.6.0`, used to draw the QR code.

### Breaking

1. A successful wallet payment is `captured` with `externalRef`, `amount` and `currency`, plus `createdAt` when it was paid at the QR. `authId` and `captureId` are `null`, because no card payment is made. If your app or backend confirms payments only by `authId`, confirm wallet payments by `externalRef`.

### Results of a wallet payment

1. `declined`: XPay declined the payment made at the QR.
2. `expired` without `authId`: the QR expired, or the payment session expired while the SDK was waiting for the QR to be paid.
3. `failed`: the ride amount changed (`amount_locked`), the ride is closed (`ride_not_found`), the ride is not on the corporate wallet (`ride_not_on_corporate_wallet`), XPay refused the payment session (`token_expired`, `ride_payment_session_revoked`), or XPay refused to report the QR payment. `errorCode` keeps the raw code.
4. `cancelled`: the cashier left before the rider paid. Leaving the QR screen first cancels the QR with XPay. If XPay cannot confirm the cancellation, the SDK stays on the QR screen and says so, because the rider could still pay it.
5. While the wallet code is being verified, the back button is disabled. A native app that closes the SDK screens at that moment gets the verification result instead of `cancelled`. Closing them while the QR is shown cancels the QR first.

## 3.1120.1

Aligns the payment error messages with the XPay Merchant app. The public API is unchanged.

### Changed

1. `declined` results now carry a specific `message` for more `declineCode` values: `card_outside_validity_window`, `card_link_inactive`, `employee_policy_violation`, `employee_policy_unavailable`, `chip_cryptogram_invalid`, `chip_nonce_replayed`, `chip_counter_replay`, `chip_credential_revoked`, `chip_credential_not_active`, `service_payment_auth_failed`, `service_payment_invalid_request`, `service_payment_in_flight`, `service_payment_failed`, `service_payment_declined` and `service_payment_unavailable`. Before, these codes fell back to the generic decline copy with an error code line.
2. `failed` results from the authorization step now carry a specific `message` for `not_found` (worded for the method the cashier used), `no_registered_phone`, `static_code_unavailable`, `otp_delivery_failed`, `ride_card_not_found` and `ride_already_paid`. `errorCode` keeps the raw code. See the error code table in the README.

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
