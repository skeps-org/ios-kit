//
//  ContentView.swift
//  IOS_SDK
//
//  Created by dev tushar on 19/04/23.
//

import SwiftUI
import Foundation
struct ContentView: View {
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
    
    var body: some View {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
