import Foundation

extension XPayConfig {
    func toMessage() -> XPayEmbeddedConfigMessage {
        return XPayEmbeddedConfigMessage(language: language.toMessage(), baseUrl: environment.baseUrl)
    }
}

extension XPayCheckout {
    func toMessage() -> XPayEmbeddedRequestMessage {
        return XPayEmbeddedRequestMessage(sessionJson: sessionJson)
    }
}

extension XPayEmbeddedResultMessage {
    func toResult() -> XPayPaymentResult {
        return XPayPaymentResult(
            status: status.toStatus(),
            authId: authId,
            bookingRef: bookingRef,
            captureId: captureId,
            currency: currency,
            declineCode: declineCode,
            errorCode: errorCode,
            externalRef: externalRef,
            message: message,
            amount: amount,
            createdAt: createdAtEpochMillis.map { Date(timeIntervalSince1970: TimeInterval($0) / 1000.0) },
            failureCategory: failureCategory?.toCategory()
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
        case .approved: return .approved
        case .captured: return .captured
        case .declined: return .declined
        case .cancelled: return .cancelled
        case .duplicate: return .duplicate
        case .failed: return .failed
        case .expired: return .expired
        case .unsupported: return .unsupported
        }
    }
}

private extension XPayEmbeddedFailureCategory {
    func toCategory() -> XPayFailureCategory {
        switch self {
        case .system: return .system
        case .network: return .network
        case .cardholderRetry: return .cardholderRetry
        case .cardholderChange: return .cardholderChange
        case .corporatePolicy: return .corporatePolicy
        case .session: return .session
        case .unknown: return .unknown
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
