//
//  ContentView.swift
//  CM_NetTest
//
//  Created by peter hearl on 15/11/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentTime = Date()
    @Environment(\.colorScheme) var colorScheme
    
    // Create a timer publisher
    private let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            // Status indicators row
            HStack {
                // UDP Message Indicator (left)
                Circle()
                    .fill(appState.udpMessageReceived ? Color.green : Color.gray)
                    .frame(width: 20, height: 20)
                    .transition(.opacity)
                
                Spacer()
                
                // Title
                Text("CM Network")
                    .font(.headline)
                    .foregroundColor(.black)
                
                Spacer()
                
                // UDP Connection Status Indicator (right)
                if appState.udpConnected {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(10)
            
            // Message History
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(appState.messageHistory) { message in
                        let isStale = Date().timeIntervalSince(message.timestamp) > 10
                        VStack(alignment: .leading) {
                            Text("Device: \(message.deviceName)")
                                .font(.headline)
                            Text("IP: \(message.ipAddress)")
                            Text("ID: \(message.deviceId)")
                            Text("Type: \(message.deviceType)")
                            Text("Version: \(message.version)")
                            Text("S/N: \(message.serialNumber)")
                            Text("Time: \(message.timestamp.formatted())")
                                .font(.caption)
                        }
                        .padding()
                        .background(
                            isStale ?
                            (colorScheme == .dark ? Color.red.opacity(0.3) : Color.red.opacity(0.1)) :
                            Color.gray.opacity(0.1)
                        )
                        .cornerRadius(8)
                        .id("\(message.id)_\(currentTime)")  // Force view update
                    }
                }
                .padding(.horizontal)
            }
        }
        .onReceive(timer) { _ in
            // Update currentTime to force view refresh
            currentTime = Date()
        }
    }
}

#Preview("Light Mode") {
    ContentView()
        .environmentObject({
            let state = AppState()
            state.udpConnected = true
            return state
        }())
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ContentView()
        .environmentObject({
            let state = AppState()
            state.udpConnected = true
            return state
        }())
        .preferredColorScheme(.dark)
}
