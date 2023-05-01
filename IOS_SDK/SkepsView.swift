//
//  ContentView.swift
//
//  Created by dev tushar on 23/04/23.
//
import SwiftUI
import WebKit

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
