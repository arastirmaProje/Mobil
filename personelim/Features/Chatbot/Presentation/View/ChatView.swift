import SwiftUI

struct ChatView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    @StateObject private var vm = ChatViewModel()
    @StateObject private var memberViewModel = BusinessMemberViewModel()
    @StateObject private var departmentViewModel = DepartmentViewModel()

    private var isManagerChat: Bool {
        appState.role.canSeePersonnelTab
    }

    private var businessId: String {
        appState.businessId ?? ""
    }

    private var departmentId: String? {
        nil
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    messagesScrollView
                }

                inputBar
            }
            .navigationTitle(ConstantStrings.chatTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        ChatConversationListView(
                            vm: vm,
                            businessId: businessId,
                            isManagerChat: isManagerChat,
                            departmentId: departmentId
                        )
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
        }.task {
            await memberViewModel.fetchMembers(businessId: businessId)
            await departmentViewModel.fetchDepartments(businessId: businessId)
        }
    }

    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(vm.messages) { message in
                        chatBubble(message)
                            .id(message.id)
                    }

                    if vm.isLoading {
                        typingBubble
                            .id("typing")
                    }

                    if let errorMessage = vm.errorMessage {
                        errorBubble(errorMessage)
                    }

                    Spacer(minLength: 90)
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
            }
            .onChange(of: vm.messages.count) { _, _ in
                scrollToBottom(proxy)
            }
            .onChange(of: vm.isLoading) { _, _ in
                scrollToBottom(proxy)
            }
        }
    }

    private func chatBubble(_ message: ChatMessageEntity) -> some View {
        HStack(alignment: .bottom) {
            if message.isUser {
                Spacer(minLength: 60)
            }

            Text(message.text)
                .font(.system(size: 14))
                .foregroundStyle(message.isUser ? .white : .primary)
                .padding(.horizontal, 13)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(message.isUser ? Color.blue : Color(.systemGray6))
                )
                .frame(
                    maxWidth: 280,
                    alignment: message.isUser ? .trailing : .leading
                )

            if !message.isUser {
                Spacer(minLength: 60)
            }
        }
    }

    private var typingBubble: some View {
        HStack {
            HStack(spacing: 8) {
                ProgressView()
                    .scaleEffect(0.85)

                Text(ConstantStrings.chatLoadingText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemGray6))
            )

            Spacer(minLength: 60)
        }
    }

    private func errorBubble(_ message: String) -> some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)

                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.red.opacity(0.08))
            )

            Spacer(minLength: 60)
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField(
                ConstantStrings.chatPlaceholder,
                text: $vm.messageText,
                axis: .vertical
            )
            .font(.system(size: 14))
            .lineLimit(1...4)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .disabled(vm.isLoading)

            Button {
                Task {
                    let resolved = ChatEntityResolver.resolve(
                        message: vm.messageText,
                        members: memberViewModel.members,
                        departments: departmentViewModel.departments
                    )

                    await vm.sendMessage(
                        businessId: businessId,
                        departmentId: resolved.departmentId,
                        employeeUserId: resolved.employeeUserId,
                        isManager: isManagerChat
                    )
                }
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(canSend ? Color.blue : Color.gray)
                    .clipShape(Circle())
            }
            .disabled(!canSend)
        }
        .padding(.horizontal, 14)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(.regularMaterial)
    }

    private var canSend: Bool {
        !vm.isLoading &&
        !vm.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !businessId.isEmpty
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            if vm.isLoading {
                proxy.scrollTo("typing", anchor: .bottom)
            } else if let last = vm.messages.last {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }
}
