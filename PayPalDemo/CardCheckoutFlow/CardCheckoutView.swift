import SwiftUI
import CardPayments

struct CardCheckoutView: View {
    @State private var cardNumber = "4111 1111 1111 1111"
    @State private var expiryDate = "01 / 25"
    @State private var cvv = "123"
    
    @StateObject private var viewModel = CardCheckoutViewModel()
    @State private var showAlert: Bool = false
    
    private let cardFormatter = CardFormatter()
    
    var onSubmit: (Card) -> Void
    
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
                handleSubmit()
            }
            .padding(20)
        }
        .padding()
        .background(Color.white)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func handleSubmit() {
        viewModel.cardNumber = cardNumber
        viewModel.expiryDate = expiryDate
        viewModel.cvv = cvv
        
        viewModel.submitCard { card in
            if let card = card {
                onSubmit(card)
            } else {
                showAlert = true
            }
        }
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
            .padding(10)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
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
