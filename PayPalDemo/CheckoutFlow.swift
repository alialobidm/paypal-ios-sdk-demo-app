import SwiftUI

enum CheckoutStep: Hashable {
    case checkout(amount: Double)
    case complete(orderID: String)
}

struct CheckoutFlow: View {
    @StateObject private var coordinator = CheckoutCoordinator()
    @State private var showPayPalCheckoutAlert = false

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            CartView(
                onPayWithPayPal: { amount in coordinator.startPayPalCheckout(amount: amount)
                },
                onPayWithCard: { amount in
                    coordinator.startCardCheckout(amount: amount)
                }
            )
            .navigationDestination(for: CheckoutStep.self) { step in
                switch step {
                case .checkout(let amount):
                    if let viewModel = coordinator.cardPaymentViewModel {
                        CardCheckoutView(
                            viewModel: viewModel,
                            amount: amount,
                            intent: coordinator.selectedIntent,
                            onCheckoutCompleted: { orderID in
                                coordinator.completeOrder(orderID: orderID)
                            }
                        )
                    }
                case .complete(let orderID):
                    OrderCompleteView(orderID: orderID) {
                        coordinator.reset()
                    }
                }
            }
        }
        .overlay {
            if case .loading = coordinator.payPalCheckoutState {
                ProgressView("Processing...")
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
            }
        }
        .onChange(of: coordinator.paypalErrorMessage) { _, newValue in
            if newValue != nil {
                showPayPalCheckoutAlert = true
            }
        }
        .alert(isPresented: $showPayPalCheckoutAlert) {
            Alert(
                title: Text("Error"),
                message: Text(coordinator.paypalErrorMessage ?? "Unknown error"),
                dismissButton: .default(Text("OK")) {
                    coordinator.paypalErrorMessage = nil
                }
            )
        }
    }
}

#Preview {
    CheckoutFlow()
}
