import Foundation

/// Input of one payment: the unedited response body of `POST /merchant/rides/{order_id}/payment-session`.
public struct XPayCheckout: Equatable, CustomStringConvertible, CustomDebugStringConvertible {
    public let sessionJson: String
    public let fetchSession: (@MainActor () async throws -> String)?

    public init(sessionJson: String, fetchSession: (@MainActor () async throws -> String)? = nil) {
        self.sessionJson = sessionJson
        self.fetchSession = fetchSession
    }

    public var description: String {
        return "XPayCheckout(sessionJson: ***, fetchSession: \(fetchSession == nil ? "nil" : "set"))"
    }

    public var debugDescription: String {
        return description
    }

    public static func == (lhs: XPayCheckout, rhs: XPayCheckout) -> Bool {
        return lhs.sessionJson == rhs.sessionJson && (lhs.fetchSession == nil) == (rhs.fetchSession == nil)
    }
}
