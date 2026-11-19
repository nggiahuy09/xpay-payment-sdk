// Channel layer for pigeons/xpay_embedded_api.dart (Pigeon v30.0.2 wire format), do not edit directly.
// Written to match XPayEmbeddedApi.g.kt: same channel names, codec type ids and field order.
// Running `dart run pigeon --input pigeons/xpay_embedded_api.dart` replaces this file with Pigeon's own output.

import Flutter
import Foundation

final class XPayEmbeddedError: Error {
  let code: String
  let message: String?
  let details: Any?

  init(code: String, message: String?, details: Any?) {
    self.code = code
    self.message = message
    self.details = details
  }

  var localizedDescription: String {
    return "XPayEmbeddedError(code: \(code), message: \(message ?? "<nil>"), details: \(details ?? "<nil>")"
  }
}

private func xpayEmbeddedCreateConnectionError(withChannelName channelName: String) -> XPayEmbeddedError {
  return XPayEmbeddedError(code: "channel-error", message: "Unable to establish connection on channel: '\(channelName)'.", details: "")
}

private func xpayEmbeddedWrapError(_ error: Any) -> [Any?] {
  if let embeddedError = error as? XPayEmbeddedError {
    return [embeddedError.code, embeddedError.message, embeddedError.details]
  }
  if let flutterError = error as? FlutterError {
    return [flutterError.code, flutterError.message, flutterError.details]
  }
  return ["\(type(of: error))", "\(error)", "Stacktrace: \(Thread.callStackSymbols)"]
}

private func xpayEmbeddedIsNullish(_ value: Any?) -> Bool {
  return value is NSNull || value == nil
}

private func xpayEmbeddedNilOrValue<T>(_ value: Any?) -> T? {
  if value is NSNull { return nil }
  return value as! T?
}

enum XPayEmbeddedLanguage: Int {
  case en = 0
  case vi = 1
}

enum XPayEmbeddedLogCategory: Int {
  case api = 0
  case behavior = 1
  case error = 2
}

enum XPayEmbeddedLogLevel: Int {
  case info = 0
  case warn = 1
  case error = 2
}

enum XPayEmbeddedPaymentStatus: Int {
  case approved = 0
  case captured = 1
  case declined = 2
  case cancelled = 3
  case duplicate = 4
  case failed = 5
  case expired = 6
  case unsupported = 7
}

struct XPayEmbeddedConfigMessage {
  var language: XPayEmbeddedLanguage
  var baseUrl: String

  static func fromList(_ pigeonVar_list: [Any?]) -> XPayEmbeddedConfigMessage? {
    let language = pigeonVar_list[0] as! XPayEmbeddedLanguage
    let baseUrl = pigeonVar_list[1] as! String
    return XPayEmbeddedConfigMessage(language: language, baseUrl: baseUrl)
  }

  func toList() -> [Any?] {
    return [language, baseUrl]
  }
}

struct XPayEmbeddedRequestMessage {
  var sessionJson: String

  static func fromList(_ pigeonVar_list: [Any?]) -> XPayEmbeddedRequestMessage? {
    let sessionJson = pigeonVar_list[0] as! String
    return XPayEmbeddedRequestMessage(sessionJson: sessionJson)
  }

  func toList() -> [Any?] {
    return [sessionJson]
  }
}

struct XPayEmbeddedResultMessage {
  var status: XPayEmbeddedPaymentStatus
  var authId: String? = nil
  var bookingRef: String? = nil
  var captureId: String? = nil
  var currency: String? = nil
  var declineCode: String? = nil
  var errorCode: String? = nil
  var externalRef: String? = nil
  var message: String? = nil
  var amount: Int64? = nil
  var createdAtEpochMillis: Int64? = nil

