import Foundation
import CardPayments
import CorePayments
import FraudProtection

class CardPaymentViewModel: ObservableObject {
    @Published var state = CardPaymentState()
    private var payPalDataCollector: PayPalDataCollector?
    let configManager = CoreConfigManager(domain: "Card Payments")

    private var cardClient: CardClient?
    
    func createOrder(
        amount: String,
        selectedMerchantIntegration: MerchantIntegration,
        intent: String,
        customerID: String? = nil
    ) async throws {

        let amountRequest = Amount(currencyCode: "USD", value: amount)

        let orderRequestParams = CreateOrderParams(
            applicationContext: nil,
            intent: intent,
            purchaseUnits: [PurchaseUnit(amount: amountRequest)]
        )

        do {
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .loading
            }
            let order = try await DemoMerchantAPI.sharedService.createOrder(
                orderParams: orderRequestParams, selectedMerchantIntegration: selectedMerchantIntegration
            )
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .loaded(order)
                print("✅ fetched orderID: \(order.id) with status: \(order.status)")
            }
        } catch {
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .error(message: error.localizedDescription)
                print("❌ failed to fetch orderID: \(error)")
            }
        }
    }

    func captureOrder(orderID: String, selectedMerchantIntegration: MerchantIntegration) async throws {
        do {
            DispatchQueue.main.async {
                self.state.capturedOrderResponse = .loading
            }
            let payPalClientMetadataID = payPalDataCollector?.collectDeviceData()
            let order = try await DemoMerchantAPI.sharedService.captureOrder(
                orderID: orderID,
                selectedMerchantIntegration: selectedMerchantIntegration,
                payPalClientMetadataID: payPalClientMetadataID
            )
            DispatchQueue.main.async {
                self.state.capturedOrderResponse = .loaded(order)
            }
        } catch {
            DispatchQueue.main.async {
                self.state.capturedOrderResponse = .error(message: error.localizedDescription)
            }
            print("Error capturing order: \(error.localizedDescription)")
        }
    }

    func authorizeOrder(orderID: String, selectedMerchantIntegration: MerchantIntegration) async throws {
        do {
            DispatchQueue.main.async {
                self.state.authorizedOrderResponse = .loading
            }
            let payPalClientMetadataID = payPalDataCollector?.collectDeviceData()
            let order = try await DemoMerchantAPI.sharedService.authorizeOrder(
                orderID: orderID,
                selectedMerchantIntegration: selectedMerchantIntegration,
                payPalClientMetadataID: payPalClientMetadataID
            )
            DispatchQueue.main.async {
                self.state.authorizedOrderResponse = .loaded(order)
            }
        } catch {
            DispatchQueue.main.async {
                self.state.authorizedOrderResponse = .error(message: error.localizedDescription)
            }
            print("Error capturing order: \(error.localizedDescription)")
        }
    }
    
    func checkoutWith(
        card: Card,
        orderID: String,
        sca: SCA,
        completion: @escaping (Result<CardPaymentState.CardResult, Error>) -> Void
    ) async {
        do {
            DispatchQueue.main.async {
                self.state.approveResultResponse = .loading
            }
            let config = try await configManager.getCoreConfig()
            cardClient = CardClient(config: config)
            payPalDataCollector = PayPalDataCollector(config: config)
            let cardRequest = CardRequest(orderID: orderID, card: card, sca: sca)
            
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
                }
            }
        } catch {
            completion(.failure(error))
            print("Failed in checkout with card: \(error.localizedDescription)")
        }
    }
}
