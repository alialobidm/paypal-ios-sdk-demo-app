import SwiftUI

struct OrderCompleteView: View {
    
    var onDone: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Order Complete")
            Text("Thank you for your order! Your order number is #123456789")
                .font(.subheadline)
                .padding(.bottom)
            
            Spacer()
            
            SubmitButton(title: "Done", action: {
                onDone()
            })
        }
        .padding()
        .background(Color.white)
    }
}
