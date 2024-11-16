import Foundation

struct MessageData: Identifiable {
    let id = UUID()
    let message: String
    let deviceName: String
    let version: String
    let ipAddress: String
    let deviceId: String
    let deviceType: String
    let serialNumber: String
    let timestamp: Date
    
    var isStale: Bool {
        return Date().timeIntervalSince(timestamp) > 10
    }
    
    init(rawMessage: String) {
        // Default values
        var msg = ""
        var name = ""
        var ver = ""
        var ip = ""
        var did = ""
        var dtype = ""
        var serial = ""
        
        // Split and parse the message
        let parts = rawMessage.components(separatedBy: ":")
        for part in parts {
            let components = part.components(separatedBy: "~")
            if components.count == 2 {
                switch components[0] {
                case "0": msg = components[1]
                case "1": name = components[1]
                case "3": ver = components[1]
                case "4": ip = components[1]
                case "5": did = components[1]
                case "6": dtype = components[1]
                case "7": serial = components[1]
                default: break
                }
            }
        }
        
        self.message = msg
        self.deviceName = name
        self.version = ver
        self.ipAddress = ip
        self.deviceId = did
        self.deviceType = dtype
        self.serialNumber = serial
        self.timestamp = Date()
    }
} 