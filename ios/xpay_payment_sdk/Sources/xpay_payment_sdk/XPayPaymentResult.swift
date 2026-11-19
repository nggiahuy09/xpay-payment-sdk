import Foundation

/// The single result of one payment.
public struct XPayPaymentResult: Equatable {
    public let status: XPayPaymentStatus
    public let authId: String?
    public let bookingRef: String?
    public let captureId: String?
    public let currency: String?
    public let declineCode: String?
    public let errorCode: String?
    public let externalRef: String?
    public let message: String?
    public let amount: Int64?
    public let createdAt: Date?

    public init(
        status: XPayPaymentStatus,
        authId: String? = nil,
        bookingRef: String? = nil,
        captureId: String? = nil,
        currency: String? = nil,
        declineCode: String? = nil,
        errorCode: String? = nil,
        externalRef: String? = nil,
        message: String? = nil,
        amount: Int64? = nil,
        createdAt: Date? = nil
    ) {
        self.status = status
        self.authId = authId
        self.bookingRef = bookingRef
        self.captureId = captureId
        self.currency = currency
        self.declineCode = declineCode
        self.errorCode = errorCode
        self.externalRef = externalRef
        self.message = message
        self.amount = amount
        self.createdAt = createdAt
    }

    /// `true` when `status` is `approved` or `captured`.
    public var isSuccessful: Bool {
        return status == .approved || status == .captured
    }
}

/// Error codes the SDK itself produces. Compare them with `XPayPaymentResult.errorCode` instead of hard-coding the strings.
public enum XPayErrorCode {
    public static let busy = "sdk_busy"
    public static let invalidRequest = "sdk_invalid_request"
    public static let notInitialized = "sdk_not_initialized"
    public static let presentationFailed = "sdk_presentation_failed"
    public static let unexpectedResponse = "sdk_unexpected_response"
}

public enum XPayPaymentStatus: String {
    case approved
    case captured
    case declined
    case cancelled
    case duplicate
    case failed
    case expired
    case unsupported
}
