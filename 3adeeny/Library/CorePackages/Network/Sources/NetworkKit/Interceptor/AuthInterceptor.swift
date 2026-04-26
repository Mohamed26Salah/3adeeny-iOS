import Alamofire
import Foundation

/// Injects a Bearer token into every request and handles 401 retry.
///
/// Declared as an `actor` so token reads/writes are automatically
/// serialised — no locks needed. The `RequestInterceptor` methods are
/// `nonisolated` (protocol requirement) and hop into the actor
/// via a `Task {}`.
///
/// When your auth endpoints are ready, replace the stub in `retry`
/// with a real token-refresh call and invoke `completion(.retry)`.
public actor AuthInterceptor: RequestInterceptor {
    private var accessToken: String?

    public init(accessToken: String? = nil) {
        self.accessToken = accessToken
    }

    public func updateToken(_ token: String) {
        accessToken = token
    }

    public func clearToken() {
        accessToken = nil
    }

    // MARK: - RequestAdapter

    nonisolated public func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping @Sendable (Result<URLRequest, any Error>) -> Void
    ) {
        Task {
            let token = await self.accessToken
            var request = urlRequest
            if let token {
                request.headers.add(.authorization(bearerToken: token))
            }
            completion(.success(request))
        }
    }

    // MARK: - RequestRetrier

    nonisolated public func retry(
        _ request: Request,
        for session: Session,
        dueTo error: any Error,
        completion: @escaping @Sendable (RetryResult) -> Void
    ) {
        guard
            let response = request.task?.response as? HTTPURLResponse,
            response.statusCode == 401,
            request.retryCount == 0
        else {
            completion(.doNotRetry)
            return
        }

        // TODO: refresh token, then call completion(.retry)
        // Task {
        //     let newToken = try await refreshToken()
        //     await updateToken(newToken)
        //     completion(.retry)
        // }
        completion(.doNotRetryWithError(NetworkError.unauthorized))
    }
}
