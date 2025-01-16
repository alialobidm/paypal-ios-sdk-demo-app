import SwiftUI

class CheckoutCoordinator: ObservableObject {
    @Published var navigationPath: [CheckoutStep] = []
    @Published var cardPaymentViewModel: CardPaymentViewModel?
    @Published var payPalViewModel: PayPalViewModel?
    @Published var payPalCheckoutState: PayPalCheckoutState = .none
    @Published var paypalErrorMessage: String?
    @Published var selectedIntent: Intent = .capture

    func startCardCheckout(amount: Double) {
        DispatchQueue.main.async {
            self.cardPaymentViewModel = CardPaymentViewModel()
            self.navigationPath.append(.checkout(amount: amount))
        }
    }

    func startPayPalCheckout(amount: Double) {
        payPalCheckoutState = .loading
        DispatchQueue.main.async {
            self.payPalViewModel = PayPalViewModel()
            Task {
                do {
                    guard let viewModel = self.payPalViewModel else { return }
                    let completedOrderID = try await viewModel.startCheckout(
                        amount: amount,
                        intent: self.selectedIntent
                    )

                    self.payPalCheckoutState = .none
                    self.completeOrder(orderID: completedOrderID)
                } catch {
                    self.payPalCheckoutState = .error(error)
                    self.paypalErrorMessage = error.localizedDescription
                }
            }
        }
    }

    func completeOrder(orderID: String) {
        DispatchQueue.main.async {
            self.navigationPath.append(.complete(orderID: orderID))
        }
    }

    func reset() {
        DispatchQueue.main.async {
            self.navigationPath.removeAll()
            self.cardPaymentViewModel = nil
            self.payPalViewModel = nil
        }
    }
}
