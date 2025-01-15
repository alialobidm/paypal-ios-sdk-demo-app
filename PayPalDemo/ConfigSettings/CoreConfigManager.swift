import Foundation
import CorePayments

class CoreConfigManager {

    let domain: String

    public init(domain: String) {
        self.domain = domain
    }

    func getClientID() async throws -> String {
        try await DemoMerchantAPI.sharedService.getClientID(environment: DemoSettings.environment)
    }

    func getCoreConfig() async throws -> CoreConfig {
        let clientID = try await getClientID()
        
        return CoreConfig(clientID: clientID, environment: DemoSettings.environment.paypalSDKEnvironment)
    }
}
