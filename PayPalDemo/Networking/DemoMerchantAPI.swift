import Foundation
import CorePayments

/// API Client used to create and process orders on sample merchant server
final class DemoMerchantAPI {

    static let sharedService = DemoMerchantAPI()

    private init() {}

    /// This function fetches a clientID to initialize any module of the SDK
    /// - Parameters:
    ///   - environment: the current environment
    /// - Returns: a String representing an clientID
    /// - Throws: an error explaining why fetch clientID failed
    public func getClientID(environment: paypal_ios_sdk_demo_app.Environment) async -> String? {

        let clientID = await fetchClientID(environment: environment)
            return clientID
    }

    /// This function replicates a way a merchant may go about creating an order on their server and is not part of the SDK flow.
    /// - Parameter orderParams: the parameters to create the order with
    /// - Returns: an order
    /// - Throws: an error explaining why create order failed
    func createOrder(orderParams: CreateOrderParams) async throws -> Order {

        guard let url = buildBaseURL(with: "/orders") else {
            throw URLResponseError.invalidURL
        }

        let urlRequest = buildURLRequest(method: "POST", url: url, body: orderParams)
        let data = try await data(for: urlRequest)
        return try parse(from: data)
    }

    func completeOrder(
        orderID: String,
        payPalClientMetadataID: String? = nil,
        intent: Intent
    ) async throws -> Order {
        guard let url = buildBaseURL(with: "/orders/\(orderID)/\(intent.rawValue)") else {
            throw URLResponseError.invalidURL
        }

        var urlRequest = buildURLRequest(method: "POST", url: url, body: EmptyBodyParams())
        if let payPalClientMetadataID {
            urlRequest.addValue(payPalClientMetadataID, forHTTPHeaderField: "PayPal-Client-Metadata-Id")
        }
        let data = try await data(for: urlRequest)
        return try parse(from: data)
    }

    // MARK: Private methods

    private func buildURLRequest<T>(method: String, url: URL, body: T) -> URLRequest where T: Encodable {
        let encoder = JSONEncoder()
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if method != "GET", let json = try? encoder.encode(body) {
            print(String(data: json, encoding: .utf8) ?? "")
                urlRequest.httpBody = json
        }

        return urlRequest
    }

    private func data(for urlRequest: URLRequest) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            return data
        } catch {
            throw URLResponseError.networkConnectionError
        }
    }

    private func parse<T: Decodable>(from data: Data) throws -> T {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw URLResponseError.dataParsingError
        }
    }

    private func buildBaseURL(with endpoint: String) -> URL? {
        return URL(string: DemoSettings.environment.baseURL + endpoint)
    }

    private func buildPayPalURL(with endpoint: String) -> URL? {
        URL(string: "https://api.sandbox.paypal.com" + endpoint)
    }

    private func fetchClientID(environment: paypal_ios_sdk_demo_app.Environment) async -> String? {
        do {
            let clientIDRequest = ClientIDRequest()
            let request = try buildClientIDRequest(
                clientIDRequest: clientIDRequest, environment: environment
            )
            let (data, response) = try await URLSession.shared.performRequest(with: request)
            guard let response = response as? HTTPURLResponse else {
                throw URLResponseError.serverError
            }
            switch response.statusCode {
            case 200..<300:
                let clientIDResponse: ClientIDResponse = try parse(from: data)
                return clientIDResponse.clientID
            default: throw URLResponseError.dataParsingError
            }
        } catch {
            print("Error in fetching clientID")
            return nil
        }
    }
    
    private func buildClientIDRequest(
        clientIDRequest: ClientIDRequest,
        environment: paypal_ios_sdk_demo_app.Environment
    ) throws -> URLRequest {
        var completeUrl = environment.baseURL
        completeUrl.append(contentsOf: clientIDRequest.path)
        guard let url = URL(string: completeUrl) else {
            throw URLResponseError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = clientIDRequest.method.rawValue
        request.httpBody = clientIDRequest.body
        clientIDRequest.headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key.rawValue)
        }
        return request
    }
}
