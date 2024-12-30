import SwiftUI

enum CheckoutStep: Hashable {
    case cart
    case checkout(amount: Double)
    case complete
}

struct CheckoutFlow: View {
    @State private var navigationPath: [CheckoutStep] = []
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            CartView {
                //TODO: Implement PayPal checkout flow
            } onPayWithCard: { totalAmount in
                navigationPath.append(.checkout(amount: totalAmount))
            }
            .navigationDestination(for: CheckoutStep.self) { step in
                switch step {
                case .checkout(let amount):
                    CardCheckoutView(totalAmount: amount) { _ in
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
    CheckoutFlow()
}
