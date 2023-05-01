//
//  IOS_SDKApp.swift
//  IOS_SDK
//
//  Created by dev tushar on 17/04/23.
//

import SwiftUI

@main
struct IOS_SDKApp: App {
    @ObservedObject var network:Network = Network()
    var body: some Scene {
        WindowGroup {
            NavigationView {
            ContentView()
            }.environmentObject(network)
        }
    }
}
