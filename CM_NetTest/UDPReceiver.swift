import Foundation
import Network
import Darwin

class UDPReceiver: ObservableObject {
    private var socket: Int32 = -1
    @Published var messageReceived = false
    @Published var isConnected = false
    @Published var lastMessage = ""
    @Published var messageHistory: [MessageData] = []
    
    private var isListening = false
    private let queue = DispatchQueue(label: "udp.receiver")
    private var deviceMessages: [String: MessageData] = [:] // Track messages by IP
    
    func startListening() {
        guard !isListening else { return }
        isListening = true
        
        queue.async { [weak self] in
            self?.setupSocket()
        }
    }
    
    private func setupSocket() {
        // Create UDP socket
        socket = Darwin.socket(AF_INET, SOCK_DGRAM, 0)
        guard socket >= 0 else {
            print("Failed to create socket")
            return
        }
        
        // Enable address reuse
        var reuse = 1
        setsockopt(socket, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(MemoryLayout<Int32>.size))
        
        // Bind to port 9000
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = UInt16(9000).bigEndian
        addr.sin_addr.s_addr = INADDR_ANY
        addr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        
        let bindResult = withUnsafePointer(to: addr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { addr in
                Darwin.bind(socket, addr, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        
        guard bindResult == 0 else {
            print("Failed to bind socket")
            close(socket)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.isConnected = true
        }
        
        // Start receiving
        receiveMessages()
    }
    
    private func receiveMessages() {
        while isListening {
            var buffer = [UInt8](repeating: 0, count: 1024)
            var addr = sockaddr_in()
            var addrLen = socklen_t(MemoryLayout<sockaddr_in>.size)
            
            let bytesRead = withUnsafeMutablePointer(to: &addr) { ptr in
                ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { addr in
                    Darwin.recvfrom(socket, &buffer, buffer.count, 0, addr, &addrLen)
                }
            }
            
            if bytesRead > 0 {
                let data = Data(bytes: buffer, count: bytesRead)
                if let message = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async { [weak self] in
                        self?.processNewMessage(message)
                    }
                }
            }
        }
    }
    
    private func processNewMessage(_ message: String) {
        let messageData = MessageData(rawMessage: message)
        let deviceIP = messageData.ipAddress
        
        // Always flash green circle and update last message
        messageReceived = false
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Update device message cache
            self.deviceMessages[deviceIP] = messageData
            
            // Always update the existing entry or add a new one
            if let index = self.messageHistory.firstIndex(where: { $0.ipAddress == deviceIP }) {
                // Update existing entry with new timestamp
                self.messageHistory[index] = messageData
            } else {
                // Add new entry
                self.messageHistory.append(messageData)
            }
            
            // Update last message
            self.lastMessage = messageData.message
            
            // Always trigger the green circle
            self.messageReceived = true
            
            // Reset message received indicator after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.messageReceived = false
            }
        }
    }
    
    deinit {
        isListening = false
        if socket >= 0 {
            close(socket)
        }
    }
} 