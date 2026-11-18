# XPay SDK Demo

A minimal host app for the XPay payment SDK. It uses only the public API in `package:xpay_payment_sdk/xpay_payment_sdk.dart`.

## Run

```bash
flutter run --dart-define=XPAY_BASE_URL=<sandbox base url> --dart-define=XPAY_SESSION_TOKEN=<sandbox session token>
```

Both values can also be typed into the app. A session token covers one ride and expires after 15 minutes, so paste a fresh one from your backend for each payment. The session locks the payment amount: the amount typed into the app must equal the `amount` the session was opened with, otherwise XPay answers `amount_locked`. With "Attach ride details", the fare is the amount, the sub fee is 0 and the distance is 8.5 km, so open the session with the same values.

## What it shows

1. Initializing the SDK with an environment, a language and a log callback.
2. Disabling payment methods that `XPayPayment.isSupported` rejects on the device.
3. Starting a payment with a session token, optionally with ride details, and printing the `XPayPaymentResult`.
4. Keeping the external reference after a failed payment, so a retry reuses the idempotency key, and generating a new one after a successful payment.
5. The SDK's business events from `onLog`.

NFC tap needs a real Android phone with NFC.
