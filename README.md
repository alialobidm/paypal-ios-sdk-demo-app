**PayPal iOS SDK Demo App**

This repository contains a SwiftUI demo app that simulates a real-world merchant application, featuring a store, cart, and checkout process. <br>The goal of this app is to showcase core features of the PayPal iOS SDK, providing merchants with sample code and implementation patterns to simplify integration.

**🚀 Version 1.0 Features**

Checkout with PayPal<br>
Seamless PayPal checkout experience<br>
Checkout with Cards

**🎯 Purpose**
This demo app serves as a reference for merchants, aligning with real-world patterns and code structures they are likely to adopt.<br> By providing a practical and easy-to-follow example, we aim to make PayPal SDK integration smoother and faster for developers.

**📂 Project Structure**
- **Where to find key logic**<br>
If you are just interested in code to implement server side and SDK API calls, you can skip to `CardPaymentViewModel` or `PayPalViewModel`

- **CheckoutFlow**<br>
 SwiftUI view that is the entry point for the checkout process. It sets up the overall navigation structure using a `NavigationStack`, so users can move from cart checkout and finally OrderCompletion
- **CheckoutCoordinator (Navigation and Flow Manager)**<br>
Handles navigation logic and handles loading and error states of flows that do not have a dedicated SwiftUI view (e.g., PayPal Web Checkout)
- **CartView**<br>
Displays items in the cart and total amount<br>
Buttons to initiate Card or PayPalWeb checkout<br>
Tapping either calls into a `CheckoutCoordinator` that starts the respective flow
- **Card Checkout**<br>
This uses a SwiftUI screen called `CardCheckoutView` which references a `CardPaymentViewModel`<br>
The view model handles network calls for creating order, approving the card and final capture<br>
When complete, the user is navigated to `OrderCompleteView`
- **PayPal Web Checkout**<br>
No dedicated SwiftUI screen - once triggered, it opens a web flow<br>
Becuase there is no dedicated PayPal view, we handle loading and errors in a `CheckoutCoordinator`<br>
If the user completes the PayPal flow, we capture the order and show `OrderCompleteView` 


**🔧 Requirements**

Xcode 15.0+
iOS 15.0+
PayPal iOS SDK


**🛠 Setup**

Clone this repository:
bash
Copy code
git clone https://github.com/paypal-examples/paypal-ios-sdk-demo-app.git
cd paypal-ios-sdk-demo-app
Open the project in Xcode.
Run the app on a simulator or device.
