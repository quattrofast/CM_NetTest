import SwiftUI

struct IconGenerator: View {
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [.blue, .cyan]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Icon content
            VStack(spacing: 10) {
                Text("CM")
                    .font(.system(size: 400, weight: .bold))
                    .foregroundColor(.white)
                
                Text("NET")
                    .font(.system(size: 200, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .frame(width: 1024, height: 1024)
    }
}

#Preview {
    IconGenerator()
} 