  static func fromList(_ pigeonVar_list: [Any?]) -> XPayEmbeddedResultMessage? {
    let status = pigeonVar_list[0] as! XPayEmbeddedPaymentStatus
    let authId: String? = xpayEmbeddedNilOrValue(pigeonVar_list[1])
    let bookingRef: String? = xpayEmbeddedNilOrValue(pigeonVar_list[2])
    let captureId: String? = xpayEmbeddedNilOrValue(pigeonVar_list[3])
    let currency: String? = xpayEmbeddedNilOrValue(pigeonVar_list[4])
    let declineCode: String? = xpayEmbeddedNilOrValue(pigeonVar_list[5])
    let errorCode: String? = xpayEmbeddedNilOrValue(pigeonVar_list[6])
    let externalRef: String? = xpayEmbeddedNilOrValue(pigeonVar_list[7])
    let message: String? = xpayEmbeddedNilOrValue(pigeonVar_list[8])
    let amount: Int64? = xpayEmbeddedNilOrValue(pigeonVar_list[9])
    let createdAtEpochMillis: Int64? = xpayEmbeddedNilOrValue(pigeonVar_list[10])

    return XPayEmbeddedResultMessage(
      status: status,
      authId: authId,
      bookingRef: bookingRef,
      captureId: captureId,
      currency: currency,
      declineCode: declineCode,
      errorCode: errorCode,
      externalRef: externalRef,
      message: message,
      amount: amount,
      createdAtEpochMillis: createdAtEpochMillis
    )
  }

  func toList() -> [Any?] {
    return [status, authId, bookingRef, captureId, currency, declineCode, errorCode, externalRef, message, amount, createdAtEpochMillis]
  }
}

struct XPayEmbeddedLogMessage {
  var input: [String: Any?]
  var category: XPayEmbeddedLogCategory
  var level: XPayEmbeddedLogLevel
  var action: String
  var errorCode: String? = nil
  var feature: String
  var reason: String? = nil
  var serverMessage: String? = nil

  static func fromList(_ pigeonVar_list: [Any?]) -> XPayEmbeddedLogMessage? {
    let input = pigeonVar_list[0] as! [String: Any?]
    let category = pigeonVar_list[1] as! XPayEmbeddedLogCategory
    let level = pigeonVar_list[2] as! XPayEmbeddedLogLevel
    let action = pigeonVar_list[3] as! String
    let errorCode: String? = xpayEmbeddedNilOrValue(pigeonVar_list[4])
    let feature = pigeonVar_list[5] as! String
    let reason: String? = xpayEmbeddedNilOrValue(pigeonVar_list[6])
    let serverMessage: String? = xpayEmbeddedNilOrValue(pigeonVar_list[7])

    return XPayEmbeddedLogMessage(
      input: input,
      category: category,
      level: level,
      action: action,
      errorCode: errorCode,
      feature: feature,
      reason: reason,
      serverMessage: serverMessage
    )
  }

  func toList() -> [Any?] {
    return [input, category, level, action, errorCode, feature, reason, serverMessage]
  }
}

private class XPayEmbeddedApiPigeonCodecReader: FlutterStandardReader {
  override func readValue(ofType type: UInt8) -> Any? {
    switch type {
    case 129:
      let enumResultAsInt: Int? = xpayEmbeddedNilOrValue(self.readValue() as! Int?)
      if let enumResultAsInt = enumResultAsInt {
        return XPayEmbeddedLanguage(rawValue: enumResultAsInt)
      }
      return nil
    case 130:
      let enumResultAsInt: Int? = xpayEmbeddedNilOrValue(self.readValue() as! Int?)
      if let enumResultAsInt = enumResultAsInt {
        return XPayEmbeddedLogCategory(rawValue: enumResultAsInt)
      }
      return nil
    case 131:
      let enumResultAsInt: Int? = xpayEmbeddedNilOrValue(self.readValue() as! Int?)
      if let enumResultAsInt = enumResultAsInt {
        return XPayEmbeddedLogLevel(rawValue: enumResultAsInt)
      }
      return nil
    case 132:
      let enumResultAsInt: Int? = xpayEmbeddedNilOrValue(self.readValue() as! Int?)
      if let enumResultAsInt = enumResultAsInt {
        return XPayEmbeddedPaymentStatus(rawValue: enumResultAsInt)
      }
      return nil
    case 133:
      return XPayEmbeddedConfigMessage.fromList(self.readValue() as! [Any?])
    case 134:
      return XPayEmbeddedRequestMessage.fromList(self.readValue() as! [Any?])
    case 135:
      return XPayEmbeddedResultMessage.fromList(self.readValue() as! [Any?])
    case 136:
      return XPayEmbeddedLogMessage.fromList(self.readValue() as! [Any?])
    default:
      return super.readValue(ofType: type)
    }
  }
}

