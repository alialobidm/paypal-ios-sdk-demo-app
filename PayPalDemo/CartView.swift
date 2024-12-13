//
//  CartView.swift
//  paypal-ios-sdk-demo-app
//
//  Created by Suraj Raju Dhopati on 12/13/24.
//


import SwiftUI


struct CartView: View {
    var body : some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("Cart")
                .font(.largeTitle)
                .padding([.top, .leading])
            
            
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
                    
                    Text("$29.99")
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
            
            Divider()
                .padding(.vertical)
                .padding(.horizontal)
            
            HStack {
                Text("Total")
                    .font(.title2)
                Spacer()
                
                Text("$29.99")
                    .font(.title2)
            }
            .padding(.horizontal)
            
            Spacer()
            
            
            VStack(spacing: 10) {
                Button(action: {
                    //Make button action changes here (auth and navigate or alert?)
                }){
                    HStack {
                        Image("paypal_color_monogram@3x")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.yellow)
                    .cornerRadius(10)
                }
                
                Button(action: {
                    //Make card payments action here (auth and Navigate)
                }) {
                    Text("Pay with Card")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}
