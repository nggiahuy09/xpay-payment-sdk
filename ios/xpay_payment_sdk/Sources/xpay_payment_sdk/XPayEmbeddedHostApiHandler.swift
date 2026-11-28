import Foundation

final class XPayEmbeddedHostApiHandler: XPayEmbeddedHostApi {
    func onLog(event: XPayEmbeddedLogMessage) throws {
        XPayPayment.config?.onLog?(event.toLogEvent())
    }

    func fetchSession(completion: @escaping (Result<String, Error>) -> Void) {
        Task { @MainActor in
            guard let fetchSession = XPayPayment.activeFetchSession else {
                return completion(.failure(XPayEmbeddedError(code: "fetch_session_unavailable", message: "No fetchSession was given for the open payment.", details: nil)))
            }

            do {
                completion(.success(try await fetchSession()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
