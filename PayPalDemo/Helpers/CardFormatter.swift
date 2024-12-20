import Foundation
import CardPayments

enum Fields {
    case cardNumber
    case expirationDate
    case cvv
}

class CardFormatter {

    func formatCardNumber(_ cardNumber: String) -> String {
        /// remove spaces from card string
        var formattedCardNumber: String = cardNumber.replacingOccurrences(of: " ", with: "")

        /// gets the card type to know how to format card string
        let cardType = CardType.unknown.getCardType(formattedCardNumber)

        /// loops through where the space should be based on the card types indices and inserts a space at the desired index
        cardType.spaceDelimiterIndices.forEach { index in
            if index < formattedCardNumber.count {
                let index = formattedCardNumber.index(formattedCardNumber.startIndex, offsetBy: index)
                formattedCardNumber.insert(" ", at: index)
            }
        }
        return formattedCardNumber
    }

    func formatExpirationDate( _ expirationDate: String) -> String {
        /// holder for the current expiration date
        var formattedDate = expirationDate

        /// if the date count is greater than 2 append " / " after the month to format as MM/YY
        if formattedDate.count > 2 {
            formattedDate.insert(contentsOf: " / ", at: formattedDate.index(formattedDate.startIndex, offsetBy: 2))
        }
        return formattedDate
    }

    func formatFieldWith(_ text: String, field: Fields) -> String {
        switch field {
        case .cardNumber:
            var cardNumberText: String
            let cleanedText = text.replacingOccurrences(of: " ", with: "")
            cardNumberText = String(cleanedText.prefix(CardType.unknown.getCardType(text).maxLength))
            cardNumberText = cardNumberText.filter { ("0"..."9").contains($0) }
            cardNumberText = formatCardNumber(cardNumberText)
            return cardNumberText

        case .expirationDate:
            var expirationDateText: String
            let cleanedText = text.replacingOccurrences(of: " / ", with: "")
            expirationDateText = String(cleanedText.prefix(4))
            expirationDateText = expirationDateText.filter { ("0"..."9").contains($0) }
            expirationDateText = formatExpirationDate(expirationDateText)
            return expirationDateText

        case .cvv:
            var cvvText: String
            cvvText = String(text.prefix(4))
            cvvText = cvvText.filter { ("0"..."9").contains($0) }
            return cvvText
        }
    }
}

enum CardType {
    case americanExpress, visa, discover, masterCard, unknown

    var spaceDelimiterIndices: [Int] {
        switch self {
        case .americanExpress:
            return [4, 11]
        case .visa:
            return [4, 9, 14]
        case .discover:
            return [4, 9, 14]
        case .masterCard:
            return [4, 9, 14]
        case .unknown:
            return [4, 9, 14]
        }
    }

    var maxLength: Int {
        switch self {
        case .americanExpress:
            return 15
        case .visa:
            return 16
        case .discover:
            return 19
        case .masterCard:
            return 16
        case .unknown:
            return 16
        }
    }

    func getCardType(_ cardNumber: String) -> CardType {
        if cardNumber.starts(with: "34") || cardNumber.starts(with: "37") {
            return .americanExpress
        } else if cardNumber.starts(with: "4") {
            return .visa
        } else if cardNumber.starts(with: "6011") || cardNumber.starts(with: "65") {
            return .discover
        } else if cardNumber.starts(with: "51") || cardNumber.starts(with: "52")
            || cardNumber.starts(with: "53") || cardNumber.starts(with: "54") || cardNumber.starts(with: "55") {
            return .masterCard
        } else {
            return .unknown
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
