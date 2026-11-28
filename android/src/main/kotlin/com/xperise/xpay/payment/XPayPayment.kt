package com.xperise.xpay.payment

import android.content.Context
import android.os.Looper
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

object XPayPayment {
    const val SUPPORT_HOTLINE = "19002189"

    internal const val ENGINE_ID = "com.xperise.xpay.payment.engine"

    private const val ENTRYPOINT_FUNCTION = "xpayEmbeddedMain"
    private const val ENTRYPOINT_LIBRARY = "package:xpay_payment_sdk/xpay_payment_embedded.dart"

    internal var config: XPayConfig? = null
        private set

    internal var activeFetchSession: (suspend () -> String)? = null

    private var flutterApi: XPayEmbeddedFlutterApi? = null

    internal val isEngineCreated: Boolean
        get() = flutterApi != null

    suspend fun initialize(context: Context, config: XPayConfig) {
        check(Looper.myLooper() == Looper.getMainLooper()) { "XPayPayment.initialize must be called on the main thread." }

        val flutterApi = flutterApi ?: createEngine(context.applicationContext)
        suspendCoroutine<Unit> { continuation ->
            flutterApi.initialize(config.toMessage()) { result ->
                result.fold(
                    onSuccess = { continuation.resume(Unit) },
                    onFailure = { error -> continuation.resumeWithException(IllegalStateException(error.message, error)) },
                )
            }
        }
        this.config = config
    }

    internal fun startPayment(checkout: XPayCheckout, callback: (XPayPaymentResult) -> Unit) {
        val flutterApi = flutterApi ?: return callback(XPayPaymentResult.unavailable(XPayErrorCode.NOT_INITIALIZED))
        activeFetchSession = checkout.fetchSession
        flutterApi.start(checkout.toMessage()) { result ->
            activeFetchSession = null
            val paymentResult = result.fold(
                onSuccess = { message -> message.toResult() },
                onFailure = { XPayPaymentResult.unavailable(XPayErrorCode.UNEXPECTED_RESPONSE) },
            )
            callback(paymentResult)
        }
    }

    internal fun cancelPayment() {
        flutterApi?.cancel { }
    }

    private fun createEngine(context: Context): XPayEmbeddedFlutterApi {
        val engine = FlutterEngine(context)
        val messenger = engine.dartExecutor.binaryMessenger
        XPayEmbeddedHostApi.setUp(messenger, XPayEmbeddedHostApiHandler)

        val bundlePath = FlutterInjector.instance().flutterLoader().findAppBundlePath()
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint(bundlePath, ENTRYPOINT_LIBRARY, ENTRYPOINT_FUNCTION))
        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
        return XPayEmbeddedFlutterApi(messenger).also { flutterApi = it }
    }
}
