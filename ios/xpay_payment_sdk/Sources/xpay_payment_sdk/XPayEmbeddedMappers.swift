import Foundation

extension XPayConfig {
    func toMessage() -> XPayEmbeddedConfigMessage {
        return XPayEmbeddedConfigMessage(language: language.toMessage(), baseUrl: environment.baseUrl)
    }
}

extension XPayCheckout {
    func toMessage() -> XPayEmbeddedRequestMessage {
        return XPayEmbeddedRequestMessage(sessionJson: sessionJson, canFetchSession: fetchSession != nil)
    }
}

extension XPayEmbeddedResultMessage {
    func toResult() -> XPayPaymentResult {
        return XPayPaymentResult(
            status: status.toStatus(),
            failure: failure?.toFailure(),
            paidBy: paidBy?.toPaidBy(),
            rideStatus: rideStatus?.toRideStatus(),
            authId: authId,
            captureId: captureId,
            currency: currency,
            errorCode: errorCode,
            externalRef: externalRef,
            pendingAuthId: pendingAuthId,
            amount: amount,
            createdAt: createdAtEpochMillis.map { Date(timeIntervalSince1970: TimeInterval($0) / 1000.0) }
        )
    }
}

extension XPayEmbeddedLogMessage {
    func toLogEvent() -> XPayLogEvent {
        return XPayLogEvent(
            input: input,
            category: category.toCategory(),
            level: level.toLevel(),
            action: action,
            errorCode: errorCode,
            feature: feature,
            reason: reason,
            serverMessage: serverMessage
        )
    }
}

private extension XPayLanguage {
    func toMessage() -> XPayEmbeddedLanguage {
        switch self {
        case .en: return .en
        case .vi: return .vi
        }
    }
}

private extension XPayEmbeddedPaymentStatus {
    func toStatus() -> XPayPaymentStatus {
        switch self {
        case .paid: return .paid
        case .retryInPartner: return .retryInPartner
        case .otherMethod: return .otherMethod
        case .csPending: return .csPending
        case .rideClosed: return .rideClosed
        case .cancelled: return .cancelled
        case .unavailable: return .unavailable
        }
    }
}

private extension XPayEmbeddedFailureMessage {
    func toFailure() -> XPayPaymentFailure {
        return XPayPaymentFailure(reason: reason.toReason(), authId: authId, errorCode: errorCode, note: note)
    }
}

private extension XPayEmbeddedFailureReason {
    func toReason() -> XPayFailureReason {
        switch self {
        case .paymentDeclined: return .paymentDeclined
        case .sdkError: return .sdkError
        case .other: return .other
        }
    }
}

private extension XPayEmbeddedPaidBy {
    func toPaidBy() -> XPayPaidBy {
        switch self {
        case .partner: return .partner
        case .cs: return .cs
        }
    }
}

private extension XPayEmbeddedRideStatus {
    func toRideStatus() -> XPayRideStatus {
        switch self {
        case .completed: return .completed
        case .cancelled: return .cancelled
        }
    }
}

private extension XPayEmbeddedLogCategory {
    func toCategory() -> XPayLogCategory {
        switch self {
        case .api: return .api
        case .behavior: return .behavior
        case .error: return .error
        }
    }
}

private extension XPayEmbeddedLogLevel {
    func toLevel() -> XPayLogLevel {
        switch self {
        case .info: return .info
        case .warn: return .warn
        case .error: return .error
        }
    }
}
