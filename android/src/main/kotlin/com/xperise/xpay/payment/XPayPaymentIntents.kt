package com.xperise.xpay.payment

import android.content.Intent
import java.util.Date

internal object XPayPaymentIntents {
    private const val KEY_AMOUNT = "com.xperise.xpay.payment.amount"
    private const val KEY_AUTH_ID = "com.xperise.xpay.payment.auth_id"
    private const val KEY_CAN_FETCH_SESSION = "com.xperise.xpay.payment.can_fetch_session"
    private const val KEY_CAPTURE_ID = "com.xperise.xpay.payment.capture_id"
    private const val KEY_CREATED_AT = "com.xperise.xpay.payment.created_at"
    private const val KEY_CURRENCY = "com.xperise.xpay.payment.currency"
    private const val KEY_ERROR_CODE = "com.xperise.xpay.payment.error_code"
    private const val KEY_EXTERNAL_REF = "com.xperise.xpay.payment.external_ref"
    private const val KEY_FAILURE_AUTH_ID = "com.xperise.xpay.payment.failure_auth_id"
    private const val KEY_FAILURE_ERROR_CODE = "com.xperise.xpay.payment.failure_error_code"
    private const val KEY_FAILURE_NOTE = "com.xperise.xpay.payment.failure_note"
    private const val KEY_FAILURE_REASON = "com.xperise.xpay.payment.failure_reason"
    private const val KEY_PAID_BY = "com.xperise.xpay.payment.paid_by"
    private const val KEY_PENDING_AUTH_ID = "com.xperise.xpay.payment.pending_auth_id"
    private const val KEY_RIDE_STATUS = "com.xperise.xpay.payment.ride_status"
    private const val KEY_SESSION_JSON = "com.xperise.xpay.payment.session_json"
    private const val KEY_STATUS = "com.xperise.xpay.payment.status"

    fun writeCheckout(intent: Intent, checkout: XPayCheckout): Intent = intent.apply {
        XPayPayment.activeFetchSession = checkout.fetchSession
        putExtra(KEY_SESSION_JSON, checkout.sessionJson)
        putExtra(KEY_CAN_FETCH_SESSION, checkout.fetchSession != null)
    }

    fun readCheckout(intent: Intent): XPayCheckout? {
        val sessionJson = intent.getStringExtra(KEY_SESSION_JSON) ?: return null
        val fetchSession = XPayPayment.activeFetchSession.takeIf { intent.getBooleanExtra(KEY_CAN_FETCH_SESSION, false) }
        return XPayCheckout(sessionJson = sessionJson, fetchSession = fetchSession)
    }

    fun writeResult(result: XPayPaymentResult): Intent = Intent().apply {
        putExtra(KEY_STATUS, result.status.name)
        result.failure?.let { failure ->
            putExtra(KEY_FAILURE_REASON, failure.reason.name)
            putExtra(KEY_FAILURE_AUTH_ID, failure.authId)
            putExtra(KEY_FAILURE_ERROR_CODE, failure.errorCode)
            putExtra(KEY_FAILURE_NOTE, failure.note)
        }
        result.paidBy?.let { putExtra(KEY_PAID_BY, it.name) }
        result.rideStatus?.let { putExtra(KEY_RIDE_STATUS, it.name) }
        putExtra(KEY_AUTH_ID, result.authId)
        putExtra(KEY_CAPTURE_ID, result.captureId)
        putExtra(KEY_CURRENCY, result.currency)
        putExtra(KEY_ERROR_CODE, result.errorCode)
        putExtra(KEY_EXTERNAL_REF, result.externalRef)
        putExtra(KEY_PENDING_AUTH_ID, result.pendingAuthId)
        result.amount?.let { putExtra(KEY_AMOUNT, it) }
        result.createdAt?.let { putExtra(KEY_CREATED_AT, it.time) }
    }

    fun readResult(intent: Intent): XPayPaymentResult? {
        val status = XPayPaymentStatus.entries.firstOrNull { it.name == intent.getStringExtra(KEY_STATUS) } ?: return null
        val failure = XPayFailureReason.entries.firstOrNull { it.name == intent.getStringExtra(KEY_FAILURE_REASON) }?.let { reason ->
            XPayPaymentFailure(
                reason = reason,
                authId = intent.getStringExtra(KEY_FAILURE_AUTH_ID),
                errorCode = intent.getStringExtra(KEY_FAILURE_ERROR_CODE),
                note = intent.getStringExtra(KEY_FAILURE_NOTE),
            )
        }
        return XPayPaymentResult(
            status = status,
            failure = failure,
            paidBy = XPayPaidBy.entries.firstOrNull { it.name == intent.getStringExtra(KEY_PAID_BY) },
            rideStatus = XPayRideStatus.entries.firstOrNull { it.name == intent.getStringExtra(KEY_RIDE_STATUS) },
            authId = intent.getStringExtra(KEY_AUTH_ID),
            captureId = intent.getStringExtra(KEY_CAPTURE_ID),
            currency = intent.getStringExtra(KEY_CURRENCY),
            errorCode = intent.getStringExtra(KEY_ERROR_CODE),
            externalRef = intent.getStringExtra(KEY_EXTERNAL_REF),
            pendingAuthId = intent.getStringExtra(KEY_PENDING_AUTH_ID),
            amount = if (intent.hasExtra(KEY_AMOUNT)) intent.getLongExtra(KEY_AMOUNT, 0L) else null,
            createdAt = if (intent.hasExtra(KEY_CREATED_AT)) Date(intent.getLongExtra(KEY_CREATED_AT, 0L)) else null,
        )
    }
}
