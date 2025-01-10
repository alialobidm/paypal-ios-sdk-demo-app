import Foundation

struct PaymentTokenResponse: Decodable, Equatable {
    
    let id: String
    let paymentSource: PaymentSource
}

struct PaymentSource: Decodable, Equatable {
    
    var card: CardPaymentSource?
}

struct CardPaymentSource: Decodable, Equatable {

    let brand: String?
    let lastDigits: String
    let expiry: String
}
