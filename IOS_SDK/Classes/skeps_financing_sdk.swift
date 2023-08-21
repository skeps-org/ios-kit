
//  IOS_SDKApp.swift
//  IOS_SDK
//
//  Created by dev tushar on 21/08/23.
//

import SwiftUI

public protocol childViewControllerOneDelegate {
    func getSkepsEvent(takeIn name: String,orderId:String, transactionId:String) -> Void
}

public struct IOS_SDKApp: View {
    @ObservedObject var network:Network = Network()
    @Environment(\.presentationMode) var presentationMode : Binding<PresentationMode>
    public var delegate : childViewControllerOneDelegate?
    
    let content = ContentView.self
    @State var merchantId: String
    @State var amount: String
    @State var offlineURL: String
    @State var baseURL: String
    @State var type: String
    
    public init(merchantId: String, amount: String, offlineURL: String, baseURL: String, type: String,flag:String) {
        _merchantId =  State(initialValue: merchantId)
        _amount =  State(initialValue: amount)
        _offlineURL =  State(initialValue: offlineURL)
        _baseURL =  State(initialValue: baseURL)
        _type =  State(initialValue: type)
        network.EnteredAmount = amount
        network.EnteredURL = baseURL != "" ? baseURL : "https://pos.test.skeps.com"
        network.merchantId = merchantId
        network.modeType = type
        if(type == "checkout"){
            handleCheckout()
        }
        if(type == "eligibility"){
            handleEligibility()
        }
    }
    
    func handleEligibility() {
        network.checkEligiblityService(merchantId:merchantId)
    }
    
    //     Handle Check-out button
    func handleCheckout(){
        network.getUsers(merchantId:merchantId)
    }
    
    
    
    func closeSubView(value:String,orderId:String,transactionId:String){
        self.delegate?.getSkepsEvent(takeIn: "\(value)",orderId: orderId,transactionId: transactionId)
    }
    
    public var body: some View {
        NavigationView {
            //       ContentView(merchantId: $merchantId)
            SkepsView(function: { value,orderId,transactionId  in self.closeSubView(value: value,orderId:orderId,transactionId:transactionId) })
            Button(action: {
                //                closeSubView(value: "String")
            }) {
                Text("Offline flow : Checkout").padding(.horizontal, 16)
            }.buttonStyle(.borderedProminent).frame(width: 900, height: 80, alignment: .center)
            
        }.environmentObject(network)
    }
}

//
//  ContentView.swift
//  IOS_SDK
//
//  Created by dev tushar on 22/04/23.
//

import SwiftUI
import Foundation
public struct ContentView: View {
    //    @Binding merchantId
    @EnvironmentObject var network: Network
    @State var amount = "400"
    @Binding var merchantId:String
    @State var baseURL = "https://pos.test.skeps.com"
    @State var offlineURL = "https://pos.test.skeps.com/application/qr?hash=KZcfjbmS1j90tjpszDTldpu72gWeqZZW930y8r4%2Bfnjpu4XS1uzPEUW4HIgz01LrHNmAtEJh8Fb1Hqc8TcOmLWORipbs0xyHHPugXK6LFvGtKyNmYVOJ%2FYM0jlssUcCBjKPq9sJT%2B3SRZaVDhFZMH0fnNhCGPlv2gTW3ZC29u7Y%3D"
    @State var answer = true
    @State private var showingAlert = false;
    
    
    
