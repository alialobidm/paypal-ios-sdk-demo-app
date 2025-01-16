import Foundation

struct Item: Identifiable {
    let id: String = UUID().uuidString
    let name: String
    let imageName: String
    let amount: Double
}
