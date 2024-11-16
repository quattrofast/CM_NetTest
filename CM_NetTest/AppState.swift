import SwiftUI

class AppState: ObservableObject {
    @Published var udpMessageReceived = false
    @Published var udpConnected = false
    @Published var lastMessage = ""
    @Published var messageHistory: [MessageData] = []
    
    // Create a single instance of UDPReceiver
    private static let udpReceiver = UDPReceiver()
    
    init() {
        // Start UDP listener only once when AppState is initialized
        Self.udpReceiver.startListening()
        
        // Observe UDP message received status and content
        Self.udpReceiver.$messageReceived
            .assign(to: &$udpMessageReceived)
        
        // Observe UDP connection status
        Self.udpReceiver.$isConnected
            .assign(to: &$udpConnected)
            
        // Observe last message
        Self.udpReceiver.$lastMessage
            .assign(to: &$lastMessage)
            
        // Observe message history
        Self.udpReceiver.$messageHistory
            .assign(to: &$messageHistory)
    }
} 