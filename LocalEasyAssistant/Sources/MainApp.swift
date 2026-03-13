import SwiftUI

@main
struct LocalEasyAssistantApp: App {
    @StateObject private var llmManager = LocalLLMManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(llmManager)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var llmManager: LocalLLMManager
    
    var body: some View {
        if llmManager.session != nil {
            ChatView()
        } else {
            VStack(spacing: 20) {
                Image(systemName: "brain.head.profile.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("LocalEasyAssistant")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if llmManager.isDownloading {
                    ProgressView("Downloading Model...", value: llmManager.downloadProgress, total: 1.0)
                        .padding()
                } else if let error = llmManager.error {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Retry") {
                        Task {
                            await llmManager.setup()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Text("Ready to start his locally.")
                        .foregroundColor(.secondary)
                    
                    Button("Download & Setup Model") {
                        Task {
                            await llmManager.setup()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }
}
