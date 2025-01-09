import Foundation
import CardPayments
import CorePayments
import FraudProtection

class CardPaymentViewModel: ObservableObject {
    @Published var state = CardPaymentState()
    private var payPalDataCollector: PayPalDataCollector?
    let configManager = CoreConfigManager(domain: "Card Payments")

    private var cardClient: CardClient?
    
    func checkoutWith(
        card: Card,
        amount: String,
        intent: String,
        selectedMerchantIntegration: MerchantIntegration,
        sca: SCA
    ) async throws -> CardPaymentState.CardResult {
        do {
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .loading
            }
            let order = try await DemoMerchantAPI.sharedService.createOrder(
                orderParams: CreateOrderParams(
                    applicationContext: nil,
                    intent: intent,
                    purchaseUnits: [PurchaseUnit(amount: Amount(currencyCode: "USD", value: amount))]
                ),
                selectedMerchantIntegration: selectedMerchantIntegration
            )
            print("✅ fetched orderID: \(order.id) with status: \(order.status)")
            
            let config = try await configManager.getCoreConfig()
            cardClient = CardClient(config: config)
            payPalDataCollector = PayPalDataCollector(config: config)
            let cardRequest = CardRequest(orderID: order.id, card: card, sca: sca)

            let approveResult = try await cardClient?.approveOrder(request: cardRequest)

            guard let approveResult = approveResult else {
                throw NSError(domain: "ApproveOrderError", code: -1, userInfo: nil)
            }
            
            return CardPaymentState.CardResult(
                id: approveResult.orderID,
                status: approveResult.status,
                didAttemptThreeDSecureAuthentication: approveResult.didAttemptThreeDSecureAuthentication
            )
        } catch {
            DispatchQueue.main.async {
                self.state.approveResultResponse = .error(message: error.localizedDescription)
            }
            print("❌ Failed in checkout with card: \(error.localizedDescription)")
            throw error
        }
    }
}
