# Changelog

All notable changes to the XPay Payment SDK are listed here. From 3.1118.2 the version has the form `3.<MMDD>.<N>`: `MMDD` is the release month and day (1118 is 18 November) and `N` counts the releases of that day. Versions before that (3.11.x) matched the XPay Merchant app. The number does not follow Semantic Versioning: read this file to find out whether a release changes the public API.

Entries marked **Breaking** need a change in your app.

## 3.1128.1

Moves the handling of an unsuccessful payment into the SDK, following the new XPay failure flow, and replaces the result type. **Breaking**: every app must change how it reads the result. See [docs/failure_handling.vi.md](docs/failure_handling.vi.md) (Vietnamese) for the flows, the screens and what your app and backend do with each result.

### Added

1. The SDK checks the ride with `GET /merchant/ride-payment` every time it opens. A ride that is already paid opens on a "payment successful" screen and returns `paid`; a ride that is closed or cancelled opens on a "ride closed" screen and returns `rideClosed`. Nothing is charged again.
2. The SDK handles an unsuccessful payment on its own screens:
   1. It retries on its own after a timeout, a lost connection, an HTTP 5xx, `429` or `request_in_flight` (up to 3 times, only for requests that cannot charge twice), and renews an expired session through `fetchSession`.
   2. A failure popup shows the reason, the ride reference and the XPay support number, which the driver taps to call (copied when the phone cannot call). "Retry" returns to the method list; after 3 failures in a row the driver is asked to call XPay support.
   3. After the driver confirms the call, a next-step screen offers "retry with XPay", "pay another way" and "XPay support pays"; the last one opens a "waiting for XPay support" screen that checks the ride for up to 5 minutes.
3. `fetchSession`, the second argument of `XPayPaymentRequest.fromSession` (`Future<String> Function()?`), and a field of `XPayCheckout` on Android (`(suspend () -> String)?`) and iOS (`(@MainActor () async throws -> String)?`). The SDK calls it when XPay answers `ride_payment_session_expired`, and sends the rejected request again on the new session. A new session with another fare ends with `retryInPartner`.
4. `XPayPaymentResult.isRetryable` (`bool`, `Boolean` on Android, `Bool` on iOS): `true` for `retryInPartner` and `cancelled`, when your app may open XPay again right away.
5. `XPayPayment.supportHotline` (`XPayPayment.SUPPORT_HOTLINE` on Android): the XPay support number, `19002189`.
6. New dependency `url_launcher` `^6.3.1`, used to call XPay support. The Android AAR has one more POM (`url_launcher_android`), the iOS package one more framework (`url_launcher_ios`). The SDK's Android manifest declares a `<queries>` entry for `tel:`.

### Breaking

1. `XPayPaymentStatus` is now `paid`, `retryInPartner`, `otherMethod`, `csPending`, `rideClosed`, `cancelled` and `unavailable` (`PAID`, `RETRY_IN_PARTNER`, … on Android). The old values are removed:
   1. `approved`, `captured` → `paid`, with `paidBy` `partner`, or `cs` when XPay support paid.
   2. `declined`, `failed`, `duplicate`, `expired` → handled on the SDK screens. The payment then ends with `retryInPartner`, `otherMethod`, `csPending`, `paid` or `rideClosed`.
   3. `unsupported`, and `failed` with `sdk_not_initialized`, `sdk_busy` or `sdk_invalid_request` → `unavailable` with that `errorCode`. `unsupported` becomes `errorCode` `sdk_unsupported`.
2. `XPayPaymentResult` loses `failureCategory`, `message`, `declineCode` and `bookingRef`, and gains `failure` (`XPayPaymentFailure`: `reason`, `authId`, `errorCode`, `note`), `pendingAuthId`, `paidBy` (`XPayPaidBy`) and `rideStatus` (`XPayRideStatus`). `errorCode` is set only on `unavailable`; the raw code of a failed payment is in `failure.errorCode`.
3. `XPayFailureCategory` is removed, and `docs/failure_categories.vi.md` is replaced by `docs/failure_handling.vi.md`.
4. Your app no longer shows its own "payment failed" or "call XPay support" popups: the SDK shows them. Your backend reports `POST /merchant/rides/{order_id}/payment-failure`, with `reason`, `auth_id` and `note` taken from `failure`, whenever the driver stays on your payment screen without paying through XPay. For cash it reports `paid_cash` before the driver takes the cash.
5. A card payment left waiting for its OTP/PIN is returned in `pendingAuthId`, not in `authId`. Void it from your backend before collecting another way.
6. A session that expires mid-payment no longer ends with `failed` and `token_expired`, nor with `expired` on a wallet QR: the SDK calls `fetchSession`, or shows the failure popup and returns `retryInPartner`.
7. `XPayConfig.language` now applies to the SDK screens only, since the result no longer has a `message`.

## 3.1126.1

Adds a failure category to every unsuccessful result. No public type, field or method is renamed or removed.

### Added

1. `XPayPaymentResult.failureCategory` (`XPayFailureCategory?`) groups every `declined`, `failed` and `duplicate` result: `system`, `network`, `cardholderRetry`, `cardholderChange`,
   `corporatePolicy`, `session` and `unknown` (`SYSTEM`, `NETWORK`, … on Android). It is `null` for the other statuses. See "Failure category" in the README, and
   `docs/failure_categories.vi.md` for the codes in each category and how to handle them.
2. On iOS, `XPayFailureCategory` is a non-frozen enum: add an `@unknown default` branch when you switch over it.

### Changed

1. `declined` with `declineCode` `velocity_limit_exceeded` now says the card is locked and asks for another card or payment method, instead of asking to try again in 5 minutes.

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
