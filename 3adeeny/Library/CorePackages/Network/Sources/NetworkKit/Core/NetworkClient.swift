import Combine

public protocol NetworkClient: Sendable {
    /// Performs a request and decodes the response using async/await.
    func request<T: Decodable & Sendable, E: Endpoint>(_ endpoint: E) async throws -> T

    /// Performs a request and decodes the response as a Combine publisher.
    func request<T: Decodable & Sendable, E: Endpoint>(_ endpoint: E) -> AnyPublisher<T, NetworkError>
}
