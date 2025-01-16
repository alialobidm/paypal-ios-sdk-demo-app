import SwiftUI

class CheckoutCoordinator: ObservableObject {
    @Published var navigationPath: [CheckoutStep] = []
    @Published var cardPaymentViewModel: CardPaymentViewModel?
    @Published var selectedIntent: Intent = .capture
    
    @Published var payPalViewModel: PayPalViewModel?
    @Published var paypalErrorMessage: String?
    @Published var isLoading = false
    @Published var showAlert = false

    func startCardCheckout(amount: Double) {
        DispatchQueue.main.async {
            self.cardPaymentViewModel = CardPaymentViewModel()
            self.navigationPath.append(.cardCheckout(amount: amount))
        }
    }

    func startPayPalCheckout(amount: Double) {
        isLoading = true
        DispatchQueue.main.async {
            self.payPalViewModel = PayPalViewModel()
            Task {
                do {
                    guard let viewModel = self.payPalViewModel else { return }
                    let completedOrderID = try await viewModel.startCheckout(
                        amount: amount,
                        intent: self.selectedIntent
                    )

                    self.isLoading = false
                    self.completeOrder(orderID: completedOrderID)
                } catch {
                    self.isLoading = false
                    self.showAlert = true
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
