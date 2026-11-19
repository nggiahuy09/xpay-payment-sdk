import Foundation

final class XPayEmbeddedHostApiHandler: XPayEmbeddedHostApi {
    func onLog(event: XPayEmbeddedLogMessage) throws {
        XPayPayment.config?.onLog?(event.toLogEvent())
    }
}
