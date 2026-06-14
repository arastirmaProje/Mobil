//
//  ChatConversationListView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 13.06.2026.
//

import SwiftUI

struct ChatConversationListView: View {

    @ObservedObject var vm: ChatViewModel

    let businessId: String
    let isManagerChat: Bool
    let departmentId: String?

    @Environment(\.dismiss) private var dismiss
    @State private var deleteTarget: ChatConversationDTO?

    var body: some View {
        List {
            if vm.isConversationsLoading {
                loadingRow
            }

            if vm.conversations.isEmpty && !vm.isConversationsLoading {
                emptyRow
            }

            ForEach(vm.conversations) { conversation in
                Button {
                    Task {
                        await vm.loadConversationDetail(
                            conversationId: conversation.id
                        )
                        dismiss()
                    }
                } label: {
                    conversationRow(conversation)
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        deleteTarget = conversation
                    } label: {
                        Label(
                            ConstantStrings.chatDeleteTitle,
                            systemImage: "trash"
                        )
                    }
                }
            }
        }
        .navigationTitle(ConstantStrings.chatConversationsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.loadConversations()
        }
        .confirmationDialog(
            ConstantStrings.chatDeleteTitle,
            isPresented: Binding(
                get: { deleteTarget != nil },
                set: { if !$0 { deleteTarget = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(ConstantStrings.deleteButton, role: .destructive) {
                guard let deleteTarget else { return }

                Task {
                    await vm.deleteConversation(
                        conversationId: deleteTarget.id
                    )
                    self.deleteTarget = nil
                }
            }

            Button(ConstantStrings.cancelButton, role: .cancel) {
                deleteTarget = nil
            }
        } message: {
            Text(ConstantStrings.chatDeleteMessage)
        }
    }

    private var loadingRow: some View {
        HStack(spacing: 12) {
            ProgressView()

            Text(ConstantStrings.chatLoadingText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }

    private var emptyRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(ConstantStrings.chatWelcomeTitle)
                .font(.headline)

            Text(ConstantStrings.chatWelcomeSubtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }

    private func conversationRow(_ item: ChatConversationDTO) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title ?? ConstantStrings.chatTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(item.lastMessage ?? ConstantStrings.dashPlaceholder)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}
