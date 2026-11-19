import Foundation

/// A business event the SDK reports through `XPayConfig.onLog`.
public struct XPayLogEvent: CustomStringConvertible {
    public let input: [String: Any?]
    public let category: XPayLogCategory
    public let level: XPayLogLevel
    public let action: String
    public let errorCode: String?
    public let feature: String
    public let reason: String?
    public let serverMessage: String?

    public init(
        input: [String: Any?],
        category: XPayLogCategory,
        level: XPayLogLevel,
        action: String,
        errorCode: String?,
        feature: String,
        reason: String?,
        serverMessage: String?
    ) {
        self.input = input
        self.category = category
        self.level = level
        self.action = action
        self.errorCode = errorCode
        self.feature = feature
        self.reason = reason
        self.serverMessage = serverMessage
    }

    public var description: String {
        let inputDescription = input.keys.sorted().map { key in "\(key): \(input[key].flatMap { $0 }.map { "\($0)" } ?? "nil")" }.joined(separator: ", ")
        return "XPayLogEvent(level: \(level), category: \(category), feature: \(feature), action: \(action), reason: \(reason ?? "nil"), errorCode: \(errorCode ?? "nil"), serverMessage: \(serverMessage ?? "nil"), input: [\(inputDescription)])"
    }
}

public enum XPayLogCategory: String {
    case api
    case behavior
    case error
}

public enum XPayLogLevel: String {
    case info
    case warn
    case error
}
