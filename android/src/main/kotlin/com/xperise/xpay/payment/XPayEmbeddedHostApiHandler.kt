package com.xperise.xpay.payment

internal object XPayEmbeddedHostApiHandler : XPayEmbeddedHostApi {
    override fun onLog(event: XPayEmbeddedLogMessage) {
        XPayPayment.config?.onLog?.invoke(event.toLogEvent())
    }
}
