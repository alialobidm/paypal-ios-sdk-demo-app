import SwiftUI

class CheckoutCoordinator: ObservableObject {
    @Published var navigationPath: [CheckoutStep] = []
    @Published var cardPaymentViewModel: CardPaymentViewModel?
    @Published var payPalViewModel: PayPalViewModel?
    @Published var selectedIntent: Intent = .authorize

    func startCardCheckout(amount: Double) {
        cardPaymentViewModel = CardPaymentViewModel()
        navigationPath.append(.checkout(amount: amount))
    }

    func startPayPalCheckout() {
        payPalViewModel = PayPalViewModel()
        payPalViewModel?.startCheckout()
    }

    func completeOrder(orderID: String) {
        navigationPath.append(.complete(orderID: orderID))
    }

    func reset() {
        navigationPath.removeAll()
        cardPaymentViewModel = nil
        payPalViewModel = nil
    }
}
