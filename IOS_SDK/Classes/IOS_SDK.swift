//
//  IOS_SDKApp.swift
//  IOS_SDK
//
//  Created by dev tushar on 17/04/23.
//

import SwiftUI

//@main
public class IOS_SDKApp: UILabel {
    @ObservedObject var network:Network = Network()
    var body: some Scene {
        WindowGroup {
            NavigationView {
                Text("TRextdtdsts")
                ContentView()
            }.environmentObject(network)
            
        }
    }
}

//
//  ContentView.swift
//  IOS_SDK
//
//  Created by dev tushar on 19/04/23.
//

import SwiftUI
import Foundation
public struct ContentView: View {
    @EnvironmentObject var network: Network
    @State var amount = "400"
    @State var merchantId = "YKVABNVB"
    @State var baseURL = "https://pos.test.skeps.com"
    @State var offlineURL = "https://pos.test.skeps.com/application/qr?hash=KZcfjbmS1j90tjpszDTldpu72gWeqZZW930y8r4%2Bfnjpu4XS1uzPEUW4HIgz01LrHNmAtEJh8Fb1Hqc8TcOmLWORipbs0xyHHPugXK6LFvGtKyNmYVOJ%2FYM0jlssUcCBjKPq9sJT%2B3SRZaVDhFZMH0fnNhCGPlv2gTW3ZC29u7Y%3D"
    @State var answer = false
    @State private var showingAlert = false;
    
    //    Handle Check-eligibility button
    func handleEligibility() {
        if(amount == "" || merchantId == ""){
            showingAlert = true
        }
        else{
            answer = true
            //           API call
            network.checkEligiblityService(merchantId:merchantId)
        }
    }
    //     Handle Check-out button
    func handleCheckout(){
        if(amount == "" || merchantId == ""){
            showingAlert = true
        }
        else{
            answer = true
            //            API call
            network.getUsers(merchantId:merchantId)
        }
    }
    
   public var body: some View {
        Form {
            Section(header: Text("Enter below Details:").foregroundColor(.blue)) {
                TextField("Enter Amount", text: $amount)
                TextField("Enter Merchant ID", text: $merchantId)
                TextField("Enter Base URL", text: $baseURL)
                TextField("Enter Offline URL", text: $offlineURL)
            }
            VStack {
                NavigationLink(destination: SkepsView().environmentObject(network), isActive: $answer, label: {
                    Button(action: {
                        handleCheckout()
                    }) {
                        Text("Offline flow : Checkout").padding(.horizontal, 16)
                    }.buttonStyle(.borderedProminent).frame(width: 900, height: 80, alignment: .center)
                })
                Button(action: {
                    
                    handleEligibility()
                }) {
                    Text("Offline flow : Eligiblity").padding(.horizontal, 20)
                }.buttonStyle(.borderedProminent).alert("Please fill all required field", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { }
                }
            }.listRowBackground(Color.clear).navigationBarTitle(Text("Welcome to Skeps"), displayMode: .inline)
            
            
        }
    }
}

public struct ContentView_Previews: PreviewProvider {
  public static var previews: some View {
        ContentView()
    }
}

import SwiftUI

class Test: ObservableObject {
    @Published var users: String? = String()
}




class Network: ObservableObject {
    @Published var users: User?
    @Published var eligibilityData: EligibilityType?
    @Published var routerActive: String?=""
    @Published var fieldBeingEdited = false
    
    
    func getUsers(merchantId : String) {
        
        guard let url = URL(string: "https://fnbo-dev.skeps.dev/application/api/pos/v1/oauth/merchant/generate/checkout/hash?merchantId=\(merchantId)") else {
            fatalError("Missing URL")
//            YKVABNVB
        }

        let urlRequest = URLRequest(url: url)

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }

            guard let response = response as? HTTPURLResponse else { return }
            if response.statusCode == 200 {
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        let decodedUsers = try JSONDecoder().decode(User.self, from: data)
                        self.users = decodedUsers
                        self.routerActive = decodedUsers.merchantInfo.checkoutLandingUrlPath
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            }
        }

        dataTask.resume()
    }
    
