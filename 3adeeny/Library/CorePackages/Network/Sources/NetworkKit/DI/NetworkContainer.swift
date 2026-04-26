import Factory
import Environment

extension Container {
    var authInterceptor: Factory<AuthInterceptor> {
        self { AuthInterceptor() }.singleton
    }

    var networkClient: Factory<any NetworkClient> {
        self {
            AlamofireNetworkClient(
                baseURL: AppEnvironment.current.baseURL,
                interceptor: self.authInterceptor(),
                eventMonitors: AppEnvironment.current.isDebugOrStaging ? [NetworkLogger()] : []
            )
        }.singleton
    }
}
