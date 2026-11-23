# XPay Payment SDK for Flutter

Collect a payment with an XPay card from your own Flutter app. The SDK owns the card part of the checkout: it shows the amount and the trip, lets the cashier pick how the card is presented, reads the card (NFC tap, QR scan, one-time code, manual entry, or the customer's linked card), authorizes the payment with XPay, runs the OTP or PIN verification when XPay asks for one, and hands your app a single result. For a ride booked on the rider's corporate wallet, it collects from the wallet instead, by a QR code the rider scans in the XPERISE app or by a code sent to the rider's phone or email.

Your app keeps everything around it: the order, the payment session, and what happens after the result.

> **Status: preview for integration and demos.** The SDK is available for Flutter apps (this document) for native Android (Kotlin) apps as an AAR, and for native iOS (Swift) apps as a Swift package: see the [Android native integration guide](docs/android_integration.vi.md) and the [iOS native integration guide](docs/ios_integration.vi.md) (Vietnamese).

## Contents

1. [What the SDK does](#what-the-sdk-does)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Host app setup](#host-app-setup)
5. [Authentication](#authentication)
6. [Initialize](#initialize)
7. [Take a payment](#take-a-payment)
8. [Request reference](#request-reference)
9. [Result reference](#result-reference)
10. [Retries and duplicate payments](#retries-and-duplicate-payments)
11. [Confirming a payment on your backend](#confirming-a-payment-on-your-backend)
12. [Logging](#logging)
13. [Example app](#example-app)
14. [Limitations](#limitations)

## What the SDK does

| The SDK owns                                                   | Your app owns                                                     |
| -------------------------------------------------------------- | ----------------------------------------------------------------- |
| The summary and method screen, then the card capture screens   | The order and its payment session                                 |
| Authorizing the payment with XPay                              |                                                                   |
| OTP / PIN verification screens, including the recipient picker | Offering "XPay card" among your own payment methods               |
| Returning one result per payment                               | Success and failure screens, navigation, refreshing your own data |

The first SDK screen shows the amount, the trip (ride ref, pickup, destination, plate number) and the methods the session's `entry_modes` allow, in that order. The cashier picks one:

| `entry_modes` value | What the cashier does                                                          | Android | iOS |
| ------------------- | ------------------------------------------------------------------------------ | ------- | --- |
| `ride_card`         | Charges the card the ride was booked on, shown by name and last four digits    | Yes     | Yes |
| `card_qr`           | Scans the QR printed on the customer's XPay card, or picks it from the gallery | Yes     | Yes |
| `manual_pan`        | Types the card number                                                          | Yes     | Yes |
| `chip_tap`          | Taps the customer's XPay chip card on the phone                                | Yes     | No  |
| `token`             | Scans the one-time payment code in the customer's XPERISE app                  | Yes     | Yes |

Only the methods the device can run are listed. A `card_qr` choice accepts only card QR codes and a `token` choice only one-time codes. Backing out of a capture screen returns to the method list; backing out of the method list cancels the payment.

NFC is Android-only: XPay chip cards are MIFARE Classic, and iOS gives apps no access to MIFARE Classic cards.

### Corporate wallet rides

When the session's `payment_method` is `corporate_wallet`, the ride is paid from the rider's company wallet, and the same first screen lists these methods instead:

| Method                                | What happens                                                                                                                                      | Android | iOS |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | --- |
| Show QR code                          | The SDK shows a QR for the locked amount. The rider scans it with the XPERISE app and pays. The SDK checks every 3 seconds and returns once paid. | Yes     | Yes |
| Send code by SMS / Send code by email | One row per rider and channel XPay has on file, the booker first. The SDK sends a 6-digit code; the cashier types the code the rider reads out.   | Yes     | Yes |

1. Show QR code is always listed. The code rows come from XPay: a rider without a phone number gets no SMS row, without an email no email row. With no rider on file, only the QR is listed.
2. On the code screen the cashier can resend the code, 40 seconds after the last send, and switch to another rider's phone number or email with **Change**.
3. Backing out of the QR screen first cancels the QR with XPay. If XPay cannot confirm it, the SDK stays on the QR screen and says so, because the rider could still pay it; back out again to retry.
4. A wrong code, an expired code or too many attempts are reported on the code screen and do not end the payment. Ask for a new code and continue.

## Requirements

| Item    | Minimum               |
| ------- | --------------------- |
| Flutter | 3.44 (Dart `^3.12.2`) |
| Android | minSdk 24, Java 17    |
| iOS     | 15.0                  |

## Installation

The SDK is not published to pub.dev. Add it as a Git dependency and pin a release tag:

```yaml
dependencies:
  xpay_payment_sdk:
    git:
      url: https://github.com/nggiahuy09/xpay-payment-sdk.git
      ref: v3.1123.1
```

To update, change `ref` to a newer tag and run `flutter pub get`. Read [CHANGELOG.md](CHANGELOG.md) first: the version number does not follow Semantic Versioning, so the changelog is where breaking changes are listed.

Import only the public library:

```dart
import 'package:xpay_payment_sdk/xpay_payment_sdk.dart';
```

Everything under `package:xpay_payment_sdk/src/` is internal and may change without notice.

## Host app setup

### Android

Add to `android/app/src/main/AndroidManifest.xml`, inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.NFC"/>
<uses-feature android:name="android.hardware.camera" android:required="false"/>
<uses-feature android:name="android.hardware.nfc" android:required="false"/>
```

`required="false"` keeps your app installable on phones without NFC or a camera. On phones without NFC the SDK leaves `chip_tap` out of the method list.

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is needed to scan XPay QR codes for payments.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access is needed to scan XPay QR codes from your images.</string>
```

No NFC entitlement is needed, because the SDK never uses NFC on iOS.

## Authentication

Each payment is authorized by a **ride payment session** that **your backend** opens with XPay. The SDK never sees a merchant key or any other long-lived secret.

1. The cashier enters the fare of the ride in your app. Your app sends the `order_id` and the fare to your backend.
2. Your backend calls `POST /merchant/rides/{order_id}/payment-session` with its `X-Merchant-Key`, which stays on the server, and a JSON body: `amount` (string, `fare` + `sub_fee`, in VND), `fare` (number), optional `sub_fee` (number, default 0) and `distance_km` (number).
3. XPay answers a `session_token` for that one ride, with the `amount` it locked, the ride's `external_ref` (`XP-…`) and its trip data. The token is shown once and expires after 15 minutes.
4. Your backend hands the **whole** response body to your app, without picking fields out of it, and your app passes that string as `sessionJson` to `XPayPaymentRequest.fromSession`. The SDK reads `session_token`, `amount`, `external_ref`, `payment_method` and `payment_template` (`currency`, `product_type`) itself.

The SDK sends the token in the `X-Ride-Payment` header of every request of that payment. It keeps the token in memory only while the payment is open, and never stores or logs it.

The SDK does not refresh the token. When XPay rejects it, for example because the session expired, the payment ends with `failed` and an `errorCode` such as `token_expired`. Ask your backend for a new session and start the payment again. On a corporate wallet ride, a session that expires while the SDK waits for the QR to be paid ends the payment with `expired`.

**The amount is locked to the session.** The SDK collects exactly the `amount` of the session response. To collect another amount, open a new session; never edit the JSON before handing it to the SDK.

**Opening a new session for a ride revokes the earlier ones.** A request that carries a revoked session fails with `ride_payment_session_revoked` (HTTP 401). Open a session right before collecting, and never open another one for a ride while a payment of that ride is still open.

**The trip data comes from the session.** XPay attaches the session's pickup, destination, plate number, fare, sub-fee and distance to the payment. Your app does not pass them to the SDK.

**The reference comes from the session.** The SDK uses the response's `external_ref` (`XP-…`), so the result's `externalRef` is `XP-…` too.

**An unreadable session is never paid.** A string that is not a JSON object, has no `session_token`, whose `amount` is not whole đồng (for example `"138000.50"`), or, for a card session, whose `entry_modes` hold no method the SDK knows makes `start` return `failed` with `sdk_invalid_request`, and nothing is sent to XPay. The exact reason reaches `onLog` as an `error` event with `feature` `payment`, `action` `start_payment` and a `reason` among `invalid_session_json`, `malformed_session`, `missing_session_token`, `missing_entry_modes`, `invalid_amount`, `amount_below_minimum`, `missing_currency`, `invalid_external_ref`; its `input` carries only `session_json_length`, never the JSON or its token.

**Never put an XPay merchant key, API key or any other server credential in your app.**

## Initialize

Call `initialize` once before the first payment, for example at app start or after the cashier signs in. Call it again to change the language or the base URL.

1. Do not call it while a payment is open, that is before `start` returns. It then throws a `StateError` and keeps the previous configuration.
2. Do not call it before the previous call completes. The later call then throws a `StateError`, and the earlier one carries on.
3. While `initialize` runs, `start` returns `failed` with `errorCode` `sdk_not_initialized`. Always await `initialize` before calling `start`.

```dart
await XPayPayment.initialize(
  XPayConfig(
    environment: const XPayEnvironment(baseUrl: 'https://<xpay api host>'),
    language: XPayLanguage.vi,
    onLog: (event) => myLogger.log(event.toString()),
  ),
);
```

| Field         | Description                                                                                                      |
| ------------- | ---------------------------------------------------------------------------------------------------------------- |
| `environment` | The XPay API base URL for sandbox or production. XPay provides both.                                             |
| `language`    | `XPayLanguage.vi` (default) or `XPayLanguage.en`. Applies to the SDK screens and to `XPayPaymentResult.message`. |
| `onLog`       | Optional. See [Logging](#logging).                                                                               |

## Take a payment

```dart
Future<void> payWithXPay(BuildContext context, Order order) async {
  final sessionJson = await myBackend.openPaymentSession(order.id, fare: order.fare, subFee: order.subFee, distanceKm: order.distanceKm);
  if (context.mounted == false) return;

  final result = await XPayPayment.start(
    context,
    XPayPaymentRequest.fromSession(sessionJson),
  );

  switch (result.status) {
    case XPayPaymentStatus.approved:
    case XPayPaymentStatus.captured:
      await confirmOnBackend(order.id, externalRef: result.externalRef, authId: result.authId);
    case XPayPaymentStatus.declined:
    case XPayPaymentStatus.duplicate:
    case XPayPaymentStatus.failed:
      showMessage(result.message ?? 'The payment did not go through.');
    case XPayPaymentStatus.expired:
      showMessage('The verification window closed. Start a new payment.');
    case XPayPaymentStatus.cancelled:
    case XPayPaymentStatus.unsupported:
      break;
  }
}
```

`openPaymentSession` is your own function: it calls your backend, which calls `payment-session` with the body described in [Authentication](#authentication) and returns the response body as a string, untouched.

`start` opens the SDK screens on top of your app, on the root navigator. When the payment ends, it closes them and returns. It never touches your app's router.

When none of the session's methods can run on the device (for example a session that allows only `chip_tap`, on iOS), `start` returns `unsupported` without opening anything.

While XPay is authorizing the card or verifying a corporate wallet code, the back button is disabled, so the cashier cannot leave a payment that may already be charged.

## Request reference

`XPayPaymentRequest`, built with `XPayPaymentRequest.fromSession(...)`:

| Field         | Type     | Required | Notes                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| ------------- | -------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sessionJson` | `String` | Yes      | The whole body of `POST /merchant/rides/{order_id}/payment-session`. The SDK takes `session_token`, `amount` (whole đồng, at least 1,000), `external_ref` (1 to 64 characters), `payment_template.currency` (`VND` by default), `payment_template.product_type`, `payment_method` (`card` by default), `entry_modes`, `ride_card`, `order_id` and the trip in `payment_template.enhanced_data` from it. See [Authentication](#authentication). |

A request that breaks these rules is rejected before anything is sent: `start` returns `failed` with `errorCode` `sdk_invalid_request`.

The card number, chip data and verification code are never part of the request. The SDK collects them itself.

## Result reference

`start` always completes with exactly one `XPayPaymentResult`.

| Status        | Meaning                                                                      | Fields set                                                                                  |
| ------------- | ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| `approved`    | XPay approved the payment. It may be captured later.                         | `authId`, `externalRef`, `amount`, `currency`, `createdAt`; `bookingRef` after verification |
| `captured`    | XPay approved and captured the payment.                                      | As `approved`, plus `captureId`                                                             |
| `declined`    | XPay declined the payment.                                                   | `declineCode`, `message`; `authId` when known                                               |
| `cancelled`   | The cashier left before the payment finished.                                | `authId` when the payment was already authorized and left waiting for verification          |
| `duplicate`   | XPay already holds a different request under this payment's idempotency key. | `message`                                                                                   |
| `failed`      | The request failed, or XPay answered with something the SDK cannot act on.   | `errorCode`, `message`; `authId` when known                                                 |
| `expired`     | The verification window closed. Start a new payment.                         | `authId`                                                                                    |
| `unsupported` | None of the session's methods can run on this device.                        | none                                                                                        |

`result.isSuccessful` is true for `approved` and `captured`.

A corporate wallet payment ends differently, because no card payment is made:

| Status      | Meaning for a wallet payment                                                              | Fields set                                                                        |
| ----------- | ----------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| `captured`  | The rider paid from the company wallet, at the QR or with the code.                       | `externalRef`, `amount`, `currency`; `createdAt` when paid at the QR. No `authId` |
| `declined`  | XPay declined the payment made at the QR.                                                 | `message`                                                                         |
| `expired`   | The QR expired, or the payment session expired while the SDK was waiting for the QR.      | none                                                                              |
| `failed`    | The ride can no longer be paid from the wallet, XPay refused the payment session (`token_expired`, `ride_payment_session_revoked`), or XPay refused to report the QR payment. | `errorCode`, `message`                                                            |
| `cancelled` | The cashier left before the rider paid. A QR on screen is cancelled with XPay first.      | none                                                                              |

`message` is ready to show to the cashier, in the configured language. When XPay returned an error code with no copy of its own, the message ends with an `Error code:` line so support can trace it.

Error codes raised by the SDK itself, in `XPayErrorCode`:

| Code                      | Cause                                                           |
| ------------------------- | --------------------------------------------------------------- |
| `sdk_not_initialized`     | `start` was called before `initialize` completed.               |
| `sdk_invalid_request`     | The request failed validation. Nothing was sent.                |
| `sdk_busy`                | `start` was called while another payment was still open.        |
| `sdk_unexpected_response` | XPay answered with a status or chip data the SDK cannot act on. |

Other `errorCode` values come from XPay or from the network layer, for example `no_connection`, `timeout`, `token_expired`. `token_expired` means the payment session is no longer valid: open a new session and start again.

Codes tied to the payment session:

| Code                           | Cause                                                                                         | What to do                                                                          |
| ------------------------------ | --------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| `amount_locked`                | `amount` differs from the amount locked in the session (HTTP 422 on authorize, 409 on verify) | Pass the session response unedited, or open a new session for the amount to collect |
| `ride_payment_session_revoked` | Your backend opened a newer session for the same ride (HTTP 401)                              | Use the latest session; avoid opening several sessions for one ride                 |

The `message` of these codes is the generic copy followed by an `Error code:` line.

Codes from the authorization step that carry their own `message`, naming the cause instead of the generic copy:

| Code                      | Cause                                                                                                      | What to do                                    |
| ------------------------- | ---------------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| `not_found`               | XPay found no card or payment code for what was scanned, tapped or typed. `message` names the method used. | Check the card or code and try again          |
| `no_registered_phone`     | The card has no phone number to send the OTP to.                                                           | Use another card, or ask the corporate admin  |
| `static_code_unavailable` | The card has no PIN set up.                                                                                | Use another card, or ask the corporate admin  |
| `otp_delivery_failed`     | The OTP could not be sent to the cardholder's phone.                                                       | Try again                                     |
| `ride_card_not_found`     | The ride is no longer assigned to the driver, or can no longer be paid.                                    | Check the ride on your side                   |
| `ride_already_paid`       | The ride already has a payment.                                                                            | Check the ride status before collecting again |

Codes that end a corporate wallet payment with `failed`, each with its own `message`:

| Code                           | Cause                                                          | What to do                                    |
| ------------------------------ | -------------------------------------------------------------- | --------------------------------------------- |
| `amount_locked`                | XPay locked another fare for the ride after the code was sent. | Open a new session and start again            |
| `ride_not_found`               | The ride is closed or no longer open for payment.              | Check the ride status before collecting again |
| `ride_not_on_corporate_wallet` | The ride was not booked on the corporate wallet.               | Check the ride's payment method on your side  |

Other wallet errors (wrong, expired or locked code, too many codes requested, a code that could not be delivered, a rider with no contact on file, the wallet refusing or being unavailable) are shown on the SDK screen and do not end the payment.

## Retries and duplicate payments

Every authorization carries an idempotency key, so that a retried request is not charged twice.

1. **Retrying the same payment:** call `start` again with the JSON of the same session (or a new session of the same ride) and the other fields unchanged. If the cashier presents the same card, the SDK reuses the key, and XPay replays the original outcome instead of charging again. This holds across `start` calls for as long as your app process lives.
2. **A new payment:** each ride has its own `external_ref` in its session response.
3. **A different card or changed details:** the request is different, so it gets a new key.
4. **`duplicate`:** XPay holds a different request under the same key. A payment may already exist: check before charging again.

A chip tap always produces a new key, because every tap carries a new cryptogram.

The session token is not part of the key. Retrying with a new session, after the previous one expired, still reuses the key. Opening a new session revokes the earlier ones (see [Authentication](#authentication)).

A corporate wallet ride is paid at most once, by the QR or by a code: once paid, XPay closes the ride, and a later code request for it fails with `ride_not_found`. Check the ride with your backend before starting again after a `failed` or `cancelled` wallet result.

## Confirming a payment on your backend

The result reaches the cashier's phone, which is not a trusted source. Before you fulfil the order, confirm the payment from your backend with XPay, using `authId` or your `externalRef`.

Treat `cancelled` and `failed` results that carry an `authId` the same way. The payment was authorized and may still complete or expire on the XPay side.

A corporate wallet payment has no `authId`: confirm it by `externalRef`.

## Logging

Pass `onLog` to receive the SDK's business events, for example authorization outcomes, verification steps, NFC failures and corporate wallet steps (`feature` `corporate_wallet`). Each `XPayLogEvent` has a `level`, a `category`, the `feature` and `action`, optional `reason`, `errorCode` and `serverMessage`, and an `input` map with the identifiers involved.

Events never contain a card number, chip key, cryptogram, nonce, verification code or token. NFC failure events do contain the chip's UID.

The SDK sends logs nowhere else. Without `onLog`, it stays silent.

## Example app

`example/` is a small host app that exercises the whole flow with only the public API.

```bash
cd example
flutter run --dart-define=XPAY_BASE_URL=<sandbox base url> --dart-define=XPAY_SESSION_JSON='<payment-session response JSON>'
```

You can also type the base URL and paste the session JSON into the app. A session lasts 15 minutes and covers one ride, so get a new one from your backend for each payment.

Use a real Android phone with NFC to try the chip tap.

## Limitations

1. Native Android and iOS apps use the packages described in the native integration guides, not this document.
2. The SDK screens use XPay's styling. Theming is not configurable yet. Text uses the `Inter` font when your app bundles it, and your app's default font otherwise.
3. The SDK shows no success or decline screen. Your app shows its own from the result.
4. On Android, `chip_tap` is listed when the phone has NFC. A phone whose NFC chip cannot read MIFARE Classic cards is only detected when a card is tapped.
5. QR methods are listed without checking for a camera.
6. Network failures (`no_connection`, `no_host`, `timeout`) and an expired session (`token_expired`) carry English `message` copy in both languages.
7. Amounts are whole units, which suits VND. Other currencies have not been considered yet.
8. The corporate wallet QR is checked every 3 seconds; a payment made at the QR is reported up to 3 seconds later.
9. On Android the SDK has no app bar of its own and is left only with the system back button. iOS has no system back button, so on iOS the method list shows a back button in the top left corner; it cancels the payment like the Android back button.