    //    Handle Check-eligibility button
    func handleEligibility() {
        if(amount == "" || merchantId == ""){
            showingAlert = true
        }
        else{
            answer = true
            // API call
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
        ContentView(merchantId: .constant("LDDDDD"))
    }
}

import SwiftUI

class Test: ObservableObject {
    @Published var users: String? = String()
}




public class Network: ObservableObject {
    @Published var users: User?
    @Published var eligibilityData: EligibilityType?
    @Published var routerActive: String?=""
    @Published var fieldBeingEdited = false
    @Published var EnteredAmount = ""
    @Published var EnteredURL = ""
    @Published var merchantId = ""
    @Published var modeType = ""
    @Published var webViewStatus = ""
    @Published var responseValue = ""
    @Published var isLoading = true
    @Published var downloadPassed  = false
    @Published var isBlobDownload = false
    @Published var showingScore = false
    @Published var dialogTitle = ""
    @Published var dialogMessage = ""
    public init(){}
    func getUsers(merchantId : String) {
        guard let url = URL(string: "\(self.EnteredURL)/application/api/pos/v1/oauth/merchant/generate/checkout/hash?merchantId=\(merchantId)") else {
            fatalError("Missing URL")
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
    
    func checkEligiblityService(merchantId : String) {
        guard let url = URL(string: "\(self.EnteredURL)/application/api/pos/v1/financing/getEligibleOffersForCIN/") else { fatalError("Missing URL")
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(merchantId, forHTTPHeaderField: "merchant_id")
        urlRequest.httpMethod = "post"
        let parameters:[String:Any] = [
            "currency": "USD",
            "amount": Int(self.EnteredAmount)
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
//  Created by dev tushar on 01/05/23.
//
import SwiftUI
import WebKit
import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
//import AppKit


struct WebView: UIViewRepresentable {
    @EnvironmentObject var network: Network
    @Environment(\.presentationMode) var mode2: Binding<PresentationMode>
    @State var merchantId:String = ""
//    @Binding var showingScore : Bool
    @Binding var wrapper : PresentationMode
    var function: (_ value:String,_ orderId: String,_ transactionId : String) -> Void
    
    func blobDownloadWith(jsonString: String,netWorkService:Network) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Cannot convert blob JSON into data!")
            return
        }
        
        let decoder = JSONDecoder()
        
        do {
            let file = try decoder.decode(BlobComponents.self, from: jsonData)
            
            guard let data = Data(base64Encoded: file.dataString),
                  let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, file.mimeType as CFString, nil),
                  let ext = UTTypeCopyPreferredTagWithClass(uti.takeRetainedValue(), kUTTagClassFilenameExtension)
            else {
                //                print("Error! \(error)")
                return
            }
            print(file.url)
            let fileName = file.url.components(separatedBy: "/").last ?? "unknown"
            let path = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!)
            let url = path.appendingPathComponent("skeps_doc-\(fileName).\(ext.takeRetainedValue())")
            try data.write(to: url)
            let pdfData = try? Data.init(contentsOf: url)
            let pdfFileName =  String((url.lastPathComponent)) as NSString
            let filePath = path.appendingPathComponent(pdfFileName as String)
            do {
                try pdfData?.write(to: filePath,options: .atomic)
                netWorkService.isLoading = false
                netWorkService.downloadPassed = true
                netWorkService.dialogTitle = "Success"
                netWorkService.dialogMessage = "File has been downloaded."
                print("File Saved blob")
            } catch {
                print("Some Error in code")
            }
        }
        catch {
            print("Error! \(error)")
            return
        }
    }
    
    static func loadFileSync(url: URL,netWork1:Network, completion: @escaping (String?, Error?) -> Void)
    {
        var group = DispatchGroup()
        let bgQueue = DispatchQueue.global(qos: .background)
        group.enter()
        func doSomething(network1 : Network,callback: @escaping (Bool) -> Void) {
            netWork1.isLoading = true
            bgQueue.asyncAfter(deadline: .now()) {
                let url = url
                let pdfData = try? Data.init(contentsOf: url)
                let resDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!) as URL
                var pdfFileName =  String((url.lastPathComponent)) as NSString
                pdfFileName = ((pdfFileName as String) + ".pdf") as NSString
                let filePath = resDocPath.appendingPathComponent(pdfFileName as String)
                do {
                    try pdfData?.write(to: filePath,options: .atomic)
                    netWork1.isLoading = false
                    netWork1.downloadPassed = true
                    netWork1.dialogTitle = "Success"
                    netWork1.dialogMessage = "File has been downloaded."
                    print("File Saved")
                    callback(true)
                } catch {
                    print("Some Error in code")
                }
            }
        }
        
        group.enter()
        doSomething(network1 : netWork1) { (success) in
                if success {
                    netWork1.isLoading = false
                    netWork1.downloadPassed = true
                    netWork1.dialogTitle = "Success"
                    netWork1.dialogMessage = "File has been downloaded."
                }

                print("Finished request")
                group.leave()
            }
        
        group.notify(queue: .main) {
       
        }
        
//        netWork1.isLoading = true
       DispatchQueue.main.async {
//            let url = url
//            let pdfData = try? Data.init(contentsOf: url)
//            let resDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!) as URL
//            var pdfFileName =  String((url.lastPathComponent)) as NSString
//            pdfFileName = ((pdfFileName as String) + ".pdf") as NSString
//            let filePath = resDocPath.appendingPathComponent(pdfFileName as String)
//            do {
//                try pdfData?.write(to: filePath,options: .atomic)
////                netWork1.isLoading = false
//                netWork1.downloadPassed = true
//                print("File Saved")
//            } catch {
//                print("Some Error in code")
//            }
            
        }
    }
    
    
    //    Class Cordinator for E2E webview configurations.
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
        var webView: WKWebView?
        var popupWebView: WKWebView?
        @EnvironmentObject var network: Network
        //        Get Parent struct data to access close navigate function
        let parent: WebView
        
        init(_ parent: WebView) {
            //            webView?.removeConstraints((webView?.constraints)!)
            self.parent = parent
            
        }
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            let url = navigationAction.request.url
            if(url?.absoluteString.range(of: "pdf") != nil){
//                self.parent.network.isLoading = true
            }
            if navigationAction.targetFrame == nil {
                //                webView.load(navigationAction.request)
                popupWebView = WKWebView(frame: .zero, configuration: configuration)
                popupWebView!.navigationDelegate = self
                popupWebView!.uiDelegate = self
                webView.addSubview(popupWebView!)
                popupWebView!.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    popupWebView!.topAnchor.constraint(equalTo: webView.topAnchor),
                    popupWebView!.bottomAnchor.constraint(equalTo:webView.bottomAnchor),
                    popupWebView!.leadingAnchor.constraint(equalTo:webView.leadingAnchor),
                    popupWebView!.trailingAnchor.constraint(equalTo: webView.trailingAnchor)
                ])
                return popupWebView
            }
            