//    ----------
    func checkEligiblityService(merchantId : String) {
        debugPrint(merchantId)
        guard let url = URL(string: "https://fnbo-dev.skeps.dev/application/api/pos/v1/financing/getEligibleOffersForCIN/") else { fatalError("Missing URL")
//            YKVABNVB
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(merchantId, forHTTPHeaderField: "merchant_id")
        urlRequest.httpMethod = "post"
        let parameters:[String:Any] = [
            "currency": "USD",
            "amount": 400
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
        urlRequest.httpBody = jsonData;
          let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            guard let response = response as? HTTPURLResponse else { return }
            debugPrint("response.statusCode\(response.statusCode)")
            if response.statusCode == 200 {
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        let decoder = JSONDecoder()
                        let messages = try decoder.decode(EligibilityType.self, from: data)
                        self.routerActive = messages.landing_url_path
                        debugPrint(messages as Any)
                        debugPrint("response.body\(messages.landing_url_path)")
                    } catch DecodingError.dataCorrupted(let context) {
                        debugPrint(context)
                    } catch DecodingError.keyNotFound(let key, let context) {
                        debugPrint("Key '\(key)' not found:", context.debugDescription)
                        debugPrint("codingPath:", context.codingPath)
                    } catch DecodingError.valueNotFound(let value, let context) {
                        debugPrint("Value '\(value)' not found:", context.debugDescription)
                        debugPrint("codingPath:", context.codingPath)
                    } catch DecodingError.typeMismatch(let type, let context) {
                        debugPrint("Type '\(type)' mismatch:", context.debugDescription)
                        debugPrint("codingPath:", context.codingPath)
                    } catch {
                        debugPrint("error: ", error)
                    }
                }
            }
        }

        dataTask.resume()
    }
}

//
//  ContentView.swift
//
//  Created by dev tushar on 23/04/23.
//
import SwiftUI
import WebKit
import UIKit
//import AppKit

struct WebView: UIViewRepresentable {
    @EnvironmentObject var network: Network
    @Environment(\.presentationMode) var mode2: Binding<PresentationMode>
    @State var merchantId:String = ""
    @Binding var showingScore : Bool
    //    Class Cordinator for E2E webview configurations.
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var webView: WKWebView?
        @EnvironmentObject var network: Network
//        @Environment(\.presentationMode) var mode3: Binding<PresentationMode>
        
        //        Get Parent struct data to access close navigate function
        let parent: WebView
        init(_ parent: WebView) {
//            webView?.removeConstraints((webView?.constraints)!)
            self.parent = parent
        }
        //         Run while error occurs due to any extrenal failure
        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            if (error as NSError).code == -999 {
                return
            }
            
            print(error)
        }
        // Run while error occurs due to any frame initialization failure
        public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            if (error as NSError).code == -999 {
            }
            print(error)
        }
        
        //       Default hook for web veiw
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.navigationDelegate = self
            self.webView = webView
        }
        
        
        
        //         Handle event and navigate to back view after success or failure
        func handleEvent(dict: NSDictionary) {
            let type = dict["type"] as? String ?? ""
            if(type == "failure" || type == "success" ){
                parent.mode2.wrappedValue.dismiss()
            }
        }
        
        // receive message from parent party
        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage
        ) {
            print(message.body)
            handleEvent(dict: message.body as! NSDictionary)
        }
        
    }
    
    // Initialize co-ordinator (first run)
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    //     handle bridge between view and parent party
    func makeUIView(context: Context) -> WKWebView {
        let coordinator = makeCoordinator()
        let userContentController = WKUserContentController()
        userContentController.add(coordinator, name: "skepsMessageHandler")
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        let _wkwebview = WKWebView(frame: .zero, configuration: configuration)
        _wkwebview.navigationDelegate = coordinator
        return _wkwebview
    }
    
    //    Get query params data
    func getQueryItems(_ urlString: String) -> [String : String] {
        var queryItems: [String : String] = [:]
        let components: NSURLComponents? = getURLComonents(urlString)
        for item in components?.queryItems ?? [] {
            queryItems[item.name] = item.value?.removingPercentEncoding
        }
        return queryItems
    }
    //     Get URL and extract query params
    func getURLComonents(_ urlString: String?) -> NSURLComponents? {
        var components: NSURLComponents? = nil
        let linkUrl = URL(string: urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")
        if let linkUrl = linkUrl {
            components = NSURLComponents(url: linkUrl, resolvingAgainstBaseURL: true)
        }
        return components
    }
    
    //    Webview UI render
    func updateUIView(_ webView: WKWebView, context: Context) {
        let date = NSDate();
        let currentTime = Int64(date.timeIntervalSince1970 * 1000)
        var mode = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if(network.routerActive != ""){
            mode = network.routerActive?.contains("checkout") == true ? "checkout":"eligibility";
            
            var request1=URLRequest(url:URL(string: "https://pos.test.skeps.com")!)
            if(mode == "checkout"){
                request1 = URLRequest(url:URL(string: "https://fnbo-dev.skeps.dev\(network.routerActive!)&_=\(currentTime)&order_amount=400")!)
            }
            else{
                request1 = URLRequest(url:URL(string: "https://fnbo-dev.skeps.dev\(network.routerActive!)")!)
            }
            webView.load(request1)
            }
            else{
               showingScore =  true
            }
        }
        //        Javascript config call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            var jsConfig = ""
            if(mode == "checkout"){
                jsConfig = """
                setTimeout(()=>{
                    window.postMessage({event:'initialize', sourceType :'SKEPS_INTEGRATED_MERCHANT',config: {cartAmount: 400,mode: 'modal'}},'*')
                },1000)
            """
            }
            else{
                let activeELigibilityURL = getQueryItems(webView.url?.absoluteString ?? "");
                  debugPrint(activeELigibilityURL)
                do {
                    let json1 = try! JSONEncoder().encode(activeELigibilityURL)
                    let result = try JSONDecoder().decode(Response.self, from: json1)
                    merchantId = result.merchant_id
                }
                catch let error{
                    print(error)
                }
                jsConfig = """
                setTimeout(()=>{
                    window.postMessage({event:'check-eligibility', sourceType :'SKEPS_INTEGRATED_MERCHANT',config: {mode: 'modal',merchantId:'\(merchantId)',cartAmount:400}}, '*')
              },1000)
            """
            }
            let script = WKUserScript(source: jsConfig, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            webView.configuration.userContentController.addUserScript(script)
        }
    }
    
    
}

