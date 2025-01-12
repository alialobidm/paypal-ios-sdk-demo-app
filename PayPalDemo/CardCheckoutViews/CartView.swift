import SwiftUI

struct CartView: View {
    @State private var totalAmount: Double = 29.99
    var onPayWithPayPal: () -> Void
    var onPayWithCard: (Double) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("Cart")
                .font(.largeTitle)
                .padding([.top, .leading])
            
            CartItemView(amount: totalAmount)

            Divider()
                .padding(.vertical)
                .padding(.horizontal)
            
            TotalSection(amount: totalAmount)

            Spacer()
            
            VStack(spacing: 10) {
                PaymentButton(
                    title: "Pay with PayPal",
                    imageName: "paypal_color_monogram@3x",
                    backgroundColor: Color.yellow,
                    action: onPayWithPayPal
                )
                
                PaymentButton(
                    title: "Pay with Card",
                    imageName: nil,
                    backgroundColor: Color.black,
                    action: {
                        onPayWithCard(totalAmount)
                    }
                )
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.bottom)
    }
}


struct CartItemView: View {
    let amount: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 15){
            HStack{
                Image(systemName: "tshirt")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                VStack(alignment: .leading) {
                    Text("White T-Shirt")
                        .font(.headline)
                }
                
                Spacer()
                
                Text("$\(amount, specifier: "%.2f")")
                    .font(.headline)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black, lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }
    
}

struct TotalSection: View {
    let amount: Double

    var body: some View {
        HStack {
            Text("Total")
                .font(.title2)
            Spacer()
            
            Text("$\(amount, specifier: "%.2f")")
                .font(.title2)
        }
        .padding(.horizontal)
        
    }
    
}

struct PaymentButton: View {
    let title: String
    let imageName: String?
    let backgroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let imageName = imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                Text(title)
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(backgroundColor)
            .cornerRadius(10)
        }
    }
}
