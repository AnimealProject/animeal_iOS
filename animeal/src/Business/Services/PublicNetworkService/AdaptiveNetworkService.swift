// System
import UIKit

// SDK
import Common
import Services
import Amplify

/// Adapter that switches between authenticated and public network services based on user auth state
final class AdaptiveNetworkService: NetworkServiceProtocol {
    
    private let authenticatedService: NetworkServiceProtocol
    private let publicService: NetworkServiceProtocol
    
    init(
        authenticatedService: NetworkServiceProtocol = NetworkService(),
        publicService: NetworkServiceProtocol = PublicNetworkService()
    ) {
        self.authenticatedService = authenticatedService
        self.publicService = publicService
    }
    
    func query<Response: Decodable>(request: Request<Response>) async throws -> Response {
        let authSession = try await Amplify.Auth.fetchAuthSession()
        
        if authSession.isSignedIn {
            // User is authenticated - use authenticated service (Cognito User Pools)
            return try await authenticatedService.query(request: request)
        } else {
            // Guest user - use public service (API Key)
            return try await publicService.query(request: request)
        }
    }
    
    func mutate<Response: Decodable>(request: Request<Response>) async throws -> Response {
        let authSession = try await Amplify.Auth.fetchAuthSession()
        
        if authSession.isSignedIn {
            // User is authenticated - use authenticated service
            return try await authenticatedService.mutate(request: request)
        } else {
            // Guest user - use public service (will throw error)
            return try await publicService.mutate(request: request)
        }
    }
}
