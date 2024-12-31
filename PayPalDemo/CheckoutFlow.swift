import SwiftUI

enum CheckoutStep: Hashable {
    case checkout(amount: Double)
    case complete(orderID: String)
}

struct CheckoutFlow: View {
    @State private var navigationPath: [CheckoutStep] = []
    @StateObject private var cardPaymentViewModel = CardPaymentViewModel()
    @State private var selectedIntent: Intent = .authorize

    var body: some View {
        NavigationStack(path: $navigationPath) {
            CartView(
                onPayWithPayPal: handlePayPalCheckout,
                onPayWithCard: handleCardCheckout
            )
            .navigationDestination(for: CheckoutStep.self, destination: buildDestination)
        }
    }

    private func handlePayPalCheckout() {
        // TODO: Implement PayPal checkout flow
    }

    private func handleCardCheckout(totalAmount: Double) {
        navigationPath.append(.checkout(amount: totalAmount))
    }

    @ViewBuilder
    private func buildDestination(for step: CheckoutStep) -> some View {
        switch step {
        case .checkout(let amount):
            CardCheckoutView(
                cardPaymentViewModel: cardPaymentViewModel, 
                selectedIntent: selectedIntent,
                orderID: cardPaymentViewModel.state.createOrder?.id ?? "",
                totalAmount: amount,
                onSubmit: {
                    if let order = cardPaymentViewModel.state.createOrder {
                        navigationPath.append(.complete(orderID: order.id))
                    }
                }
            )

        case .complete(let orderID):
            OrderCompleteView(orderID: orderID) {
                navigationPath = []
            }
        }
    }
}


#Preview {
    CheckoutFlow()
}
