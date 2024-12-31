import Foundation
import CorePayments

struct ClientIDRequest {

    typealias ResponseType = ClientIDResponse

    var path: String = "/client_id"
    var method: HTTPMethod = .get
    var body: Data?

    var headers: [HTTPHeader: String] {
        [
            .accept: "application/json",
            .acceptLanguage: "en_US"
        ]
    }
}

struct ClientIDResponse: Codable {

    enum CodingKeys: String, CodingKey {
        case clientID = "value"
    }

    let clientID: String
}