private class XPayEmbeddedApiPigeonCodecWriter: FlutterStandardWriter {
  override func writeValue(_ value: Any) {
    if let value = value as? XPayEmbeddedLanguage {
      super.writeByte(129)
      super.writeValue(value.rawValue)
    } else if let value = value as? XPayEmbeddedLogCategory {
      super.writeByte(130)
      super.writeValue(value.rawValue)
    } else if let value = value as? XPayEmbeddedLogLevel {
      super.writeByte(131)
      super.writeValue(value.rawValue)
    } else if let value = value as? XPayEmbeddedPaymentStatus {
      super.writeByte(132)
      super.writeValue(value.rawValue)
    } else if let value = value as? XPayEmbeddedConfigMessage {
      super.writeByte(133)
      super.writeValue(value.toList())
    } else if let value = value as? XPayEmbeddedRequestMessage {
      super.writeByte(134)
      super.writeValue(value.toList())
    } else if let value = value as? XPayEmbeddedResultMessage {
      super.writeByte(135)
      super.writeValue(value.toList())
    } else if let value = value as? XPayEmbeddedLogMessage {
      super.writeByte(136)
      super.writeValue(value.toList())
    } else {
      super.writeValue(value)
    }
  }
}

private class XPayEmbeddedApiPigeonCodecReaderWriter: FlutterStandardReaderWriter {
  override func reader(with data: Data) -> FlutterStandardReader {
    return XPayEmbeddedApiPigeonCodecReader(data: data)
  }

  override func writer(with data: NSMutableData) -> FlutterStandardWriter {
    return XPayEmbeddedApiPigeonCodecWriter(data: data)
  }
}

class XPayEmbeddedApiPigeonCodec: FlutterStandardMessageCodec, @unchecked Sendable {
  static let shared = XPayEmbeddedApiPigeonCodec(readerWriter: XPayEmbeddedApiPigeonCodecReaderWriter())
}

/// Messages Swift sends to the Dart side of the embedded SDK.
protocol XPayEmbeddedFlutterApiProtocol {
  func initialize(config configArg: XPayEmbeddedConfigMessage, completion: @escaping (Result<Void, XPayEmbeddedError>) -> Void)
  func start(request requestArg: XPayEmbeddedRequestMessage, completion: @escaping (Result<XPayEmbeddedResultMessage, XPayEmbeddedError>) -> Void)
  func cancel(completion: @escaping (Result<Void, XPayEmbeddedError>) -> Void)
}

class XPayEmbeddedFlutterApi: XPayEmbeddedFlutterApiProtocol {
  private let binaryMessenger: FlutterBinaryMessenger
  private let messageChannelSuffix: String

  init(binaryMessenger: FlutterBinaryMessenger, messageChannelSuffix: String = "") {
    self.binaryMessenger = binaryMessenger
    self.messageChannelSuffix = messageChannelSuffix.count > 0 ? ".\(messageChannelSuffix)" : ""
  }

  var codec: XPayEmbeddedApiPigeonCodec {
    return XPayEmbeddedApiPigeonCodec.shared
  }

