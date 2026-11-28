import Foundation

/// The single result of one payment.
public struct XPayPaymentResult: Equatable {
    public let status: XPayPaymentStatus
    public let failure: XPayPaymentFailure?
    public let paidBy: XPayPaidBy?
    public let rideStatus: XPayRideStatus?
    public let authId: String?
    public let captureId: String?
    public let currency: String?
    public let errorCode: String?
    public let externalRef: String?
    public let pendingAuthId: String?
    public let amount: Int64?
    public let createdAt: Date?

    public init(
        status: XPayPaymentStatus,
        failure: XPayPaymentFailure? = nil,
        paidBy: XPayPaidBy? = nil,
        rideStatus: XPayRideStatus? = nil,
        authId: String? = nil,
        captureId: String? = nil,
        currency: String? = nil,
        errorCode: String? = nil,
        externalRef: String? = nil,
        pendingAuthId: String? = nil,
        amount: Int64? = nil,
        createdAt: Date? = nil
    ) {
        self.status = status
        self.failure = failure
        self.paidBy = paidBy
        self.rideStatus = rideStatus
        self.authId = authId
        self.captureId = captureId
        self.currency = currency
        self.errorCode = errorCode
        self.externalRef = externalRef
        self.pendingAuthId = pendingAuthId
        self.amount = amount
        self.createdAt = createdAt
    }

    /// `true` when `status` is `paid`.
    public var isSuccessful: Bool {
        return status == .paid
    }

    public var isRetryable: Bool {
        return status.isRetryable
    }

    static func unavailable(_ errorCode: String) -> XPayPaymentResult {
        return XPayPaymentResult(
            status: .unavailable,
            failure: XPayPaymentFailure(reason: .sdkError, errorCode: errorCode, note: errorCode),
            errorCode: errorCode
        )
    }
}

public struct XPayPaymentFailure: Equatable {
    public let reason: XPayFailureReason
    public let authId: String?
    public let errorCode: String?
    public let note: String?

    public init(reason: XPayFailureReason, authId: String? = nil, errorCode: String? = nil, note: String? = nil) {
        self.reason = reason
        self.authId = authId
        self.errorCode = errorCode
        self.note = note
    }
}

/// Error codes the SDK itself produces. Compare them with `XPayPaymentResult.errorCode` instead of hard-coding the strings.
public enum XPayErrorCode {
    public static let busy = "sdk_busy"
    public static let invalidRequest = "sdk_invalid_request"
    public static let notInitialized = "sdk_not_initialized"
    public static let presentationFailed = "sdk_presentation_failed"
    public static let sessionAmountChanged = "sdk_session_amount_changed"
    public static let unexpectedResponse = "sdk_unexpected_response"
    public static let unsupported = "sdk_unsupported"
}

public enum XPayPaymentStatus: String {
    case paid
    case retryInPartner
    case otherMethod
    case csPending
    case rideClosed
    case cancelled
    case unavailable

    public var isRetryable: Bool {
        switch self {
        case .retryInPartner, .cancelled:
            return true
        case .paid, .otherMethod, .csPending, .rideClosed, .unavailable:
            return false
        }
    }
}

public enum XPayFailureReason: String {
    case paymentDeclined = "payment_declined"
    case sdkError = "sdk_error"
    case other
}

public enum XPayPaidBy: String {
    case partner
    case cs
}

public enum XPayRideStatus: String {
    case completed
    case cancelled
}
