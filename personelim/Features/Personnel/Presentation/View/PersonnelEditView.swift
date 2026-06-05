import SwiftUI

struct PersonnelEditView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    let memberId: String
    let originalMember: BusinessMemberDTO
    let onSaved: () -> Void
    let onDeleted: () -> Void

    @StateObject private var vm: PersonnelEditViewModel
    @State private var showDeleteConfirm = false
    @State private var positionSearchText = ""

    private var selectedPositionName: String {
        vm.jobTitles
            .first(where: { $0.id == vm.selectedPositionId })?
            .name ?? originalMember.positionName ?? "Ünvan seç"
    }

    private var filteredJobTitles: [JobTitleDTO] {
        let query = positionSearchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return vm.jobTitles
        }

        return vm.jobTitles.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    init(
        memberId: String,
        originalMember: BusinessMemberDTO,
        onSaved: @escaping () -> Void,
        onDeleted: @escaping () -> Void
    ) {
        self.memberId = memberId
        self.originalMember = originalMember
        self.onSaved = onSaved
        self.onDeleted = onDeleted

        let repo = BusinessMemberRepositoryImpl(network: NetworkManager())
        let updateUseCase = UpdateBusinessMemberUseCase(repo: repo)
        let deleteUseCase = DeleteBusinessMemberUseCase(repo: repo)

        _vm = StateObject(
            wrappedValue: PersonnelEditViewModel(
                memberRepo: repo,
                updateUseCase: updateUseCase,
                deleteUseCase: deleteUseCase
            )
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemBackground)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    headerSection

                    formSection

                    positionSection

                    selectedPositionSummary

                    dangerSection

                    if vm.isLoading {
                        loadingCard
                    }

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 28)
            }

            bottomSaveButton
        }
        .navigationTitle(ConstantStrings.editPersonnelTitle)
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
        }
        .task {
            vm.prefill(from: originalMember)

            if let businessId = appState.businessId {
                await vm.loadJobTitlesForEdit(
                    businessId: businessId,
                    departmentId: originalMember.departmentId
                )
            }
        }
        .onChange(of: vm.didUpdate) { _, newValue in
            guard newValue else { return }
            onSaved()
            dismiss()
        }
        .onChange(of: vm.didDelete) { _, newValue in
            guard newValue else { return }
            onDeleted()
            dismiss()
        }
        .alert(ConstantStrings.deleteAlertTitle, isPresented: $showDeleteConfirm) {
            Button(ConstantStrings.cancel, role: .cancel) { }

            Button(ConstantStrings.delete, role: .destructive) {
                Task {
                    await vm.delete(memberId: memberId)
                }
            }
        } message: {
            Text(ConstantStrings.deleteAlertMessage)
        }
        .alert(
            ConstantStrings.errorTitle,
            isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { _ in vm.errorMessage = nil }
            )
        ) {
            Button(ConstantStrings.okButton, role: .cancel) { }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                Text(initials(from: originalMember.fullName))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 58, height: 58)

            VStack(alignment: .leading, spacing: 5) {
                Text(originalMember.fullName)
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(selectedPositionName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
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

    // MARK: - Form

    private var formSection: some View {
        sectionCard(title: "Personel Bilgileri") {
            inputRow(
                title: ConstantStrings.salaryField,
                text: $vm.salaryText,
                icon: "turkishlirasign.circle.fill",
                keyboard: .numberPad
            )
        }
    }

    // MARK: - Position

    private var positionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(ConstantStrings.positionField)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.primary)

                Spacer()

                if vm.isPositionsLoading {
                    ProgressView()
                }
            }
            .padding(.horizontal, 2)

            positionSearchBox

            if vm.isPositionsLoading {
                positionLoadingCard
            } else if filteredJobTitles.isEmpty {
                emptyPositionState
            } else {
                VStack(spacing: 0) {
                    ForEach(filteredJobTitles) { title in
                        positionRow(title)

                        if title.id != filteredJobTitles.last?.id {
                            Divider()
                                .padding(.leading, 58)
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
        }
    }

    private var positionSearchBox: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)

            TextField("Ünvan ara", text: $positionSearchText)
                .font(.system(size: 15, weight: .medium))
                .textInputAutocapitalization(.words)
                .disabled(vm.isLoading || vm.isPositionsLoading)

            if !positionSearchText.isEmpty {
                Button {
                    positionSearchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private func positionRow(_ title: JobTitleDTO) -> some View {
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                vm.selectedPositionId = title.id
                vm.position = title.name
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected(title) ? Color.blue.opacity(0.10) : Color(.systemGray6))

                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(isSelected(title) ? .blue : .secondary)
                }
                .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(isSelected(title) ? "Seçili ünvan" : "Ünvan")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected(title) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(.blue)
                } else {
                    Circle()
                        .stroke(Color.black.opacity(0.14), lineWidth: 1.4)
                        .frame(width: 21, height: 21)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(
                isSelected(title)
                ? Color.blue.opacity(0.035)
                : Color(.systemBackground)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(vm.isLoading)
    }

    @ViewBuilder
    private var selectedPositionSummary: some View {
        if vm.selectedPositionId != 0 {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.blue)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Seçilen ünvan")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(selectedPositionName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(14)
            .background(Color.blue.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.blue.opacity(0.16), lineWidth: 1)
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    private var positionLoadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()

            Text("Ünvanlar yükleniyor...")
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

    private var emptyPositionState: some View {
        VStack(spacing: 12) {
            Image(systemName: "briefcase.circle")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(.blue)

            Text("Ünvan bulunamadı")
                .font(.headline)

            Text("Bu departman için tanımlı ünvan bulunamadı.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Danger

    private var dangerSection: some View {
        sectionCard(title: "Tehlikeli İşlem") {
            Button {
                showDeleteConfirm = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.red)
                        .frame(width: 32, height: 32)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(ConstantStrings.deletePersonnelButton)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.red)

                        Text("Bu işlem geri alınamaz.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.red.opacity(0.06))
            }
            .buttonStyle(.plain)
            .disabled(vm.isLoading)
        }
    }

    // MARK: - Loading

    private var loadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()

            Text("İşlem yapılıyor...")
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

    // MARK: - Bottom Save

    private var bottomSaveButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                Task {
                    await vm.save(
                        memberId: memberId,
                        original: originalMember
                    )
                }
            } label: {
                HStack(spacing: 8) {
                    if vm.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                    }

                    Text(vm.isLoading ? "Kaydediliyor..." : "Değişiklikleri Kaydet")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(canSave ? Color.blue : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!canSave)
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(.regularMaterial)
        }
    }

    private var canSave: Bool {
        !vm.isLoading &&
        !vm.isPositionsLoading &&
        vm.selectedPositionId != 0
    }

    // MARK: - UI Helpers

    private func sectionCard<Content: View>(
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

    private func inputRow(
        title: String,
        text: Binding<String>,
        icon: String,
        keyboard: UIKeyboardType = .default
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

                TextField(title, text: text)
                    .font(.system(size: 15, weight: .medium))
                    .keyboardType(keyboard)
                    .disabled(vm.isLoading)
            }
        }
        .formRowBackground()
    }

    private func isSelected(_ title: JobTitleDTO) -> Bool {
        vm.selectedPositionId == title.id
    }

    private func initials(from name: String) -> String {
        let parts = name
            .split(separator: " ")
            .map(String.init)

        let first = parts.first?.first.map(String.init) ?? ""
        let second = parts.dropFirst().first?.first.map(String.init) ?? ""

        let result = first + second
        return result.isEmpty ? "?" : result.uppercased()
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
