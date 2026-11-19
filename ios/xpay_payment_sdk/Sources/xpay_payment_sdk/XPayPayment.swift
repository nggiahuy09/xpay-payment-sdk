import Flutter
import UIKit

/// The single entry point of the XPay payment SDK for native iOS hosts.
///
/// 1. Call `initialize(config:)` once before the first payment.
/// 2. Call `start(from:checkout:)` for each payment; it always returns exactly one `XPayPaymentResult`.
public enum XPayPayment {
    static let engineName = "com.xperise.xpay.payment.engine"

    private static let entrypointFunction = "xpayEmbeddedMain"
    private static let entrypointLibrary = "package:xpay_payment_sdk/xpay_payment_embedded.dart"
    private static let pluginRegistrantClassName = "GeneratedPluginRegistrant"
    private static let pluginRegistrantSelectorName = "registerWithRegistry:"

    private(set) static var config: XPayConfig?

    private static let hostApiHandler = XPayEmbeddedHostApiHandler()
    private static var activeController: XPayPaymentViewController?
    private static var engine: FlutterEngine?
    private static var flutterApi: XPayEmbeddedFlutterApi?

    /// Configures the SDK: language, base URL and log callback. Call it again to change them.
    ///
    /// - Throws: `XPayInitializationError` while a payment is open, while a previous `initialize` is still running, or when the SDK engine cannot start.
    ///   The previous configuration stays in effect.
    @MainActor
    public static func initialize(config: XPayConfig) async throws {
        let flutterApi = try self.flutterApi ?? createEngine()
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            flutterApi.initialize(config: config.toMessage()) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: XPayInitializationError(message: error.message ?? error.code))
                }
            }
        }
        self.config = config
    }

    /// Presents the SDK screens full screen above `presenter` and returns once they are dismissed.
    ///
    /// Never throws: every failure is reported in the returned result. When the SDK is not initialized, another payment is open,
    /// or `presenter` is not in a window, the result is `failed` and nothing is presented.
    @MainActor
    public static func start(from presenter: UIViewController, checkout: XPayCheckout) async -> XPayPaymentResult {
        guard config != nil, let engine = engine, let flutterApi = flutterApi else {
            return XPayPaymentResult(status: .failed, errorCode: XPayErrorCode.notInitialized)
        }
        guard activeController == nil else {
            return XPayPaymentResult(status: .failed, errorCode: XPayErrorCode.busy)
        }
        guard presenter.viewIfLoaded?.window != nil else {
            return XPayPaymentResult(status: .failed, errorCode: XPayErrorCode.presentationFailed)
        }

        let host = topmostController(above: presenter)
        guard host.isBeingDismissed == false else {
            return XPayPaymentResult(status: .failed, errorCode: XPayErrorCode.presentationFailed)
        }

        let controller = XPayPaymentViewController(engine: engine)
        activeController = controller

        let result = await withCheckedContinuation { (continuation: CheckedContinuation<XPayPaymentResult, Never>) in
            host.present(controller, animated: true) {
                flutterApi.start(request: checkout.toMessage()) { result in
                    let paymentResult: XPayPaymentResult
                    switch result {
                    case .success(let message):
                        paymentResult = message.toResult()
                    case .failure:
                        paymentResult = XPayPaymentResult(status: .failed, errorCode: XPayErrorCode.unexpectedResponse)
                    }
                    finish(controller, with: paymentResult) { continuation.resume(returning: paymentResult) }
                }
            }
        }

        if activeController === controller { activeController = nil }
        if engine.viewController === controller { engine.viewController = nil }
        return result
    }

    static func cancelPayment() {
        flutterApi?.cancel { _ in }
    }

    private static func createEngine() throws -> XPayEmbeddedFlutterApi {
        #if targetEnvironment(simulator)
        // A release (AOT) Flutter build cannot run on the simulator: the engine would start without Dart and `initialize` would never complete.
        let kernelBlob = Bundle.main.privateFrameworksURL?.appendingPathComponent("App.framework/flutter_assets/kernel_blob.bin")
        guard let kernelBlob = kernelBlob, FileManager.default.fileExists(atPath: kernelBlob.path) else {
            throw XPayInitializationError(message: "This XPay payment SDK build does not run on the iOS Simulator. Use a real device.")
        }
        #endif

        let engine = FlutterEngine(name: engineName, project: nil, allowHeadlessExecution: true)
        guard engine.run(withEntrypoint: entrypointFunction, libraryURI: entrypointLibrary) else {
            throw XPayInitializationError(message: "The XPay payment engine could not start.")
        }
        guard registerPlugins(with: engine) else {
            engine.destroyContext()
            throw XPayInitializationError(message: "\(pluginRegistrantClassName) was not found. Link FlutterPluginRegistrant.xcframework with the app target.")
        }

        // The iOS engine rejects message handlers set before it runs. Dart only logs after `initialize`, which is sent below.
        XPayEmbeddedHostApiSetup.setUp(binaryMessenger: engine.binaryMessenger, api: hostApiHandler)

        let flutterApi = XPayEmbeddedFlutterApi(binaryMessenger: engine.binaryMessenger)
        self.engine = engine
        self.flutterApi = flutterApi
        return flutterApi
    }

    /// Registers the plugins the SDK screens use (camera, photo library, NFC…).
    ///
    /// `GeneratedPluginRegistrant` is built after this plugin and depends on it, so it cannot be imported here; it is looked up at runtime instead.
    private static func registerPlugins(with engine: FlutterEngine) -> Bool {
        let selector = NSSelectorFromString(pluginRegistrantSelectorName)
        guard let registrant = NSClassFromString(pluginRegistrantClassName), let method = class_getClassMethod(registrant, selector) else { return false }

        typealias RegisterFunction = @convention(c) (AnyClass, Selector, AnyObject) -> Void
        let register = unsafeBitCast(method_getImplementation(method), to: RegisterFunction.self)
        register(registrant, selector, engine)
        return true
    }

    private static func topmostController(above controller: UIViewController) -> UIViewController {
        var topmost = controller
        while let presented = topmost.presentedViewController, presented.isBeingDismissed == false {
            topmost = presented
        }
        return topmost
    }

    private static func finish(_ controller: XPayPaymentViewController, with result: XPayPaymentResult, completion: @escaping () -> Void) {
        controller.markResultReceived()
        guard controller.presentingViewController != nil, controller.isBeingDismissed == false else { return completion() }

        controller.dismiss(animated: true, completion: completion)
    }
}

/// Hosts the SDK screens. Leaving it by any other way than a payment result (for example the host app dismissing it) cancels the payment.
final class XPayPaymentViewController: FlutterViewController {
    private var isResultReceived = false

    init(engine: FlutterEngine) {
        super.init(engine: engine, nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        isModalInPresentation = true
    }

    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    func markResultReceived() {
        isResultReceived = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard isResultReceived == false, isBeingDismissed || presentingViewController == nil else { return }

        XPayPayment.cancelPayment()
    }
}
