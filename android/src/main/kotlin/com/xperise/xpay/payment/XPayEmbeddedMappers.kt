package com.xperise.xpay.payment

import java.util.Date

internal fun XPayConfig.toMessage(): XPayEmbeddedConfigMessage = XPayEmbeddedConfigMessage(language = language.toMessage(), baseUrl = environment.baseUrl)

internal fun XPayCheckout.toMessage(): XPayEmbeddedRequestMessage = XPayEmbeddedRequestMessage(sessionJson = sessionJson, canFetchSession = fetchSession != null)

internal fun XPayEmbeddedResultMessage.toResult(): XPayPaymentResult = XPayPaymentResult(
    status = status.toStatus(),
    failure = failure?.toFailure(),
    paidBy = paidBy?.toPaidBy(),
    rideStatus = rideStatus?.toRideStatus(),
    authId = authId,
    captureId = captureId,
    currency = currency,
    errorCode = errorCode,
    externalRef = externalRef,
    pendingAuthId = pendingAuthId,
    amount = amount,
    createdAt = createdAtEpochMillis?.let(::Date),
)

internal fun XPayEmbeddedLogMessage.toLogEvent(): XPayLogEvent = XPayLogEvent(
    input = input,
    category = category.toCategory(),
    level = level.toLevel(),
    action = action,
    errorCode = errorCode,
    feature = feature,
    reason = reason,
    serverMessage = serverMessage,
)

private fun XPayLanguage.toMessage(): XPayEmbeddedLanguage = when (this) {
    XPayLanguage.EN -> XPayEmbeddedLanguage.EN
    XPayLanguage.VI -> XPayEmbeddedLanguage.VI
}

private fun XPayEmbeddedPaymentStatus.toStatus(): XPayPaymentStatus = when (this) {
    XPayEmbeddedPaymentStatus.PAID -> XPayPaymentStatus.PAID
    XPayEmbeddedPaymentStatus.RETRY_IN_PARTNER -> XPayPaymentStatus.RETRY_IN_PARTNER
    XPayEmbeddedPaymentStatus.OTHER_METHOD -> XPayPaymentStatus.OTHER_METHOD
    XPayEmbeddedPaymentStatus.CS_PENDING -> XPayPaymentStatus.CS_PENDING
    XPayEmbeddedPaymentStatus.RIDE_CLOSED -> XPayPaymentStatus.RIDE_CLOSED
    XPayEmbeddedPaymentStatus.CANCELLED -> XPayPaymentStatus.CANCELLED
    XPayEmbeddedPaymentStatus.UNAVAILABLE -> XPayPaymentStatus.UNAVAILABLE
}

private fun XPayEmbeddedFailureMessage.toFailure(): XPayPaymentFailure = XPayPaymentFailure(reason = reason.toReason(), authId = authId, errorCode = errorCode, note = note)

private fun XPayEmbeddedFailureReason.toReason(): XPayFailureReason = when (this) {
    XPayEmbeddedFailureReason.PAYMENT_DECLINED -> XPayFailureReason.PAYMENT_DECLINED
    XPayEmbeddedFailureReason.SDK_ERROR -> XPayFailureReason.SDK_ERROR
    XPayEmbeddedFailureReason.OTHER -> XPayFailureReason.OTHER
}

private fun XPayEmbeddedPaidBy.toPaidBy(): XPayPaidBy = when (this) {
    XPayEmbeddedPaidBy.PARTNER -> XPayPaidBy.PARTNER
    XPayEmbeddedPaidBy.CS -> XPayPaidBy.CS
}

private fun XPayEmbeddedRideStatus.toRideStatus(): XPayRideStatus = when (this) {
    XPayEmbeddedRideStatus.COMPLETED -> XPayRideStatus.COMPLETED
    XPayEmbeddedRideStatus.CANCELLED -> XPayRideStatus.CANCELLED
}

private fun XPayEmbeddedLogCategory.toCategory(): XPayLogCategory = when (this) {
    XPayEmbeddedLogCategory.API -> XPayLogCategory.API
    XPayEmbeddedLogCategory.BEHAVIOR -> XPayLogCategory.BEHAVIOR
    XPayEmbeddedLogCategory.ERROR -> XPayLogCategory.ERROR
}

private fun XPayEmbeddedLogLevel.toLevel(): XPayLogLevel = when (this) {
    XPayEmbeddedLogLevel.INFO -> XPayLogLevel.INFO
    XPayEmbeddedLogLevel.WARN -> XPayLogLevel.WARN
    XPayEmbeddedLogLevel.ERROR -> XPayLogLevel.ERROR
}
