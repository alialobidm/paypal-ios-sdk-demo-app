import SwiftUI

enum CheckoutStep: Hashable {
    case checkout(amount: Double)
    case complete(orderID: String)
}

struct CheckoutFlow: View {
    @StateObject private var coordinator = CheckoutCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            CartView(
                onPayWithPayPal: coordinator.startPayPalCheckout,
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
    }
}

#Preview {
    CheckoutFlow()
}
