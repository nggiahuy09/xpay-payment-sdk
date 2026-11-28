# XPay Payment SDK for Flutter

Collect a payment with an XPay card from your own Flutter app. The SDK owns the card part of the checkout: it checks whether the ride is already paid, shows the amount and the trip, lets the cashier pick how the card is presented, reads the card (NFC tap, QR scan, one-time code, manual entry, or the customer's linked card), authorizes the payment with XPay, runs the OTP or PIN verification when XPay asks for one, handles an unsuccessful payment (retry, call XPay support, wait for support to pay), and hands your app a single result. For a ride booked on the rider's corporate wallet, it collects from the wallet instead, by a QR code the rider scans in the XPERISE app or by a code sent to the rider's phone or email.

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

| The SDK owns                                                                      | Your app owns                                                                 |
| --------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| Checking the ride's payment status every time it opens                            | The order and its payment session                                             |
| The summary and method screen, then the card capture screens                      | Offering "XPay card" among your own payment methods                           |
| Authorizing the payment with XPay, OTP / PIN verification screens                 | Your success screen, navigation, refreshing your own data                     |
| The failure popup, the next-step screen and the "waiting for XPay support" screen | Reporting `payment-failure` from your backend, voiding pending payments, cash |
| "Payment successful" when the ride is already paid, "ride closed" or "cancelled"  |                                                                               |
| Returning one result per payment                                                  |                                                                               |

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
      ref: v3.1128.1
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

When the session expires mid-payment, the SDK asks your app for a new one through `fetchSession`, see [Renewing the session](#renewing-the-session-fetchsession). Without `fetchSession`, or when no new session comes back, the SDK shows "the payment session could not be opened" and returns `retryInPartner`.

**The amount is locked to the session.** The SDK collects exactly the `amount` of the session response. To collect another amount, open a new session; never edit the JSON before handing it to the SDK.

**Opening a new session for a ride revokes the earlier ones.** A request that carries a revoked session fails with `ride_payment_session_revoked` (HTTP 401): the SDK shows "the fare was updated" and returns `retryInPartner`. Open a session right before collecting, and never open another one for a ride while a payment of that ride is still open, except in `fetchSession`.

**The trip data comes from the session.** XPay attaches the session's pickup, destination, plate number, fare, sub-fee and distance to the payment. Your app does not pass them to the SDK.

**The reference comes from the session.** The SDK uses the response's `external_ref` (`XP-…`), so the result's `externalRef` is `XP-…` too.

**An unreadable session is never paid.** A string that is not a JSON object, has no `session_token`, whose `amount` is not whole đồng (for example `"138000.50"`), or, for a card session, whose `entry_modes` hold no method the SDK knows makes `start` return `unavailable` with `sdk_invalid_request`, and nothing is sent to XPay. The exact reason reaches `onLog` as an `error` event with `feature` `payment`, `action` `start_payment` and a `reason` among `invalid_session_json`, `malformed_session`, `missing_session_token`, `missing_entry_modes`, `invalid_amount`, `amount_below_minimum`, `missing_currency`, `invalid_external_ref`; its `input` carries only `session_json_length`, never the JSON or its token.

**Never put an XPay merchant key, API key or any other server credential in your app.**

### Renewing the session: `fetchSession`

A session lives 15 minutes, so it can expire while the driver is working (the rider looks for a card, waits for the OTP). Pass `fetchSession` to `XPayPaymentRequest.fromSession` and the SDK gets a new session without interrupting the payment:

1. When XPay answers `401 ride_payment_session_expired`, the SDK calls `fetchSession` once and waits up to 15 seconds.
2. `fetchSession` asks your backend for a new session of the **same ride and fare** (`POST /merchant/rides/{order_id}/payment-session`) and returns the whole response body.
3. The SDK sends the rejected request again, with the same body and idempotency key, on the new session. The driver only sees a slightly longer spinner.
4. A new session with another fare: the SDK shows "the fare was updated" and returns `retryInPartner` with `failure.errorCode` `sdk_session_amount_changed` and `failure.note` `cước đổi`.
5. `fetchSession` throws, takes longer than 15 seconds, or returns a session of another ride: the SDK shows "the payment session could not be opened" and returns `retryInPartner` with `failure.reason` `sdkError`.

## Initialize

Call `initialize` once before the first payment, for example at app start or after the cashier signs in. Call it again to change the language or the base URL.

1. Do not call it while a payment is open, that is before `start` returns. It then throws a `StateError` and keeps the previous configuration.
2. Do not call it before the previous call completes. The later call then throws a `StateError`, and the earlier one carries on.
3. While `initialize` runs, `start` returns `unavailable` with `errorCode` `sdk_not_initialized`. Always await `initialize` before calling `start`.

```dart
await XPayPayment.initialize(
  XPayConfig(
    environment: const XPayEnvironment(baseUrl: 'https://<xpay api host>'),
    language: XPayLanguage.vi,
    onLog: (event) => myLogger.log(event.toString()),
  ),
);
```

| Field         | Description                                                                   |
| ------------- | ----------------------------------------------------------------------------- |
| `environment` | The XPay API base URL for sandbox or production. XPay provides both.          |
| `language`    | `XPayLanguage.vi` (default) or `XPayLanguage.en`. Applies to the SDK screens. |
| `onLog`       | Optional. See [Logging](#logging).                                            |

## Take a payment

```dart
Future<void> payWithXPay(BuildContext context, Order order) async {
  final sessionJson = await myBackend.openPaymentSession(order.id, fare: order.fare, subFee: order.subFee, distanceKm: order.distanceKm);
  if (context.mounted == false) return;

  final result = await XPayPayment.start(
    context,
    XPayPaymentRequest.fromSession(
      sessionJson,
      () => myBackend.openPaymentSession(order.id, fare: order.fare, subFee: order.subFee, distanceKm: order.distanceKm),
    ),
  );
  await myBackend.saveXPayResult(order.id, result);

  switch (result.status) {
    case XPayPaymentStatus.paid:
      await confirmOnBackend(order.id, externalRef: result.externalRef);
      showPaidScreen(order);
    case XPayPaymentStatus.rideClosed:
      closeRide(order, result.rideStatus);
    case XPayPaymentStatus.retryInPartner:
    case XPayPaymentStatus.otherMethod:
    case XPayPaymentStatus.csPending:
    case XPayPaymentStatus.cancelled:
    case XPayPaymentStatus.unavailable:
      showPaymentScreen(order, lastXPayResult: result);
  }
}
```

`openPaymentSession` is your own function: it calls your backend, which calls `payment-session` with the body described in [Authentication](#authentication) and returns the response body as a string, untouched. The second argument of `fromSession` is `fetchSession`, see [Renewing the session](#renewing-the-session-fetchsession).

Your payment screen uses `lastXPayResult` to offer XPay again right away when `isRetryable` is true, to ask the driver to check with XPay support before collecting another way after `csPending`, and to void `pendingAuthId` and report `payment-failure` once the driver settles on another method. See [Handling the result](#handling-the-result).

1. `start` opens the SDK screens on top of your app, on the root navigator. When the payment ends, it closes them and returns. It never touches your app's router.
2. Every time it opens, the SDK first checks the ride (up to 15 seconds). A ride that is already paid opens straight on the "payment successful" screen, a ride that is closed or cancelled on the "ride closed" screen, so it is never charged again. When the check cannot run (no connection), the method list opens as usual.
3. While XPay is authorizing the card or verifying a code, the back button is disabled, so the cashier cannot leave a payment that may already be charged.
4. Backing out of a capture screen returns to the method list. Backing out of the method list ends with `cancelled`. Backing out of the OTP/PIN screen asks for confirmation, then ends with `cancelled` and `pendingAuthId`.
5. When none of the session's methods can run on the device (for example a session that allows only `chip_tap`, on iOS), `start` returns `unavailable` with `sdk_unsupported` without opening anything.
6. An unsuccessful payment is handled on the SDK screens (failure popup, next-step screen, waiting for XPay support) before the SDK closes. Your app does not show another error popup.

## Request reference

`XPayPaymentRequest`, built with `XPayPaymentRequest.fromSession(sessionJson, [fetchSession])`:

| Field          | Type                         | Required | Notes                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| -------------- | ---------------------------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sessionJson`  | `String`                     | Yes      | The whole body of `POST /merchant/rides/{order_id}/payment-session`. The SDK takes `session_token`, `amount` (whole đồng, at least 1,000), `external_ref` (1 to 64 characters), `payment_template.currency` (`VND` by default), `payment_template.product_type`, `payment_method` (`card` by default), `entry_modes`, `ride_card`, `order_id` and the trip in `payment_template.enhanced_data` from it. See [Authentication](#authentication). |
| `fetchSession` | `Future<String> Function()?` | No       | Called when the session expires mid-payment. Returns the whole body of a new session for the **same ride and fare**. See [Renewing the session](#renewing-the-session-fetchsession).                                                                                                                                                                                                                                                           |

A request that breaks these rules is rejected before anything is sent: `start` returns `unavailable` with `errorCode` `sdk_invalid_request`.

The card number, chip data and verification code are never part of the request. The SDK collects them itself.

## Result reference

`start` always completes with exactly one `XPayPaymentResult`.

| Field           | Type                  | Notes                                                                                                                     |
| --------------- | --------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `status`        | `XPayPaymentStatus`   | Always set. See [Handling the result](#handling-the-result)                                                               |
| `failure`       | `XPayPaymentFailure?` | Why XPay could not collect, on `retryInPartner`, `otherMethod`, `csPending` and `unavailable`                             |
| `pendingAuthId` | `String?`             | A card payment still waiting for its OTP/PIN when the SDK closed. Void it from your backend before collecting another way |
| `paidBy`        | `XPayPaidBy?`         | On `paid`: `partner` (collected in the car through the SDK) or `cs` (XPay support paid on the rider's behalf)             |
| `rideStatus`    | `XPayRideStatus?`     | On `rideClosed`: `completed` (XPay support closed the ride without collecting) or `cancelled`                             |
| `authId`        | `String?`             | On `paid`: the card payment. Always `null` for a corporate wallet payment                                                 |
| `captureId`     | `String?`             | On `paid`, when captured                                                                                                  |
| `externalRef`   | `String?`             | On `paid`: the ride's `XP-…` reference                                                                                    |
| `amount`        | `int?`                | On `paid`: what XPay collected. When XPay support paid, it may differ from the amount locked in the session               |
| `currency`      | `String?`             | On `paid`                                                                                                                 |
| `createdAt`     | `DateTime?`           | On `paid`, when known                                                                                                     |
| `errorCode`     | `String?`             | On `unavailable`: the SDK error code                                                                                      |
| `isSuccessful`  | `bool`                | `true` for `paid`                                                                                                         |
| `isRetryable`   | `bool`                | `true` for `retryInPartner` and `cancelled`: your app may open XPay again right away, with a new session                  |

`XPayPaymentFailure`:

| Field       | Type                | Notes                                                                                                                                                  |
| ----------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `reason`    | `XPayFailureReason` | `paymentDeclined`, `sdkError` or `other`. Your backend sends `reason.toRemote()` (`payment_declined`, `sdk_error`, `other`) to `payment-failure` as is |
| `authId`    | `String?`           | The latest declined card payment. `null` on a corporate wallet ride                                                                                    |
| `errorCode` | `String?`           | The raw code the SDK routed on (decline reason or API code), for support and reconciliation                                                            |
| `note`      | `String?`           | For XPay support: `cước đổi` (fare changed), `chờ tổng đài quá 5 phút` (support wait timed out), or the error code on `sdkError`                       |

`XPayPaidBy` is `partner` or `cs`. `XPayRideStatus` is `completed` or `cancelled`.

### Handling the result

The SDK shows every failure on its own screens and guides the driver: retry inside the SDK, go back to your app, or call XPay support and pick the next step. When it closes, your app gets one result and acts on it. The five failure flows, each screen and the full procedure are in [docs/failure_handling.vi.md](docs/failure_handling.vi.md) (Vietnamese).

| Status           | The SDK closed on                                                 | `isRetryable` | What your app does                                                                                                                     |
| ---------------- | ----------------------------------------------------------------- | ------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `paid`           | The "payment successful" screen, after 3 seconds                  | `false`       | Confirm on your backend by `externalRef`, show your success screen                                                                     |
| `retryInPartner` | The failure popup, "back to the payment screen"                   | `true`        | Go back to your payment screen and offer XPay again with a new session. With `failure.note` `cước đổi`, show the new amount first      |
| `otherMethod`    | The next-step screen, "pay another way"                           | `false`       | Void `pendingAuthId` if set, go back to your payment screen for another method, report `payment-failure`                               |
| `csPending`      | The "waiting for XPay support" screen, after 5 minutes or on back | `false`       | **Do not collect another way right away**: check with XPay support first. Report `payment-failure`; for cash, report `paid_cash` first |
| `rideClosed`     | The "ride closed" or "ride cancelled" screen                      | `false`       | Do not collect. Update the ride from `rideStatus`                                                                                      |
| `cancelled`      | The driver left before a result, or your app closed the SDK       | `true`        | Go back to your payment screen. Void `pendingAuthId` if set. XPay may be opened again                                                  |
| `unavailable`    | Nothing was opened                                                | `false`       | See `errorCode`: fix the integration, or let the driver pay another way                                                                |

1. **Opening XPay again always uses a new session.** Your backend calls `POST /merchant/rides/{order_id}/payment-session` again (the previous session is revoked) and your app passes the new response to `start`. There is no limit.
2. **A corporate wallet payment** also ends with `paid`, without `authId` or `captureId`: no card payment is made. Confirm it by `externalRef`.
3. **`paid` with `paidBy` `cs`** means XPay support paid on the rider's behalf, possibly found when the SDK opened or while the driver was retrying. Do not collect again.
4. **Do not show a second error popup.** The driver has already seen the reason, the ride reference and the XPay support number on the SDK popup.
5. **Report `payment-failure`.** Every time the driver stays on your payment screen without paying through XPay (`otherMethod`, `csPending`, or `retryInPartner`, `cancelled`, `unavailable` without opening XPay again), your backend calls `POST /merchant/rides/{order_id}/payment-failure` with `reason`, `auth_id` and `note` from `failure`. For cash, send `reason: "paid_cash"` with the `amount` **before** the driver takes the cash. Do not report `paid` or `rideClosed`. Details: section 6 of [docs/failure_handling.vi.md](docs/failure_handling.vi.md).

XPay support: **1900 2189**, available as `XPayPayment.supportHotline`. The SDK already shows it on its failure popup.

### Error codes

`errorCode` is set only on `unavailable`. These codes are in `XPayErrorCode`:

| Code                  | Cause                                                    |
| --------------------- | -------------------------------------------------------- |
| `sdk_not_initialized` | `start` was called before `initialize` completed.        |
| `sdk_busy`            | `start` was called while another payment was still open. |
| `sdk_invalid_request` | The request failed validation. Nothing was sent.         |
| `sdk_unsupported`     | None of the session's methods can run on this device.    |

`failure.errorCode` keeps the raw code the SDK routed on: a decline reason such as `insufficient_funds`, an XPay API code such as `ride_payment_session_revoked`, a network code (`no_connection`, `no_host`, `timeout`), or one of the SDK's own: `sdk_session_amount_changed` (`fetchSession` returned another fare) and `sdk_unexpected_response` (XPay answered with a status the SDK cannot act on). Your app does not need to branch on it. The codes of each flow are listed in section 8 of [docs/failure_handling.vi.md](docs/failure_handling.vi.md).

## Retries and duplicate payments

Every card authorization and card verification carries an idempotency key, so that a retried request is not charged twice.

1. **The SDK sends an authorization or card verification again on its own** after a timeout, a lost connection, an HTTP 5xx or `request_in_flight`, with the same key and body. XPay replays the first outcome if it already recorded one.
2. **"Retry" inside the SDK** (the failure popup, or "retry with XPay" on the next-step screen): after a decline, the next attempt gets a new key. After a system error with an unknown outcome, the same card reuses the key, so XPay replays the earlier outcome instead of charging again.
3. **Opening XPay again from your app** (`start` again) for the same ride: when the cashier presents the same card and the amount is unchanged, the SDK reuses the previous key for as long as your app process lives.
4. **A different card or amount** gets a new key. A chip tap always gets a new key, because every tap carries a new cryptogram.
5. The session token is not part of the key. Retrying on a new session still reuses it.
6. When the ride is already paid (for example by XPay support while the driver was retrying), XPay answers `ride_already_paid`, and the SDK shows the "payment successful" screen and returns `paid` without charging the card again.

A corporate wallet ride is paid at most once, by the QR or by a code: once paid, XPay closes the ride, and the next time XPay is opened the SDK goes straight to the "payment successful" screen.

## Confirming a payment on your backend

The result reaches the cashier's phone, which is not a trusted source. Before you fulfil the order, confirm the payment from your backend with XPay, using `externalRef` (or `authId` for a card payment).

1. Confirm `paid` with `paidBy` `cs` by `externalRef` too. `amount` is what XPay collected, which may differ from the locked amount.
2. A corporate wallet payment has no `authId`: confirm it by `externalRef`.
3. `pendingAuthId` is a card payment still waiting for its code. Void it from your backend with `POST /merchant/payments/{auth_id}/void`, or let it expire after about 10 minutes. Until then, `paid_cash` is refused with `409 ride_payment_pending`.
4. After `csPending`, XPay support may still pay. Your backend learns it through the channel you already use to confirm payments, or from `409 ride_already_paid` when it reports `paid_cash`.

## Logging

Pass `onLog` to receive the SDK's business events, for example authorization outcomes, verification steps, NFC failures, corporate wallet steps (`feature` `corporate_wallet`) and the flow chosen for each failure (`feature` `payment`, `action` `checkout_failure`, with `route`, `kind` and `error_code` in `input`). Each `XPayLogEvent` has a `level`, a `category`, the `feature` and `action`, optional `reason`, `errorCode` and `serverMessage`, and an `input` map with the identifiers involved.

Events never contain a card number, chip key, cryptogram, nonce, verification code or token. NFC failure events do contain the chip's UID.

The SDK sends logs nowhere else. Without `onLog`, it stays silent.

## Example app

`example/` is a small host app that exercises the whole flow with only the public API.

```bash
cd example
flutter run --dart-define=XPAY_BASE_URL=<sandbox base url> --dart-define=XPAY_SESSION_JSON='<payment-session response JSON>'
```

You can also type the base URL and paste the session JSON into the app. A session lasts 15 minutes and covers one ride, so get a new one from your backend for each payment. The app also lets you pick what `fetchSession` does when the session expires: return a renewed session JSON you pasted, throw, hang, or not be passed at all.

Use a real Android phone with NFC to try the chip tap.

## Limitations

1. Native Android and iOS apps use the packages described in the native integration guides, not this document.
2. The SDK screens use XPay's styling. Theming is not configurable yet. Text uses the `Inter` font when your app bundles it, and your app's default font otherwise.
3. The SDK shows failures and its own failure-handling screens, but it does not replace your success screen. Your app shows its own from the result.
4. On Android, `chip_tap` is listed when the phone has NFC. A phone whose NFC chip cannot read MIFARE Classic cards is only detected when a card is tapped.
5. QR methods are listed without checking for a camera.
6. Amounts are whole units, which suits VND. Other currencies have not been considered yet.
7. The corporate wallet QR is checked every 3 seconds; a payment made at the QR is reported up to 3 seconds later.
8. On Android the SDK has no app bar of its own and is left only with the system back button. iOS has no system back button, so on iOS the method list shows a back button in the top left corner; it cancels the payment like the Android back button.
