import SwiftUI

struct SlackIntegrationSection: View {

    let integrations: [SlackIntegration]
    let isLoading: Bool
    let onAdd: () -> Void
    let onSelect: (SlackIntegration) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            if isLoading {
                loadingCard
            } else if integrations.isEmpty {
                emptyCard
            } else {
                integrationsList
            }
        }
        .padding(.top, 6)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(ConstantStrings.slackIntegrationTitle)
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(.primary)

                Text(ConstantStrings.slackIntegrationSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onAdd) {
                Label(ConstantStrings.addButton, systemImage: "plus")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.10))
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var loadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()

            Text(ConstantStrings.slackLoading)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var emptyCard: some View {
        HStack(spacing: 13) {
            iconBox(systemName: "bubble.left.and.bubble.right.fill")

            VStack(alignment: .leading, spacing: 4) {
                Text(ConstantStrings.slackEmptyText)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(ConstantStrings.slackEmptyDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var integrationsList: some View {
        VStack(spacing: 0) {
            ForEach(integrations) { integration in
                Button {
                    onSelect(integration)
                } label: {
                    SlackIntegrationCard(title: integration.label)
                }
                .buttonStyle(.plain)

                if integration.id != integrations.last?.id {
                    Divider()
                        .padding(.leading, 62)
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private func iconBox(systemName: String) -> some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.10))

            Image(systemName: systemName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.blue)
        }
        .frame(width: 42, height: 42)
    }
}

// MARK: - Slack Integration Card

private struct SlackIntegrationCard: View {

    let title: String

    var body: some View {
        HStack(spacing: 13) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                Image(systemName: "number")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(ConstantStrings.slackWebhookIntegrationSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(Color(.systemBackground))
    }
}

// MARK: - Slack Integration Editor

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

    private var isAdding: Bool {
        integration == nil
    }

    private var canSave: Bool {
        isEditing &&
        !viewModel.isLoading &&
        !trimmed(label).isEmpty &&
        !trimmed(webhookUrl).isEmpty &&
        !selectedTypes.isEmpty
    }

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
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerSection

                        formSection

                        activityTypesSection

                        if viewModel.isLoading {
                            loadingCard
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }

                bottomActionButton
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }

                if !isEditing {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                isEditing = true
                            }
                        } label: {
                            Text(ConstantStrings.editButton)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.blue.opacity(0.10))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
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

        return isEditing
            ? ConstantStrings.slackEditTitle
            : ConstantStrings.slackDetailTitle
    }
}

// MARK: - Editor Sections

private extension SlackIntegrationEditorView {

    var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 5) {
                Text(ConstantStrings.slackIntegrationFormTitle)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(
                    isEditing
                    ? ConstantStrings.slackEditSubtitle
                    : ConstantStrings.slackDetailSubtitle
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    var formSection: some View {
        sectionCard(title: ConstantStrings.slackWebhookInfoTitle) {
            formField(
                title: ConstantStrings.slackChannelNameLabel,
                placeholder: ConstantStrings.slackChannelNamePlaceholder,
                text: $label,
                icon: "number",
                keyboardType: .default
            )

            formField(
                title: ConstantStrings.slackWebhookURLLabel,
                placeholder: ConstantStrings.slackWebhookURLPlaceholder,
                text: $webhookUrl,
                icon: "link",
                keyboardType: .URL
            )
        }
    }

    var activityTypesSection: some View {
        sectionCard(title: ConstantStrings.slackActivityTypesLabel) {
            VStack(spacing: 0) {
                ForEach(SlackActivityType.allCases) { type in
                    activityRow(type)

                    if type.id != SlackActivityType.allCases.last?.id {
                        Divider()
                            .padding(.leading, 58)
                    }
                }
            }
        }
    }

    var loadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()

            Text(ConstantStrings.processingText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    var bottomActionButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                if isEditing {
                    Task {
                        await save()
                    }
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        isEditing = true
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: isEditing ? "checkmark.circle.fill" : "square.and.pencil")
                    }

                    Text(bottomButtonTitle)
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(bottomButtonColor)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(isEditing && !canSave)
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(.regularMaterial)
        }
    }

    var bottomButtonTitle: String {
        if viewModel.isLoading {
            return ConstantStrings.savingText
        }

        return isEditing
            ? ConstantStrings.saveButtonShort
            : ConstantStrings.editButton
    }

    var bottomButtonColor: Color {
        if isEditing {
            return canSave ? .blue : .gray
        }

        return .blue
    }
}

// MARK: - Editor UI Helpers

private extension SlackIntegrationEditorView {

    func formField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        icon: String,
        keyboardType: UIKeyboardType
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                TextField(placeholder, text: text)
                    .font(.system(size: 15, weight: .medium))
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .disabled(!isEditing || viewModel.isLoading)
                    .foregroundStyle(isEditing ? .primary : .secondary)
            }
        }
        .formRowBackground()
    }

    func activityRow(_ type: SlackActivityType) -> some View {
        Button {
            guard isEditing, !viewModel.isLoading else { return }

            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                toggle(type)
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected(type) ? Color.green.opacity(0.12) : Color(.systemGray6))

                    Image(systemName: isSelected(type) ? "bell.fill" : "bell.slash.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(isSelected(type) ? .green : .secondary)
                }
                .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 3) {
                    Text(type.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text(ConstantStrings.slackActivitySubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if isSelected(type) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(.green)
                } else {
                    Circle()
                        .stroke(Color.black.opacity(0.14), lineWidth: 1.4)
                        .frame(width: 21, height: 21)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(
                isSelected(type)
                ? Color.green.opacity(0.035)
                : Color(.systemBackground)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEditing || viewModel.isLoading)
        .opacity((!isEditing || viewModel.isLoading) ? 0.72 : 1)
    }

    func sectionCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 2)

            VStack(spacing: 0) {
                content()
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
        }
    }

    func isSelected(_ type: SlackActivityType) -> Bool {
        selectedTypes.contains(type)
    }

    func toggle(_ type: SlackActivityType) {
        if selectedTypes.contains(type) {
            selectedTypes.remove(type)
        } else {
            selectedTypes.insert(type)
        }
    }

    func save() async {
        let orderedTypes = SlackActivityType.allCases.filter {
            selectedTypes.contains($0)
        }

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

    func refreshCurrentIntegration() {
        guard let oldIntegration = currentIntegration else { return }

        let oldRecordIds = Set(oldIntegration.records.map(\.id))

        currentIntegration = viewModel.integrations.first { candidate in
            candidate.records.contains { oldRecordIds.contains($0.id) }
        } ?? viewModel.integrations.first { candidate in
            candidate.label == trimmed(label) &&
            candidate.webhookUrl == trimmed(webhookUrl)
        }
    }

    func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Row Background

private extension View {

    func formRowBackground() -> some View {
        self
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.black.opacity(0.055))
                    .frame(height: 0.7)
                    .padding(.leading, 58)
            }
    }
}
