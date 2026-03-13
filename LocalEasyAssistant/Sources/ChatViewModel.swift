import Foundation
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText: String = ""
    @Published var isGenerating: Bool = false
    
    private let dbManager = DatabaseManager.shared
    
    func loadMessages() {
        do {
            messages = try dbManager.fetchMessages()
        } catch {
            print("Failed to fetch messages: \(error)")
        }
    }
    
    func sendMessage(llmManager: LocalLLMManager) {
        let userText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userText.isEmpty else { return }
        
        let userMessage = Message(content: userText, isUser: true, timestamp: Date())
        messages.append(userMessage)
        inputText = ""
        
        do {
            try dbManager.saveMessage(userMessage)
        } catch {
            print("Failed to save user message: \(error)")
        }
        
        isGenerating = true
        
        let assistantMessageID = Int64(Date().timeIntervalSince1970)
        var assistantMessage = Message(id: assistantMessageID, content: "", isUser: false, timestamp: Date())
        messages.append(assistantMessage)
        
        let messageIndex = messages.count - 1
        
        Task {
            do {
                for try await text in llmManager.generateResponse(to: userText) {
                    messages[messageIndex].content += text
                }
                
                // Save assistant message when done
                try dbManager.saveMessage(messages[messageIndex])
            } catch {
                messages[messageIndex].content += "\n(Error: \(error.localizedDescription))"
            }
            isGenerating = false
        }
    }
    
    func clearChat() {
        do {
            try dbManager.clearHistory()
            messages = []
        } catch {
            print("Failed to clear history: \(error)")
        }
    }
}
