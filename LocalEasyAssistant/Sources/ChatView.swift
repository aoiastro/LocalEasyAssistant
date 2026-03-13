import SwiftUI

struct ChatView: View {
    @EnvironmentObject var llmManager: LocalLLMManager
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        withAnimation {
                            if let last = viewModel.messages.last {
                                proxy.scrollTo(last.id ?? 0, anchor: .bottom)
                            }
                        }
                    }
                }
                
                HStack {
                    TextField("Enter message...", text: $viewModel.inputText)
                        .textFieldStyle(.roundedBorder)
                        .disabled(viewModel.isGenerating)
                    
                    Button(action: {
                        viewModel.sendMessage(llmManager: llmManager)
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(viewModel.isGenerating || viewModel.inputText.isEmpty ? .secondary : .blue)
                    }
                    .disabled(viewModel.isGenerating || viewModel.inputText.isEmpty)
                }
                .padding()
            }
            .navigationTitle("LocalAssistant")
            .navigationBarItems(trailing: Button(role: .destructive) {
                viewModel.clearChat()
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            })
            .onAppear {
                viewModel.loadMessages()
            }
        }
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            Text(message.content)
                .padding(12)
                .background(message.isUser ? Color.blue : Color(.systemGray6))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(16)
                .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser { Spacer() }
        }
    }
}
