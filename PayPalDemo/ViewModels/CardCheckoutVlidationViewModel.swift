import Foundation
import CardPayments

class CardCheckoutValidationViewModel: ObservableObject {
    @Published var errorMessage: String = ""
    var cardNumber: String = ""
    var expirationDate: String = ""
    var cvv: String = ""
    
    var isValid: Bool {
        Card.isCardFormValid(cardNumber: cardNumber, expirationDate: expirationDate, cvv: cvv)
    }
    
    func isCardValid(completion: (Card?) -> Void) {
        if isValid {
            let card = Card.createCard(cardNumber: cardNumber, expirationDate: expirationDate, cvv: cvv)
            completion(card)
        } else {
            errorMessage = "Invalid card details. Please check and try again."
            completion(nil)
        }
    }
}

extension Card {
    static func createCard(cardNumber: String, expirationDate: String, cvv: String) -> Card {
        let cleanedCardText = cardNumber.replacingOccurrences(of: " ", with: "")

        let expirationComponents = expirationDate.components(separatedBy: " / ")
        let expirationMonth = expirationComponents[0]
        let expirationYear = "20" + expirationComponents[1]

        return Card(number: cleanedCardText, expirationMonth: expirationMonth, expirationYear: expirationYear, securityCode: cvv)
    }

    static func isCardFormValid(cardNumber: String, expirationDate: String, cvv: String) -> Bool {
        let cleanedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        let cleanedExpirationDate = expirationDate.replacingOccurrences(of: " / ", with: "")

        let enabled = cleanedCardNumber.count >= 15 && cleanedCardNumber.count <= 19
        && cleanedExpirationDate.count == 4 && cvv.count >= 3 && cvv.count <= 4
        return enabled
    }
}
