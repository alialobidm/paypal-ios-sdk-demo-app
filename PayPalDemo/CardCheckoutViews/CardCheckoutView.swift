import SwiftUI
import CardPayments

struct CardCheckoutView: View {
    @ObservedObject var viewModel: CardPaymentViewModel
    let amount: Double
    let intent: String
    let onCheckoutCompleted: (String) -> Void

    @StateObject private var validationViewModel = CardCheckoutValidationViewModel()
    @State private var cardNumber: String = "4111 1111 1111 1111"
    @State private var expirationDate: String = "01 / 25"
    @State private var cvv: String = "123"
    @State private var showAlert: Bool = false
    @State private var isLoading: Bool = false
    
    private let cardFormatter = CardFormatter()

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Card Checkout")
                    .padding(.bottom, 25)
                CardInputField(placeholder: "Card Number", text: $cardNumber)
                    .onChange(of: cardNumber) { _, newValue in
                        cardNumber = cardFormatter.formatFieldWith(newValue, field: .cardNumber)
                        cvv = CardType.unknown.getCardType(newValue) == .americanExpress ? "1234" : "123"
                    }
                HStack(spacing: 10) {
                    CardInputField(placeholder: "MM/YY", text: $expirationDate)
                        .onChange(of: expirationDate) { _, newValue in
                            expirationDate = cardFormatter.formatFieldWith(newValue, field: .expirationDate)
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
                    message: Text(validationViewModel.errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            
            if isLoading {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                ProgressView("Processing...")
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
            }
        }
    }

    private func handleSubmit() {
        validationViewModel.cardNumber = cardNumber
        validationViewModel.expirationDate = expirationDate
        validationViewModel.cvv = cvv
        
        guard validationViewModel.isValid else {
            showAlert = true
            
            return
        }
        isLoading = true
        Task {
            do {
                let card = Card.createCard(
                    cardNumber: cardNumber,
                    expirationDate: expirationDate,
                    cvv: cvv
                )
                let completedOrder = try await viewModel.checkoutWith(
                    card: card,
                    amount: "\(amount)",
                    intent: intent,
                    selectedMerchantIntegration: DemoSettings.merchantIntegration,
                    sca: .scaWhenRequired
                )
                onCheckoutCompleted(completedOrder.id)
            } catch {
                showAlert = true
                print("Checkout process failed with error: \(error.localizedDescription)")
            }
            isLoading = false
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
