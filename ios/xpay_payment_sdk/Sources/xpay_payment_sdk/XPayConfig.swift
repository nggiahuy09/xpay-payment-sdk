import Foundation

/// Configuration passed to `XPayPayment.initialize(config:)`.
public struct XPayConfig {
    public let environment: XPayEnvironment
    public let language: XPayLanguage
    public let onLog: ((XPayLogEvent) -> Void)?

    public init(environment: XPayEnvironment, language: XPayLanguage = .vi, onLog: ((XPayLogEvent) -> Void)? = nil) {
        self.environment = environment
        self.language = language
        self.onLog = onLog
    }
}

/// The XPay environment (sandbox or production) the SDK talks to.
public struct XPayEnvironment: Equatable {
    public let baseUrl: String

    public init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
}

/// Language of the SDK screens and of `XPayPaymentResult.message`.
public enum XPayLanguage {
    case en
    case vi
}
