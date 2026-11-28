package com.xperise.xpay.payment

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.activity.result.contract.ActivityResultContract

class XPayPaymentContract : ActivityResultContract<XPayCheckout, XPayPaymentResult>() {
    override fun createIntent(context: Context, input: XPayCheckout): Intent = XPayPaymentActivity.createIntent(context, input)

    override fun getSynchronousResult(context: Context, input: XPayCheckout): ActivityResultContract.SynchronousResult<XPayPaymentResult>? {
        if (XPayPayment.isEngineCreated) return null
        return ActivityResultContract.SynchronousResult(XPayPaymentResult.unavailable(XPayErrorCode.NOT_INITIALIZED))
    }

    override fun parseResult(resultCode: Int, intent: Intent?): XPayPaymentResult {
        val result = if (resultCode == Activity.RESULT_OK && intent != null) XPayPaymentIntents.readResult(intent) else null
        return result ?: XPayPaymentResult(XPayPaymentStatus.CANCELLED)
    }
}
