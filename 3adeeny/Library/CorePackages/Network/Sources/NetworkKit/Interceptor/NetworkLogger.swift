import Alamofire
import Foundation

public final class NetworkLogger: EventMonitor, @unchecked Sendable {
    public let queue = DispatchQueue(label: "com.3adeeny.network.logger")

    public init() {}

    public func requestDidFinish(_ request: Request) {
        #if DEBUG
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        debugPrint(request)
        #endif
    }

    public func request<Value>(
        _ request: DataRequest,
        didParseResponse response: DataResponse<Value, AFError>
    ) {
        #if DEBUG
        guard
            let data = response.data,
            let json = try? JSONSerialization.jsonObject(with: data),
            let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
            let prettyString = String(data: pretty, encoding: .utf8)
        else { return }
        print("[Network] Response:\n\(prettyString)")
        #endif
    }
}
