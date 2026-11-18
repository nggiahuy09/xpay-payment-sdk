# Changelog

All notable changes to the XPay Payment SDK are listed here. The SDK shares its version number with the XPay Merchant app released at the same time, so the number does not follow Semantic Versioning: read this file to find out whether a release changes the public API.

Entries marked **Breaking** need a change in your app.

## 3.11.16

First release published on GitHub. Earlier builds were sent to partners as a zip file.

### Added

1. Payment flow driven by a ride payment session: `XPayPaymentRequest.fromSession(sessionJson)` takes the response of `POST /merchant/rides/{order_id}/payment-session` unedited.
2. A method list as the first SDK screen, built from the session's `entry_modes`: `ride_card`, `card_qr`, `manual_pan`, `chip_tap` (Android with NFC) and `token`.
3. OTP and PIN verification screens, including the recipient picker.
4. Android native API (`XPayPayment`, `XPayPaymentContract`, `XPayCheckout`) for hosts without Flutter, distributed as an AAR: `com.xperise.xpay.partner:flutter_release:3.11.16`.

### Changed

1. **Breaking:** the invoice buyer and service date were removed from the public API. `XPayPaymentRequest.fromSession` and `XPayCheckout` take only the session JSON.
