import Foundation
import LocalLLMClient
import LocalLLMClientLlama

@MainActor
class LocalLLMManager: ObservableObject {
    @Published var session: LLMSession?
    @Published var downloadProgress: Double = 0
    @Published var isDownloading: Bool = false
    @Published var error: String?

    // Using a lightweight model for better mobile performance
    let modelID = "lmstudio-community/gemma-3-4B-it-qat-GGUF"
    let modelFile = "gemma-3-4B-it-QAT-Q4_0.gguf"

    func setup() async {
        let model = LLMSession.DownloadModel.llama(
            id: modelID,
            model: modelFile
        )

        // Check if already downloaded (simplified check)
        // In a real app, you might want to check the filesystem
        
        do {
            isDownloading = true
            try await model.downloadModel { [weak self] progress in
                self?.downloadProgress = progress
            }
            isDownloading = false
            
            session = LLMSession(model: model)
            session?.messages = [.system("あなたは日常生活のあらゆることを手助けする優秀なアシスタント、LocalEasyAssistantです。")]
        } catch {
            self.error = "Error setting up LLM: \(error.localizedDescription)"
            isDownloading = false
        }
    }

    func generateResponse(to prompt: String) -> AsyncThrowingStream<String, Error> {
        guard let session = session else {
            return AsyncThrowingStream { continuation in
                continuation.finish(throwing: NSError(domain: "LocalLLM", code: 1, userInfo: [NSLocalizedDescriptionKey: "Session not ready"]))
            }
        }
        
        return session.streamResponse(to: prompt)
    }
}
