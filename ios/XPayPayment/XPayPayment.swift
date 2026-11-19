// Source of the `XPayPayment` target that native iOS apps import: the Swift package in the release zip and the Package.swift of the public repo
// both compile this file. The Flutter plugin itself does not (see xpay_payment_sdk.podspec and xpay_payment_sdk/Package.swift).
@_exported import xpay_payment_sdk

import FlutterPluginRegistrant
import Foundation

/// FlutterPluginRegistrant is a static library, and XPayPayment only looks GeneratedPluginRegistrant up at runtime.
/// This reference keeps the class, and the plugins it registers, in the app binary. Objective-C classes are never dead-stripped.
@objc(XPayPaymentPluginRegistrantAnchor)
final class XPayPaymentPluginRegistrantAnchor: NSObject {
    @objc static let registrant: AnyClass = GeneratedPluginRegistrant.self
}
