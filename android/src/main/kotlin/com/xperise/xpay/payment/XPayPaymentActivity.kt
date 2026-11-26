package com.xperise.xpay.payment

import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngineCache

internal class XPayPaymentActivity : FlutterActivity() {
    private var isResultDelivered = false

    override fun getCachedEngineId(): String? = super.getCachedEngineId()?.takeIf { FlutterEngineCache.getInstance().contains(it) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        activeActivity = this

        if (getCachedEngineId() == null) return deliver(XPayPaymentResult(XPayPaymentStatus.FAILED, errorCode = XPayErrorCode.RESULT_LOST, failureCategory = XPayFailureCategory.SESSION))

        if (savedInstanceState != null) {
            pendingResult?.let { result ->
                pendingResult = null
                deliver(result)
            }
            return
        }

        pendingResult = null
        val checkout = XPayPaymentIntents.readCheckout(intent) ?: return deliver(XPayPaymentResult(XPayPaymentStatus.FAILED, errorCode = XPayErrorCode.INVALID_REQUEST, failureCategory = XPayFailureCategory.SESSION))
        XPayPayment.startPayment(checkout) { result -> finishPayment(result) }
    }

    override fun onDestroy() {
        if (activeActivity === this) activeActivity = null
        if (isFinishing && !isResultDelivered) XPayPayment.cancelPayment()
        super.onDestroy()
    }

    private fun deliver(result: XPayPaymentResult) {
        if (isResultDelivered || isFinishing || isDestroyed) return

        isResultDelivered = true
        setResult(RESULT_OK, XPayPaymentIntents.writeResult(result))
        finish()
    }

    companion object {
        private var activeActivity: XPayPaymentActivity? = null
        private var pendingResult: XPayPaymentResult? = null

        fun createIntent(context: Context, checkout: XPayCheckout): Intent {
            val intent = FlutterActivity.CachedEngineIntentBuilder(XPayPaymentActivity::class.java, XPayPayment.ENGINE_ID).build(context)
            return XPayPaymentIntents.writeCheckout(intent, checkout)
        }

        private fun finishPayment(result: XPayPaymentResult) {
            val activity = activeActivity
            if (activity == null) {
                pendingResult = result
                return
            }
            activity.deliver(result)
        }
    }
}
