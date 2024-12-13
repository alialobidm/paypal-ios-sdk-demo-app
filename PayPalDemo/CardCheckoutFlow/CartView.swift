import SwiftUI

struct CartView: View {
    
    var onPayWithCard: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SubmitButton(title: "Pay with Card") {
                onPayWithCard()
            }
            .padding(20)
        }
        .padding()
        .background(Color.white)
    }
}
