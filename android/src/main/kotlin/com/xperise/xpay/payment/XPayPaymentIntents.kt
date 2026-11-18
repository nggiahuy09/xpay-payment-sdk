package com.xperise.xpay.payment

import android.content.Intent
import java.util.Date

internal object XPayPaymentIntents {
    private const val KEY_AMOUNT = "com.xperise.xpay.payment.amount"
    private const val KEY_AUTH_ID = "com.xperise.xpay.payment.auth_id"
    private const val KEY_BOOKING_REF = "com.xperise.xpay.payment.booking_ref"
    private const val KEY_CAPTURE_ID = "com.xperise.xpay.payment.capture_id"
    private const val KEY_CREATED_AT = "com.xperise.xpay.payment.created_at"
    private const val KEY_CURRENCY = "com.xperise.xpay.payment.currency"
    private const val KEY_DECLINE_CODE = "com.xperise.xpay.payment.decline_code"
    private const val KEY_ERROR_CODE = "com.xperise.xpay.payment.error_code"
    private const val KEY_EXTERNAL_REF = "com.xperise.xpay.payment.external_ref"
    private const val KEY_MESSAGE = "com.xperise.xpay.payment.message"
    private const val KEY_SESSION_JSON = "com.xperise.xpay.payment.session_json"
    private const val KEY_STATUS = "com.xperise.xpay.payment.status"

    fun writeCheckout(intent: Intent, checkout: XPayCheckout): Intent = intent.apply {
        putExtra(KEY_SESSION_JSON, checkout.sessionJson)
    }

    fun readCheckout(intent: Intent): XPayCheckout? {
        val sessionJson = intent.getStringExtra(KEY_SESSION_JSON) ?: return null
        return XPayCheckout(sessionJson = sessionJson)
    }

    fun writeResult(result: XPayPaymentResult): Intent = Intent().apply {
        putExtra(KEY_STATUS, result.status.name)
        putExtra(KEY_AUTH_ID, result.authId)
        putExtra(KEY_BOOKING_REF, result.bookingRef)
        putExtra(KEY_CAPTURE_ID, result.captureId)
        putExtra(KEY_CURRENCY, result.currency)
        putExtra(KEY_DECLINE_CODE, result.declineCode)
        putExtra(KEY_ERROR_CODE, result.errorCode)
        putExtra(KEY_EXTERNAL_REF, result.externalRef)
        putExtra(KEY_MESSAGE, result.message)
        result.amount?.let { putExtra(KEY_AMOUNT, it) }
        result.createdAt?.let { putExtra(KEY_CREATED_AT, it.time) }
    }

    fun readResult(intent: Intent): XPayPaymentResult? {
        val statusName = intent.getStringExtra(KEY_STATUS)
        val status = XPayPaymentStatus.entries.firstOrNull { it.name == statusName } ?: return null
        return XPayPaymentResult(
            status = status,
            authId = intent.getStringExtra(KEY_AUTH_ID),
            bookingRef = intent.getStringExtra(KEY_BOOKING_REF),
            captureId = intent.getStringExtra(KEY_CAPTURE_ID),
            currency = intent.getStringExtra(KEY_CURRENCY),
            declineCode = intent.getStringExtra(KEY_DECLINE_CODE),
            errorCode = intent.getStringExtra(KEY_ERROR_CODE),
            externalRef = intent.getStringExtra(KEY_EXTERNAL_REF),
            message = intent.getStringExtra(KEY_MESSAGE),
            amount = if (intent.hasExtra(KEY_AMOUNT)) intent.getLongExtra(KEY_AMOUNT, 0L) else null,
            createdAt = if (intent.hasExtra(KEY_CREATED_AT)) Date(intent.getLongExtra(KEY_CREATED_AT, 0L)) else null,
        )
    }
}
