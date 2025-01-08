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
        sca: SCA,
        completion: @escaping (Result<CardPaymentState.CardResult, Error>) -> Void
    ) async {
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
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .loaded(order)
                print("✅ fetched orderID: \(order.id) with status: \(order.status)")
            }
            
            DispatchQueue.main.async {
                self.state.approveResultResponse = .loading
            }
            let config = try await configManager.getCoreConfig()
            cardClient = CardClient(config: config)
            payPalDataCollector = PayPalDataCollector(config: config)
            let cardRequest = CardRequest(orderID: order.id, card: card, sca: sca)
            
            cardClient?.approveOrder(request: cardRequest) { result, error in
                if let error {
                    if error == CardError.threeDSecureCanceledError {
                        completion(.failure(CardError.threeDSecureCanceledError))
                    } else {
                        completion(.failure(error))
                    }
                } else if let result {
                    let cardResult = CardPaymentState.CardResult(
                        id: result.orderID,
                        status: result.status,
                        didAttemptThreeDSecureAuthentication: result.didAttemptThreeDSecureAuthentication
                    )
                    completion(.success(cardResult))
                    
                    print("✅ Success in checkoutWith")
                }
            }
            DispatchQueue.main.async {
                self.state.capturedOrderResponse = .loading
            }
        } catch {
            DispatchQueue.main.async {
                self.state.approveResultResponse = .error(message: error.localizedDescription)
            }
            completion(.failure(error))
            print("❌ Failed in checkout with card: \(error.localizedDescription)")
        }
    }
}
