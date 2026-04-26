import Alamofire
import Combine
import Foundation

public final class AlamofireNetworkClient: NetworkClient, Sendable {
    private let session: Session
    private let baseURL: URL
    // JSONDecoder is a class not marked Sendable by Apple, but we set it
    // once in init and never mutate it — nonisolated(unsafe) scopes the
    // concurrency bypass to this property only, unlike @unchecked Sendable
    // which would silence all checks on the entire class.
    nonisolated(unsafe) private let decoder: JSONDecoder

    /// - Parameters:
    ///   - baseURL: The root URL prepended to every endpoint's path.
    ///   - interceptor: Optional Alamofire `RequestInterceptor` (e.g. `AuthInterceptor`).
    ///   - eventMonitors: Additional event monitors (e.g. `NetworkLogger`).
    ///   - decoder: The JSON decoder used for all responses. Defaults to a plain `JSONDecoder`.
    public init(
        baseURL: URL,
        interceptor: (any RequestInterceptor)? = nil,
        eventMonitors: [any EventMonitor] = [],
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.decoder = decoder
        self.session = Session(interceptor: interceptor, eventMonitors: eventMonitors)
    }

    // MARK: - Async / Await

    public func request<T: Decodable & Sendable, E: Endpoint>(_ endpoint: E) async throws -> T {
        let urlRequest = try buildURLRequest(for: endpoint)
        do {
            return try await session
                .request(urlRequest)
                .validate()
                .serializingDecodable(T.self, decoder: decoder)
                .value
        } catch let afError as AFError {
            throw NetworkError.map(afError)
        }
    }

    // MARK: - Combine

    public func request<T: Decodable & Sendable, E: Endpoint>(_ endpoint: E) -> AnyPublisher<T, NetworkError> {
        let urlRequest: URLRequest
        do {
            urlRequest = try buildURLRequest(for: endpoint)
        } catch {
            return Fail(error: error as? NetworkError ?? .underlying(error))
                .eraseToAnyPublisher()
        }

        return session
            .request(urlRequest)
            .validate()
            .publishDecodable(type: T.self, decoder: decoder)
            .value()
            .mapError { NetworkError.map($0) }
            .eraseToAnyPublisher()
    }

    // MARK: - URL Request Building

    private func buildURLRequest<E: Endpoint>(for endpoint: E) throws -> URLRequest {
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue

        endpoint.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        do {
            switch endpoint.task {
            case .plain:
                break

            case .queryParameters(let params):
                urlRequest = try URLEncoding(destination: .queryString)
                    .encode(urlRequest, with: params as [String: any Sendable])

            case .body(let encodable):
                urlRequest = try JSONParameterEncoder.default.encode(encodable, into: urlRequest)

            case .bodyAndQueryParameters(let body, let query):
                urlRequest = try URLEncoding(destination: .queryString)
                    .encode(urlRequest, with: query as [String: any Sendable])
                urlRequest = try JSONParameterEncoder.default.encode(body, into: urlRequest)
            }
        } catch let encodingError where !(encodingError is NetworkError) {
            throw NetworkError.encodingFailed(encodingError)
        }

        return urlRequest
    }
}
