import SwiftUI

enum CheckoutStep {
    case cart
    case checkout
    case complete
}

struct PayPalCheckoutFlow: View {
    @State private var navigationPath: [CheckoutStep] = []
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            CartView {
                //TODO: Implement PayPal checkout flow
            } onPayWithCard: {
                navigationPath.append(.checkout)
            }
            .navigationDestination(for: CheckoutStep.self) { step in
                switch step {
                case .checkout:
                    CardCheckoutView {
                        navigationPath.append(.complete)
                    }
                case .complete:
                    OrderCompleteView {
                        navigationPath = []
                    }
                default:
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    PayPalCheckoutFlow()
}
