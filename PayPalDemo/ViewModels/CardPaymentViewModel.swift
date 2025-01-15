import Foundation
import CardPayments
import CorePayments
import FraudProtection

class CardPaymentViewModel: ObservableObject {
    
    let configManager = CoreConfigManager()

    private var cardClient: CardClient?
    
    func checkoutWith(
        card: Card,
        amount: String,
        intent: Intent,
        sca: SCA
    ) async throws -> Order {
        do {
            async let config = try await configManager.getCoreConfig()

            let order = try await DemoMerchantAPI.sharedService.createOrder(
                orderParams: CreateOrderParams(
                    applicationContext: nil,
                    intent: intent.rawValue,
                    purchaseUnits: [PurchaseUnit(amount: Amount(currencyCode: "USD", value: amount))]
                )
            )
            print("✅ Order created with orderID: \(order.id) with status: \(order.status)")

            cardClient = try await CardClient(config: config)
            guard let cardClient = cardClient else {
                throw NSError(domain: "CardClientError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Card client could not be initialized."])
            }

            let cardRequest = CardRequest(orderID: order.id, card: card, sca: sca)
            let cardResult = try await cardClient.approveOrder(request: cardRequest)
            print("✅ Card approval returned with CardResult \norderID: \(cardResult.orderID) \nstatus: \(String(describing: cardResult.status)) \ndidAttemptThreeDSecureAuthentication: \(cardResult.didAttemptThreeDSecureAuthentication)")

            let completedOrder = try await DemoMerchantAPI.sharedService.completeOrder(orderID: order.id, intent: intent)
            print("✅ Capture returned with orderID: \(completedOrder.id) with status: \(completedOrder.status) ")
            return completedOrder
        } catch let error {
            print("❌ Failed in checkout with card: \(error.localizedDescription)")
            throw error
        }
    }
}
