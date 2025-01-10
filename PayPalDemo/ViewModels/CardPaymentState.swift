import Foundation
import CardPayments

struct CardPaymentState: Equatable {
    struct CardResult: Decodable, Equatable {
        let id: String
    }
}
