import Foundation
import CardPayments
import PayPalWebPayments

struct UpdateSetupTokenResult: Decodable, Equatable {

    var id: String
    var status: String?
    var didAttemptThreeDSecureAuthentication: Bool
}

enum LoadingState<T: Decodable & Equatable>: Equatable {

    case idle
    case loading
    case error(message: String)
    case loaded(_ value: T)
}
