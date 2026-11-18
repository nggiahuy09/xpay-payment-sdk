package com.xperise.xpay.payment

data class XPayLogEvent(
    val input: Map<String, Any?>,
    val category: XPayLogCategory,
    val level: XPayLogLevel,
    val action: String,
    val errorCode: String?,
    val feature: String,
    val reason: String?,
    val serverMessage: String?,
)

enum class XPayLogCategory { API, BEHAVIOR, ERROR }

enum class XPayLogLevel { INFO, WARN, ERROR }
