import Foundation

/// Input of one payment: the unedited response body of `POST /merchant/rides/{order_id}/payment-session`.
public struct XPayCheckout: Equatable, CustomStringConvertible, CustomDebugStringConvertible {
    public let sessionJson: String

    public init(sessionJson: String) {
        self.sessionJson = sessionJson
    }

    public var description: String {
        return "XPayCheckout(sessionJson: ***)"
    }

    public var debugDescription: String {
        return description
    }
}
