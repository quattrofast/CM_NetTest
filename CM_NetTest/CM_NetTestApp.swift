//
//  CM_NetTestApp.swift
//  CM_NetTest
//
//  Created by peter hearl on 15/11/2024.
//

import SwiftUI

@main
struct CM_NetTestApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
