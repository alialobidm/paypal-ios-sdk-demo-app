import Foundation
import CardPayments

class CardCheckoutViewModel: ObservableObject {
    @Published var errorMessage: String = ""
    var cardNumber: String = ""
    var expiryDate: String = ""
    var cvv: String = ""
    
    var isValid: Bool {
        Card.isCardFormValid(cardNumber: cardNumber, expirationDate: expiryDate, cvv: cvv)
    }
    
    func submitCard(completion: (Card?) -> Void) {
        if isValid {
            let card = Card.createCard(cardNumber: cardNumber, expirationDate: expiryDate, cvv: cvv)
            completion(card)
        } else {
            errorMessage = "Invalid card details. Please check and try again."
            completion(nil)
        }
    }
}
