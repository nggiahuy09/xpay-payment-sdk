package com.xperise.xpay.payment

import java.util.Date

data class XPayPaymentResult(
    val status: XPayPaymentStatus,
    val authId: String? = null,
    val bookingRef: String? = null,
    val captureId: String? = null,
    val currency: String? = null,
    val declineCode: String? = null,
    val errorCode: String? = null,
    val externalRef: String? = null,
    val message: String? = null,
    val amount: Long? = null,
    val createdAt: Date? = null,
    val failureCategory: XPayFailureCategory? = null,
) {
    val isSuccessful: Boolean
        get() = status == XPayPaymentStatus.APPROVED || status == XPayPaymentStatus.CAPTURED
}

object XPayErrorCode {
    const val BUSY = "sdk_busy"
    const val INVALID_REQUEST = "sdk_invalid_request"
    const val NOT_INITIALIZED = "sdk_not_initialized"
    const val RESULT_LOST = "sdk_result_lost"
    const val UNEXPECTED_RESPONSE = "sdk_unexpected_response"
}

enum class XPayPaymentStatus { APPROVED, CAPTURED, DECLINED, CANCELLED, DUPLICATE, FAILED, EXPIRED, UNSUPPORTED }

enum class XPayFailureCategory { SYSTEM, NETWORK, CARDHOLDER_RETRY, CARDHOLDER_CHANGE, CORPORATE_POLICY, SESSION, UNKNOWN }
