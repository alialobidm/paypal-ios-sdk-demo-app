import SwiftUI
import CardPayments

struct CardCheckoutView: View {
    @ObservedObject var cardPaymentViewModel: CardPaymentViewModel
    @State private var cardNumber = "4111 1111 1111 1111"
    @State private var expirationDate = "01 / 25"
    @State private var cvv = "123"
    
    let selectedIntent: Intent
    let orderID: String
    let totalAmount: Double
    
    @StateObject private var cardValidationViewModel = CardCheckoutValidationViewModel()
    @State private var showAlert: Bool = false
    @State var isLoading: Bool = false
    
    private let cardFormatter = CardFormatter()
    
    var onSubmit: () -> Void
    
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
                    message: Text(cardValidationViewModel.errorMessage),
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
        cardValidationViewModel.cardNumber = cardNumber
        cardValidationViewModel.expirationDate = expirationDate
        cardValidationViewModel.cvv = cvv
        
        isLoading = true
        
        Task {
            do {
                try await cardPaymentViewModel.createOrder(
                    amount: "\(totalAmount)",
                    selectedMerchantIntegration: DemoSettings.merchantIntegration,
                    intent: selectedIntent.rawValue,
                    shouldVault: false,
                    customerID: nil
                )
                
                guard let orderID = cardPaymentViewModel.state.createOrder?.id else {
                    print("Error: Order ID is nil after createOrder.")
                    showAlert = true
                    isLoading = false
                    return
                }
                
                cardValidationViewModel.isCardValid { card in
                    if let card = card {
                        Task {
                            do {
                                await cardPaymentViewModel.checkoutWith(
                                    card: card,
                                    orderID: orderID,
                                    sca: cardPaymentViewModel.state.scaSelection,
                                    completion: { result in
                                        switch result {
                                        case .success(let cardResult):
                                            print("Checkout succeeded with order ID: \(cardResult.id)")
                                            isLoading = false
                                            onSubmit()
                                        case .failure(let error):
                                            print("Checkout failed: \(error.localizedDescription)")
                                            showAlert = true
                                            isLoading = false
                                        }
                                    }
                                )
                            }
                        }
                    } else {
                        showAlert = true
                        isLoading = false
                    }
                }
            } catch {
                print("Error in creating order: \(error.localizedDescription)")
                showAlert = true
                isLoading = false
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
