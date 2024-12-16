import SwiftUI

struct CardCheckoutView: View {
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    
    var onSubmit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Card Checkout")
                .padding(.bottom, 25)
            CardInputField(placeholder: "Card Number", text: $cardNumber)
            HStack(spacing: 10) {
                CardInputField(placeholder: "MM/YY", text: $expiryDate)
                CardInputField(placeholder: "CVV", text: $cvv)
            }
            .padding(.trailing, 20)
            Spacer()
            SubmitButton(title: "Submit") {
                onSubmit()
            }
            .padding(20)
        }
        .padding()
        .background(Color.white)
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title)
            .bold()
    }
}

struct CardInputField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.roundedBorder)
            .padding(.trailing, 20)
        
    }
}

struct SubmitButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
}
