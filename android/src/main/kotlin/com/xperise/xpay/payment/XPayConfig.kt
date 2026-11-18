package com.xperise.xpay.payment

data class XPayConfig(
    val environment: XPayEnvironment,
    val language: XPayLanguage = XPayLanguage.VI,
    val onLog: ((XPayLogEvent) -> Unit)? = null,
)

data class XPayEnvironment(val baseUrl: String)

enum class XPayLanguage { EN, VI }
