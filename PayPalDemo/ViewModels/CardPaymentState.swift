import Foundation
import CardPayments

struct CardPaymentState: Equatable {

    struct CardResult: Decodable, Equatable {

        let id: String
        let status: String?
        let didAttemptThreeDSecureAuthentication: Bool
    }

    var createOrder: Order?
    var authorizedOrder: Order?
    var capturedOrder: Order?
    var intent: Intent = .authorize
    var scaSelection: SCA = .scaWhenRequired
    var approveResult: CardResult?
}
