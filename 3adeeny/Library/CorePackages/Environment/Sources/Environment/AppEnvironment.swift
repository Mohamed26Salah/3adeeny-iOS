import Foundation

public enum AppEnvironment: Sendable {
    case debug
    case staging
    case production

    // Resolved at compile time from SWIFT_ACTIVE_COMPILATION_CONDITIONS.
    // Switch the active scheme to change the environment — no code change needed.
    public static let current: AppEnvironment = {
        #if STAGING
        return .staging
        #elseif DEBUG
        return .debug
        #else
        return .production
        #endif
    }()

    public var baseURL: URL {
        switch self {
        case .debug:
            return URL(string: "http://localhost:8080/api/v1/")!
        case .staging:
            return URL(string: "https://staging.api.3adeeny.com/v1/")!
        case .production:
            return URL(string: "https://api.3adeeny.com/v1/")!
        }
    }

    public var isDebugOrStaging: Bool {
        self == .debug || self == .staging
    }
}
