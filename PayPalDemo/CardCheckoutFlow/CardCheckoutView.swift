import SwiftUI

struct CardCheckoutView: View {
    @State private var cardNumber = "4111 1111 1111 1111"
    @State private var expiryDate = "01 / 25"
    @State private var cvv = "123"
    
    private let cardFormatter = CardFormatter()
    
    var onSubmit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Card Checkout")
                .padding(.bottom, 25)
            CardInputField(placeholder: "Card Number", text: $cardNumber)
                .onChange(of: cardNumber) { _, newValue in
                    cardNumber = cardFormatter.formatFieldWith(newValue, field: .cardNumber)
                    cvv = CardType.unknown.getCardType(newValue) == .americanExpress ? "1234" : "123"
                }
            HStack(spacing: 10) {
                CardInputField(placeholder: "MM/YY", text: $expiryDate)
                    .onChange(of: expiryDate) { _, newValue in
                        expiryDate = cardFormatter.formatFieldWith(newValue, field: .expirationDate)
                    }
                CardInputField(placeholder: "CVV", text: $cvv)
                    .onChange(of: cvv) { _, newValue in
                        cvv = cardFormatter.formatFieldWith(newValue, field: .cvv)
                    }
            }
            .padding(.trailing, 20)
            Spacer()
            SubmitButton(title: "Submit") {
                onSubmit()
            }
            .padding(20)
        }
        .padding()
        .background(Color.white)
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title)
            .bold()
    }
}

struct CardInputField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.roundedBorder)
            .padding(.trailing, 20)
        
    }
}

struct SubmitButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
}
