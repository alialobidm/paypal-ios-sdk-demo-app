import Foundation
import CorePayments

class CoreConfigManager {

    func getClientID() async throws -> String {
        try await DemoMerchantAPI.sharedService.getClientID()
    }

    func getCoreConfig() async throws -> CoreConfig {
        let clientID = try await getClientID()
        
        return CoreConfig(clientID: clientID, environment: DemoSettings.environment.paypalSDKEnvironment)
    }
}
