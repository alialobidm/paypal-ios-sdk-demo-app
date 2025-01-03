struct Order: Codable, Equatable {
    
    let id: String
    let status: String
    let paymentSource: PaymentSource?

    struct PaymentSource: Codable, Equatable {
        
        let card: Card?
        let paypal: PayPal?
    }

    init(id: String, status: String, paymentSource: PaymentSource? = nil) {
        self.id = id
        self.status = status
        self.paymentSource = paymentSource
    }

    struct Card: Codable, Equatable {

        let lastDigits: String?
        let brand: String?
    }

    struct PayPal: Codable, Equatable {

        let emailAddress: String?
    }
    
    struct Customer: Codable, Equatable {
        
        let id: String
    }
}
