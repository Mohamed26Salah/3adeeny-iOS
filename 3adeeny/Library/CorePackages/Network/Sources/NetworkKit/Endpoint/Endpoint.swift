import Foundation

// MARK: - HTTPMethod

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - EndpointTask

/// Describes how request parameters are encoded.
public enum EndpointTask: @unchecked Sendable {
    /// No parameters.
    case plain
    /// URL query string parameters (e.g. ?key=value).
    case queryParameters([String: String])
    /// JSON-encoded body.
    case body(any Encodable)
    /// JSON body + URL query string parameters combined.
    case bodyAndQueryParameters(body: any Encodable, query: [String: String])
}

// MARK: - Endpoint

public protocol Endpoint: Sendable {
    var path: String { get }
    var method: HTTPMethod { get }
    /// Additional headers merged on top of the client's default headers.
    var headers: [String: String]? { get }
    var task: EndpointTask { get }
}

public extension Endpoint {
    var headers: [String: String]? { nil }
    var task: EndpointTask { .plain }
}
