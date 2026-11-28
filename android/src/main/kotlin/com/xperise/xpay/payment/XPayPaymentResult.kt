package com.xperise.xpay.payment

import java.util.Date

data class XPayPaymentResult(
    val status: XPayPaymentStatus,
    val failure: XPayPaymentFailure? = null,
    val paidBy: XPayPaidBy? = null,
    val rideStatus: XPayRideStatus? = null,
    val authId: String? = null,
    val captureId: String? = null,
    val currency: String? = null,
    val errorCode: String? = null,
    val externalRef: String? = null,
    val pendingAuthId: String? = null,
    val amount: Long? = null,
    val createdAt: Date? = null,
) {
    val isSuccessful: Boolean
        get() = status == XPayPaymentStatus.PAID

    val isRetryable: Boolean
        get() = status.isRetryable

    companion object {
        internal fun unavailable(errorCode: String): XPayPaymentResult = XPayPaymentResult(
            status = XPayPaymentStatus.UNAVAILABLE,
            failure = XPayPaymentFailure(XPayFailureReason.SDK_ERROR, errorCode = errorCode, note = errorCode),
            errorCode = errorCode,
        )
    }
}

data class XPayPaymentFailure(
    val reason: XPayFailureReason,
    val authId: String? = null,
    val errorCode: String? = null,
    val note: String? = null,
)

object XPayErrorCode {
    const val BUSY = "sdk_busy"
    const val INVALID_REQUEST = "sdk_invalid_request"
    const val NOT_INITIALIZED = "sdk_not_initialized"
    const val RESULT_LOST = "sdk_result_lost"
    const val SESSION_AMOUNT_CHANGED = "sdk_session_amount_changed"
    const val UNEXPECTED_RESPONSE = "sdk_unexpected_response"
    const val UNSUPPORTED = "sdk_unsupported"
}

enum class XPayPaymentStatus(val isRetryable: Boolean) {
    PAID(false),
    RETRY_IN_PARTNER(true),
    OTHER_METHOD(false),
    CS_PENDING(false),
    RIDE_CLOSED(false),
    CANCELLED(true),
    UNAVAILABLE(false),
}

enum class XPayFailureReason(val remoteValue: String) {
    PAYMENT_DECLINED("payment_declined"),
    SDK_ERROR("sdk_error"),
    OTHER("other"),
}

enum class XPayPaidBy { PARTNER, CS }

enum class XPayRideStatus { COMPLETED, CANCELLED }