            return nil
        }
        
        func webViewDidClose(_ webView: WKWebView) {
            webView.removeFromSuperview()
            popupWebView = nil
        }
        
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
                if let url = navigationAction.request.url, let scheme = url.scheme?.lowercased() {
                    debugPrint("1212\(url)")
                    if (scheme == "blob" && parent.network.isBlobDownload == true) {
                        // Defer to JS handling
                        parent.network.isLoading = true
                        executeBlobDownloadJS(url: url)
                        decisionHandler(.cancel)
                        webView.removeFromSuperview()
                        popupWebView = nil
                    }
                    else{
                        decisionHandler(.allow)
//                        let url = navigationAction.request.url
//                        var extractedURL = URL(string: url!.absoluteString)
//                        if(url?.absoluteString.range(of: "pdf") != nil || url?.absoluteString.range(of: "downloadAgreement") != nil){
//                            webView.removeFromSuperview()
//                            popupWebView = nil
//                            WebView.loadFileSync(url: extractedURL!,netWork1: parent.network) { (path, error) in
//                                print("PDF File downloaded to : \(path!)")
//                            }}
//
                    }
                }
        }
        

        
        func executeBlobDownloadJS(url : URL){
            let downloadJS =  """
             function blobToDataURL(blob, callback) {
                var reader = new FileReader()
                reader.onload = function(e) {callback(e.target.result.split(",")[1])}
                reader.readAsDataURL(blob)
             }
             
             async function run() {
                const url = "\(url)"
                const blob = await fetch(url).then(r => r.blob())
                blobToDataURL(blob, datauri => {
                    const responseObj = {
                    url: url,
                    mimeType: blob.type,
                    size: blob.size,
                    dataString: datauri
                    }
                    window.webkit.messageHandlers.jsListener.postMessage(JSON.stringify(responseObj))
                })
             }
             run()
             """
            webView?.evaluateJavaScript(downloadJS,completionHandler: nil)
            
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
            webView.uiDelegate = self
            webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
            self.webView = webView
        }
        
        //         Handle event and navigate to back view after success or failure
        func handleEvent(dict: NSDictionary) {
            let type = dict["type"] as? String ?? ""
            let orderId = dict["orderId"] as? String ?? ""
            let transactionId = dict["transactionId"] as? String ?? ""
            let triggerReason = dict["triggerReason"] as? String ?? ""
            if(type == "failure" || type == "success" || type == "checkEligibilitySuccess" ){
                parent.function(type,orderId,transactionId)
                parent.$wrapper.wrappedValue.dismiss()
            }
            if(type == "hideLoader"){
                parent.network.isLoading = false
            }
            if(triggerReason == "apiError"){
                parent.network.showingScore = true
                parent.network.downloadPassed = true
                parent.network.dialogTitle = "Error"
                parent.network.dialogMessage = "Something went wrong."
            }
            if(type == "loaded" && parent.network.showingScore  == false){
                if(parent.network.modeType == "checkout"){
                    var jsConfig = ""
                                        jsConfig = """
                                         setTimeout(()=>{
                                             window.postMessage({event:'initialize', sourceType :'SKEPS_INTEGRATED_MERCHANT',config: {cartAmount: \(parent.network.EnteredAmount),mode: 'modal',platform:'ios-sdk'}},'*')
                                         },1000)
                                     """
//                    jsConfig = """
//                    window.postMessage({event:'initialize',sourceType :'SKEPS_INTEGRATED_MERCHANT',config: {
//                                        mode:'modal',
//                                        merchantId: 'LUXMFDFL',
//                                        orderId: '2RSbbwdu2p5SwQ1zIMNbio8UabU',storeId: '11',
//                                        accessToken:'
//                 eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjbGllbnRJZCI6ImQxNmYwZmI3LThhY2UtNDk2Mi05NTg3LTFkZjczMzE1N2ZkZCIsImFjY2Vzc0tleUNyZWF0aW9uRGF0ZVRpbWUiOiIyMDIzLTA2LTIwIDA3OjM1OjA0LjA0MSIsIm1lcmNoYW50SWQiOiJMVVhNRkRGTCIsInRyYW5zYWN0aW9uSWQiOiIyUlNiYndkdTJwNVN3UTF6SU1OYmlvOFVhYlUiLCJzdG9yZUlkIjoxMSwiaWF0IjoxNjg3MjQ2NTA0LCJleHAiOjE2ODcyNDgzMzR9.DKxsRaLG-rwY4kjZpKaDnl9VGfwZXgVGKp6dxlDelLU',
//                                        cartAmount: 3102.7,
//                                        customerDetails: {
//                                        firstName: 'MICHAEL',
//                                        lastName: 'CIDLETTI',
//                                        email: 'lakshay+6000009372@gmail.com',
//                                        dob: '1999-05-14',
//                                        streetAddress: '33 CENTRAL AVE',
//                                        city: '',
//                                        state: '',
//                                        zipcode: '15137',
//                                        phoneNumber: '6000032945',
//                                        },
//                                        billingDetails:{
//                                        streetAddress: '33 CENTRAL AVE',
//                                        city: 'Montgomery',
//                                        state: 'AL',
//                                        zipcode: '15137'
//                                        }}}, 'http://localhost:4200/')
//                 """
                    webView?.evaluateJavaScript(jsConfig,completionHandler: nil)
                }
                else if(parent.network.modeType == "eligibility"){
                    let jsConfig = """
                                  setTimeout(()=>{
                                      window.postMessage({event:'check-eligibility', sourceType :'SKEPS_INTEGRATED_MERCHANT',config: {mode: 'modal',platform:'ios-sdk',merchantId:'\(parent.network.merchantId)',cartAmount:\(parent.network.EnteredAmount)}}, '*')
                                },1000)
                              """
                    webView?.evaluateJavaScript(jsConfig,completionHandler: nil)
                }
            }
        }
        
        func handleGetCheckOut(){
            
        }
        
        
        // receive message from parent party
        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage
        ) {
            print(message.body)
            if(message.name == "skepsMessageHandler"){
                handleEvent(dict: message.body as! NSDictionary)
            }
            else if(message.name == "skepsDownloadHandler"){
//                parent.network.isLoading = true
                let decoder = JSONDecoder()
                debugPrint(message.body)
                guard let downloadFakeData = message.body as? String else {
                    return
                }
                guard let downloadData = downloadFakeData.data(using: .utf8) else {
                    print("Cannot convert blob JSON into data!")
                    return
                }
                do{
                    let downloadSchema = try decoder.decode(downloadDataSchema.self, from: downloadData)
                    parent.network.isBlobDownload = downloadSchema.type == "decline" ? true : false
                    if let url = URL(string:downloadSchema.downloadURL),
                       let scheme = url.scheme?.lowercased() {
                        debugPrint("1212\(url)")
                        if scheme == "blob" {
                            // Defer to JS handling
//                            parent.network.isLoading = true
//                            executeBlobDownloadJS(url: url)
                            //decisionHandler(.cancel)
                        }
                        else{
                            var extractedURL = URL(string: url.absoluteString)
                            WebView.loadFileSync(url: extractedURL!,netWork1: parent.network) { (path, error) in
                                print("PDF File downloaded to : \(path!)")
                            }
                        }
                   }
                }
                catch{
                    print("error")
                }
            }
            
            else if(message.name == "jsListener"){
                guard let jsonString = message.body as? String else {
                    return
                }
                parent.blobDownloadWith(jsonString: jsonString,netWorkService: parent.network)
            }
            
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
        userContentController.add(context.coordinator, name: "jsListener")
        userContentController.add(context.coordinator, name: "skepsDownloadHandler")
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true;
        //        configuration.preferences.javaScriptEnabled = true;
        let _wkwebview = WKWebView(frame: .zero, configuration: configuration)
        _wkwebview.navigationDelegate = coordinator
        return _wkwebview
    }
    
    
    //    Webview UI render
    func updateUIView(_ webView: WKWebView, context: Context) {
        let date = NSDate();
        let currentTime = Int64(date.timeIntervalSince1970 * 1000)
        var mode = ""
        if(network.responseValue != "success"){
            if(network.modeType == "checkout"){
                var request1=URLRequest(url:URL(string: "https://pos.test.skeps.com")!)
                guard let url = URL(string: "\(network.EnteredURL)/application/api/pos/v1/oauth/merchant/generate/checkout/hash?merchantId=\(network.merchantId)") else {
                    fatalError("Missing URL")
                }
                
                let urlRequest = URLRequest(url: url)
                let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                    if let error = error {
                        print("Request error: ", error)
                        network.responseValue = ""
                        network.showingScore =  true
                        network.responseValue = "success"
                        network.downloadPassed = true
                        network.dialogTitle = "Error"
                        network.dialogMessage = "Something went wrong."
                        return
                    }
                    guard let response = response as? HTTPURLResponse else { return }
                    if response.statusCode == 200 {
                        network.responseValue = "success"
                        guard let data = data else { return }
                        DispatchQueue.main.async {
                            do {
                                print("sssss\(data)")
                                let decodedUsers = try JSONDecoder().decode(User.self, from: data)
//                                self.routerActive = decodedUsers.merchantInfo.checkoutLandingUrlPath
                                request1 = URLRequest(url:URL(string: "\(network.EnteredURL)\(decodedUsers.merchantInfo.checkoutLandingUrlPath)&_=\(currentTime)&order_amount=\(network.EnteredAmount)")!)
//                                request1 = URLRequest(url: URL(string:"http://localhost:4200/?_=jhfdujkfkhej")!)
                                webView.load(request1)
                            } catch let error {
                                print("Error decoding: ", error)
                                network.isLoading = false
                                network.downloadPassed = true
                                network.dialogTitle = "Error"
                                network.dialogMessage = "Something went wrong."
                               
                            }
                        }
                        
                    }
                    else{
                        network.responseValue = "success"
                        network.showingScore = true
                        network.downloadPassed = true
                        network.dialogTitle = "Error"
                        network.dialogMessage = "Something went wrong."
                    }
                }
                
                dataTask.resume()
            }
            else if(network.modeType == "eligibility"){
                guard let url = URL(string: "\(network.EnteredURL)/application/api/pos/v1/financing/getEligibleOffersForCIN/") else { fatalError("Missing URL")
                }
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.setValue(network.merchantId, forHTTPHeaderField: "merchant_id")
                urlRequest.httpMethod = "post"
                let parameters:[String:Any] = [
                    "currency": "USD",
                    "amount": Int(network.EnteredAmount)
                ]
                let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
                urlRequest.httpBody = jsonData;
                let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                    if let error = error {
                        print("Request error: ", error)
                        return
                    }
                    guard let response = response as? HTTPURLResponse else { return }
                    if response.statusCode == 200 {
                        network.responseValue = "success"
                        guard let data = data else { return }
                        DispatchQueue.main.async {
                            do {
                                let decoder = JSONDecoder()
                                let messages = try decoder.decode(EligibilityType.self, from: data)
                                //                                self.routerActive = messages.landing_url_path
                                let request1 = URLRequest(url:URL(string: "\(network.EnteredURL)\(messages.landing_url_path)")!)
                                webView.load(request1)
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
                    else{
                        network.responseValue = "success"
                        network.showingScore = true
                        network.downloadPassed = true
                        network.dialogTitle = "Error"
                        network.dialogMessage = "Something went wrong."
                    }
                }
                
                dataTask.resume()
            }
        }
    }
}

