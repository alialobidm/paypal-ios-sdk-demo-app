import Foundation

struct CreateSetupTokenParam: Encodable {

    let paymentSource: PaymentSourceType

    enum CodingKeys: String, CodingKey {
        case paymentSource = "payment_source"
    }
}

struct PayPal: Encodable {

    var usageType: String

    enum CodingKeys: String, CodingKey {
        case usageType = "usage_type"
    }
}

struct SetupTokenCard: Encodable {
    let verificationMethod: String?

    enum CodingKeys: String, CodingKey {
        case verificationMethod = "verification_method"
    }
}

enum PaymentSourceType: Encodable {
    case card(verification: String?)
    case paypal(usageType: String)

    private enum CodingKeys: String, CodingKey {
        case card, paypal
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .card(let verification):
            try container.encode(SetupTokenCard(verificationMethod: verification), forKey: .card)
        case .paypal(let usageType):
            try container.encode(PayPal(usageType: usageType), forKey: .paypal)
        }
    }
}
