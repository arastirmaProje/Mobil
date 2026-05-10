//
//  SlackIntegrationViews.swift
//  personelim
//
//  Created by Tuğberk Acabey on 06.05.2026.
//

import SwiftUI

struct SlackIntegrationSection: View {
    let integrations: [SlackIntegration]
    let isLoading: Bool
    let onAdd: () -> Void
    let onSelect: (SlackIntegration) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(ConstantStrings.slackIntegrationTitle)
                    .font(.system(size: 18, weight: .semibold))

                Spacer()

                Button(ConstantStrings.addButton, action: onAdd)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.blue)
                    .buttonStyle(.plain)
            }

            if isLoading {
                ProgressView()
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            } else if integrations.isEmpty {
                Text(ConstantStrings.slackEmptyText)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                VStack(spacing: 8) {
                    ForEach(integrations) { integration in
                        Button {
                            onSelect(integration)
                        } label: {
                            SlackIntegrationCard(title: integration.label)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.top, 6)
    }
}

private struct SlackIntegrationCard: View {
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Spacer()

            Circle()
                .fill(Color(.systemGray3))
                .frame(width: 12, height: 12)
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct SlackIntegrationEditorView: View {
    @ObservedObject var viewModel: SlackIntegrationViewModel

    let businessId: String
    let integration: SlackIntegration?

    @Environment(\.dismiss) private var dismiss

    @State private var label: String
    @State private var webhookUrl: String
    @State private var selectedTypes: Set<SlackActivityType>
    @State private var currentIntegration: SlackIntegration?
    @State private var isEditing: Bool
    @State private var showError = false

    private var isAdding: Bool { integration == nil }

    init(
        viewModel: SlackIntegrationViewModel,
        businessId: String,
        integration: SlackIntegration?
    ) {
        self.viewModel = viewModel
        self.businessId = businessId
        self.integration = integration

        _label = State(initialValue: integration?.label ?? "")
        _webhookUrl = State(initialValue: integration?.webhookUrl ?? "")
        _selectedTypes = State(initialValue: Set(integration?.eventTypes ?? SlackActivityType.allCases))
        _currentIntegration = State(initialValue: integration)
        _isEditing = State(initialValue: integration == nil)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                Text(ConstantStrings.slackIntegrationFormTitle)
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.top, 8)

                formField(
                    title: ConstantStrings.slackChannelNameLabel,
                    placeholder: ConstantStrings.slackChannelNamePlaceholder,
                    text: $label,
                    keyboardType: .default
                )

                formField(
                    title: ConstantStrings.slackWebhookURLLabel,
                    placeholder: ConstantStrings.slackWebhookURLPlaceholder,
                    text: $webhookUrl,
                    keyboardType: .URL
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text(ConstantStrings.slackActivityTypesLabel)
                        .font(.system(size: 13, weight: .medium))

                    ForEach(SlackActivityType.allCases) { type in
                        activityRow(type)
                    }
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 34, height: 34)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                trailingButton
            }
        }
        .alert(ConstantStrings.errorTitle, isPresented: $showError) {
            Button(ConstantStrings.okButton, role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? ConstantStrings.unknownError)
        }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            showError = newValue != nil
        }
    }

    private var navigationTitle: String {
        if isAdding {
            return ConstantStrings.slackAddTitle
        }
        return isEditing ? ConstantStrings.slackEditTitle : ConstantStrings.slackDetailTitle
    }

    @ViewBuilder
    private var trailingButton: some View {
        if isEditing {
            Button {
                Task { await save() }
            } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 34, height: 34)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
            .disabled(viewModel.isLoading)
        } else {
            Button(ConstantStrings.editButton) {
                isEditing = true
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Color.blue)
            .clipShape(Capsule())
        }
    }

    private func formField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .medium))

            TextField(placeholder, text: text)
                .font(.system(size: 13))
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .disabled(!isEditing || viewModel.isLoading)
                .padding(.horizontal, 12)
                .frame(height: 38)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
    }

    private func activityRow(_ type: SlackActivityType) -> some View {
        Button {
            guard isEditing, !viewModel.isLoading else { return }
            toggle(type)
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.primary)

                    Text(ConstantStrings.slackActivitySubtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Circle()
                    .fill(selectedTypes.contains(type) ? Color.green : Color(.systemGray4))
                    .frame(width: 12, height: 12)
            }
            .padding(.horizontal, 12)
            .frame(height: 54)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func toggle(_ type: SlackActivityType) {
        if selectedTypes.contains(type) {
            selectedTypes.remove(type)
        } else {
            selectedTypes.insert(type)
        }
    }

    private func save() async {
        let orderedTypes = SlackActivityType.allCases.filter { selectedTypes.contains($0) }
        let success: Bool

        if let integrationToUpdate = currentIntegration {
            success = await viewModel.update(
                integration: integrationToUpdate,
                businessId: businessId,
                label: label,
                webhookUrl: webhookUrl,
                eventTypes: orderedTypes
            )
        } else {
            success = await viewModel.create(
                businessId: businessId,
                label: label,
                webhookUrl: webhookUrl,
                eventTypes: orderedTypes
            )
        }

        guard success else { return }

        if isAdding {
            dismiss()
        } else {
            refreshCurrentIntegration()
            isEditing = false
        }
    }

    private func refreshCurrentIntegration() {
        guard let oldIntegration = currentIntegration else { return }

        let oldRecordIds = Set(oldIntegration.records.map(\.id))
        currentIntegration = viewModel.integrations.first { candidate in
            candidate.records.contains { oldRecordIds.contains($0.id) }
        } ?? viewModel.integrations.first { candidate in
            candidate.label == trimmed(label) && candidate.webhookUrl == trimmed(webhookUrl)
        }
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
