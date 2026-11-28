package com.xperise.xpay.payment

import android.os.Handler
import android.os.Looper
import kotlin.coroutines.Continuation
import kotlin.coroutines.EmptyCoroutineContext
import kotlin.coroutines.startCoroutine

internal object XPayEmbeddedHostApiHandler : XPayEmbeddedHostApi {
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onLog(event: XPayEmbeddedLogMessage) {
        XPayPayment.config?.onLog?.invoke(event.toLogEvent())
    }

    override fun fetchSession(callback: (Result<String>) -> Unit) {
        val fetchSession = XPayPayment.activeFetchSession ?: return callback(Result.failure(IllegalStateException("No fetchSession was given for the open payment.")))
        fetchSession.startCoroutine(Continuation(EmptyCoroutineContext) { result -> mainHandler.post { callback(result) } })
    }
}