struct SkepsView: View {
    @EnvironmentObject var network: Network
    @Environment(\.presentationMode) var mode3: Binding<PresentationMode>
    var function: (_ value:String,_ orderId: String,_ transactionId : String) -> Void
    
    var body: some View {
        VStack() {
            LoadingView(isShowing: $network.isLoading) {
                WebView(wrapper:mode3,function: { value,orderId,transactionId  in self.function(value,orderId,transactionId) }).environmentObject(self.network).alert(isPresented: $network.showingScore) {
                    Alert(
                        title: Text("Error!!"),
                        message: Text("Something went wrong."),
                        dismissButton: .default(Text("Ok"), action: {
                            network.showingScore = false
                            network.routerActive = "finished"
                            self.function("failure","","")
                        })
                    )
                }.alert(isPresented: $network.downloadPassed) {
                    Alert(
                        title: Text(network.dialogTitle),
                        message: Text(network.dialogMessage),
                        dismissButton: .default(Text("Ok"), action: {
                            if(network.dialogTitle == "Error"){
                                network.routerActive = "finished"
                                self.function("failure","","")
                            }
                            else if(network.dialogTitle == "Success"){
//                               Nothing to do
                            }
                        })
                    )
                }
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

// Loader view
struct LoadingView<Content>: View where Content: View {
    @Binding var isShowing: Bool
    var content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)
                
                VStack {
                    Text("Loading...")
                    ActivityIndicatorView(isAnimating: .constant(true), style: .large)
                }
                .frame(width: geometry.size.width / 2, height: geometry.size.height / 5)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.blue)
                .cornerRadius(20)
                .opacity(self.isShowing ? 1 : 0)
                
            }
        }
    }
}

// Create circle loader animation view
struct ActivityIndicatorView: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorView>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorView>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct BlobComponents: Codable {
    let url: String
    let mimeType: String
    let size: Int64
    let dataString: String
}

struct downloadDataSchema : Codable {
    let downloadURL : String
    let type : String
}


