import Foundation

enum PayPalCheckoutState {
    case none
    case loading
    case error(Error)
}
