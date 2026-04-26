import Alamofire
import Foundation

public enum NetworkError: Error, LocalizedError, @unchecked Sendable {
    case invalidURL
    case encodingFailed(Error)
    case decodingFailed(Error)
    case serverError(statusCode: Int, data: Data?)
    case unauthorized
    case noInternetConnection
    case timeout
    case cancelled
    case underlying(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .encodingFailed(let error):
            return "Request encoding failed: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Response decoding failed: \(error.localizedDescription)"
        case .serverError(let code, _):
            return "Server error with status code \(code)."
        case .unauthorized:
            return "Unauthorized — please sign in again."
        case .noInternetConnection:
            return "No internet connection."
        case .timeout:
            return "The request timed out."
        case .cancelled:
            return "The request was cancelled."
        case .underlying(let error):
            return error.localizedDescription
        }
    }

    static func map(_ afError: AFError) -> NetworkError {
        if afError.isExplicitlyCancelledError {
            return .cancelled
        }

        if afError.isSessionTaskError, let urlError = afError.underlyingError as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .noInternetConnection
            case .timedOut:
                return .timeout
            default:
                break
            }
        }

        if case .responseValidationFailed(let reason) = afError,
           case .unacceptableStatusCode(let code) = reason {
            if code == 401 { return .unauthorized }
            return .serverError(statusCode: code, data: nil)
        }

        if case .responseSerializationFailed = afError {
            return .decodingFailed(afError)
        }

        return .underlying(afError)
    }
}
