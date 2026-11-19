import Foundation

/// Thrown by `XPayPayment.initialize(config:)` when the SDK cannot be configured, for example while a payment is open or while a previous `initialize` is still running.
/// The previous configuration stays in effect.
public struct XPayInitializationError: Error, LocalizedError, Equatable {
    public let message: String

    public init(message: String) {
        self.message = message
    }

    public var errorDescription: String? {
        return message
    }
}
