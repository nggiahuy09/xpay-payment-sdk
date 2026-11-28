package com.xperise.xpay.payment

data class XPayCheckout(
    val sessionJson: String,
    val fetchSession: (suspend () -> String)? = null,
) {
    override fun toString(): String = "XPayCheckout(sessionJson=***, fetchSession=${if (fetchSession == null) "null" else "set"})"
}