struct SkepsView: View {
    @EnvironmentObject var network: Network
    @State var showingScore : Bool = false
    @Environment(\.presentationMode) var mode2: Binding<PresentationMode>

    var body: some View {
        VStack() {
            WebView(showingScore:$showingScore).environmentObject(self.network).alert(isPresented: $showingScore) {
                Alert(
                    title: Text("Error!!"),
                    message: Text("Something went wrong."),
                    dismissButton: .default(Text("Ok"), action: {
                        self.showingScore = false
                        mode2.wrappedValue.dismiss()
                       })
                )
            }
        }
    }
}

import Foundation

struct User: Identifiable, Decodable {
    var id: Int?
    var merchantInfo: MerchantInfo
    
    
    struct MerchantInfo: Decodable {
        var checkoutLandingUrlPath: String
        struct Geo: Decodable {
            var lat: String
            var lng: String
        }
    }
    
    struct Company: Decodable {
        var name: String
        var catchPhrase: String
        var bs: String
    }
}


//
//  eligibilityDecoder.swift
//  IOS_SDK
//
//  Created by dev tushar on 25/04/23.

import Foundation
import SwiftUI

struct Response : Decodable {
    
    private enum CodingKeys : String, CodingKey { case merchant_id,access_token,order_id }
    
    let merchant_id : String
    let access_token : String
    let order_id : String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        merchant_id = try container.decode(String.self, forKey: .merchant_id)
        access_token = try container.decode(String.self, forKey: .access_token)
        order_id = try container.decode(String.self, forKey: .order_id)
    }
}





import Foundation

struct EligibilityType : Identifiable, Decodable {
    var id : Int?
    var customer_details: CustomerDetails
    var offer_data: OfferData
    var offer_type, merchant_name, landing_url_path: String
    var success: Bool?
    
    struct CustomerDetails : Decodable {
        var first_name: String?
    }
    struct OfferData: Decodable  {
//        var offers, worst_offers: [Offer]
//        var expiry: Date
    }

    struct Offer:Decodable {
        var id: String
        var type: TypeEnum
        var lender: Lender
        var firstPaymentUpfront, requiresDownPayment: Bool
        var downPayment, minAmount, maxAmount: Int
        var paymentFrequency: String
        var paymentFrequencyUnit: PaymentFrequencyUnit
        var term: Int
        var termUnit: TermUnit
        var numPayments: Int
        var apr, interestRate: Double
        var isDiscounted, isAutoPayRequired, isPromoApplicable, isLateFeeApplicable: Bool
        var parentOfferID: String?
        var loanAmount, mdr, mdrValue, mdrCents: Int
        var paymentAmount: Double
        var showOffer: Bool
        var paymentScheduler: [PaymentScheduler]
        var totalPayment, totalInterest: Double
    }

    enum Lender:Decodable {
        case fnbo
    }

    enum PaymentFrequencyUnit : Decodable{
        case days
        case month
    }

    struct PaymentScheduler:Decodable {
        var date: String
        var amount: Double
    }

    enum TermUnit : Decodable{
        case days
        case months
    }

    enum TypeEnum: Decodable {
        case interestRateProduct
        case payIn5
    }

}


struct EventType: Decodable {
  let type: String
}
