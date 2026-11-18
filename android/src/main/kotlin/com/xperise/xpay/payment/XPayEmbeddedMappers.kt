package com.xperise.xpay.payment

import java.util.Date

internal fun XPayConfig.toMessage(): XPayEmbeddedConfigMessage = XPayEmbeddedConfigMessage(language = language.toMessage(), baseUrl = environment.baseUrl)

internal fun XPayCheckout.toMessage(): XPayEmbeddedRequestMessage = XPayEmbeddedRequestMessage(sessionJson = sessionJson)

internal fun XPayEmbeddedResultMessage.toResult(): XPayPaymentResult = XPayPaymentResult(
    status = status.toStatus(),
    authId = authId,
    bookingRef = bookingRef,
    captureId = captureId,
    currency = currency,
    declineCode = declineCode,
    errorCode = errorCode,
    externalRef = externalRef,
    message = message,
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
    XPayEmbeddedPaymentStatus.APPROVED -> XPayPaymentStatus.APPROVED
    XPayEmbeddedPaymentStatus.CAPTURED -> XPayPaymentStatus.CAPTURED
    XPayEmbeddedPaymentStatus.DECLINED -> XPayPaymentStatus.DECLINED
    XPayEmbeddedPaymentStatus.CANCELLED -> XPayPaymentStatus.CANCELLED
    XPayEmbeddedPaymentStatus.DUPLICATE -> XPayPaymentStatus.DUPLICATE
    XPayEmbeddedPaymentStatus.FAILED -> XPayPaymentStatus.FAILED
    XPayEmbeddedPaymentStatus.EXPIRED -> XPayPaymentStatus.EXPIRED
    XPayEmbeddedPaymentStatus.UNSUPPORTED -> XPayPaymentStatus.UNSUPPORTED
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