  func initialize(config configArg: XPayEmbeddedConfigMessage, completion: @escaping (Result<Void, XPayEmbeddedError>) -> Void) {
    let channelName = "dev.flutter.pigeon.xpay_payment_sdk.XPayEmbeddedFlutterApi.initialize\(messageChannelSuffix)"
    let channel = FlutterBasicMessageChannel(name: channelName, binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([configArg] as [Any?]) { response in
      guard let listResponse = response as? [Any?] else {
        completion(.failure(xpayEmbeddedCreateConnectionError(withChannelName: channelName)))
        return
      }
      if listResponse.count > 1 {
        let code: String = listResponse[0] as! String
        let message: String? = xpayEmbeddedNilOrValue(listResponse[1])
        let details: String? = xpayEmbeddedNilOrValue(listResponse[2])
        completion(.failure(XPayEmbeddedError(code: code, message: message, details: details)))
      } else {
        completion(.success(()))
      }
    }
  }

  func start(request requestArg: XPayEmbeddedRequestMessage, completion: @escaping (Result<XPayEmbeddedResultMessage, XPayEmbeddedError>) -> Void) {
    let channelName = "dev.flutter.pigeon.xpay_payment_sdk.XPayEmbeddedFlutterApi.start\(messageChannelSuffix)"
    let channel = FlutterBasicMessageChannel(name: channelName, binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage([requestArg] as [Any?]) { response in
      guard let listResponse = response as? [Any?] else {
        completion(.failure(xpayEmbeddedCreateConnectionError(withChannelName: channelName)))
        return
      }
      if listResponse.count > 1 {
        let code: String = listResponse[0] as! String
        let message: String? = xpayEmbeddedNilOrValue(listResponse[1])
        let details: String? = xpayEmbeddedNilOrValue(listResponse[2])
        completion(.failure(XPayEmbeddedError(code: code, message: message, details: details)))
      } else if listResponse[0] == nil || xpayEmbeddedIsNullish(listResponse[0]) {
        completion(.failure(XPayEmbeddedError(code: "null-error", message: "Flutter api returned null value for non-null return value.", details: "")))
      } else {
        let result = listResponse[0] as! XPayEmbeddedResultMessage
        completion(.success(result))
      }
    }
  }

  func cancel(completion: @escaping (Result<Void, XPayEmbeddedError>) -> Void) {
    let channelName = "dev.flutter.pigeon.xpay_payment_sdk.XPayEmbeddedFlutterApi.cancel\(messageChannelSuffix)"
    let channel = FlutterBasicMessageChannel(name: channelName, binaryMessenger: binaryMessenger, codec: codec)
    channel.sendMessage(nil) { response in
      guard let listResponse = response as? [Any?] else {
        completion(.failure(xpayEmbeddedCreateConnectionError(withChannelName: channelName)))
        return
      }
      if listResponse.count > 1 {
        let code: String = listResponse[0] as! String
        let message: String? = xpayEmbeddedNilOrValue(listResponse[1])
        let details: String? = xpayEmbeddedNilOrValue(listResponse[2])
        completion(.failure(XPayEmbeddedError(code: code, message: message, details: details)))
      } else {
        completion(.success(()))
      }
    }
  }
}

/// Messages the Dart side of the embedded SDK sends to Swift.
protocol XPayEmbeddedHostApi {
  func onLog(event: XPayEmbeddedLogMessage) throws
}

class XPayEmbeddedHostApiSetup {
  static var codec: FlutterStandardMessageCodec { XPayEmbeddedApiPigeonCodec.shared }

  /// Sets up an instance of `XPayEmbeddedHostApi` to handle messages through the `binaryMessenger`.
  static func setUp(binaryMessenger: FlutterBinaryMessenger, api: XPayEmbeddedHostApi?, messageChannelSuffix: String = "") {
    let channelSuffix = messageChannelSuffix.count > 0 ? ".\(messageChannelSuffix)" : ""
    let onLogChannel = FlutterBasicMessageChannel(
      name: "dev.flutter.pigeon.xpay_payment_sdk.XPayEmbeddedHostApi.onLog\(channelSuffix)",
      binaryMessenger: binaryMessenger,
      codec: codec
    )
    if let api = api {
      onLogChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let eventArg = args[0] as! XPayEmbeddedLogMessage
        do {
          try api.onLog(event: eventArg)
          reply(xpayEmbeddedWrapResult(nil))
        } catch {
          reply(xpayEmbeddedWrapError(error))
        }
      }
    } else {
      onLogChannel.setMessageHandler(nil)
    }
  }
}

private func xpayEmbeddedWrapResult(_ result: Any?) -> [Any?] {
  return [result]
}
