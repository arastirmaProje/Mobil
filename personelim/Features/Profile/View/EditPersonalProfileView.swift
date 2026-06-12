import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct EditPersonalProfileView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: EditPersonalProfileViewModel

    @State private var showIDScanner = false
    @State private var showCVPicker = false
    @State private var showDocPicker = false
    @State private var showDeleteAccountConfirm = false

    init(authRepo: AuthRepositoryProtocol) {
        _vm = StateObject(
            wrappedValue: EditPersonalProfileViewModel(authRepo: authRepo)
        )
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        photoSection

                        sectionCard(title: ConstantStrings.personalInfoSectionHeader) {
                            appTextField(
                                title: ConstantStrings.emailLabel,
                                text: $vm.email,
                                icon: "envelope",
                                keyboard: .emailAddress,
                                autocapitalization: .never
                            )

                            appTextField(
                                title: ConstantStrings.nameLabel,
                                text: $vm.firstName,
                                icon: "person"
                            )

                            appTextField(
                                title: ConstantStrings.surnameLabel,
                                text: $vm.lastName,
                                icon: "person.fill"
                            )

                            identityRow
                        }

                        sectionCard(title: ConstantStrings.resumeLabel) {
                            documentPickerRow(
                                title: ConstantStrings.resumeLabel,
                                selectedFileName: vm.cvURL?.lastPathComponent,
                                placeholder: ConstantStrings.selectPDFCV,
                                icon: "doc.text.magnifyingglass",
                                action: {
                                    showCVPicker = true
                                }
                            )

                            if !vm.existingCVs.isEmpty {
                                uploadedDocumentsList(vm.existingCVs)
                            }
                        }

                        sectionCard(title: ConstantStrings.documentsLabel) {
                            documentPickerRow(
                                title: ConstantStrings.documentsLabel,
                                selectedFileName: vm.documentURL?.lastPathComponent,
                                placeholder: ConstantStrings.selectPDFDocument,
                                icon: "folder.badge.plus",
                                action: {
                                    showDocPicker = true
                                }
                            )

                            if !vm.existingDocuments.isEmpty {
                                uploadedDocumentsList(vm.existingDocuments)
                            }
                        }

                        dangerZone

                        if let err = vm.errorMessage {
                            errorRow(err)
                        }

                        Spacer().frame(height: 92)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                }

                bottomSaveButton
            }
            .navigationTitle(ConstantStrings.editProfileTitle)
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
            }
        }
        .task {
            await vm.load()
        }
        .fileImporter(
            isPresented: $showCVPicker,
            allowedContentTypes: [UTType.pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    vm.setCV(url: url)
                }

            case .failure:
                vm.errorMessage = ConstantStrings.documentSelectFailed
            }
        }
        .fileImporter(
            isPresented: $showDocPicker,
            allowedContentTypes: [UTType.pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    vm.setDocument(url: url)
                }

            case .failure:
                vm.errorMessage = ConstantStrings.documentSelectFailed
            }
        }
        .sheet(isPresented: $showIDScanner) {
            IDNumberScannerView(
                onFound: { tc in
                    vm.setTC(tc)
                    showIDScanner = false
                },
                onCancel: {
                    showIDScanner = false
                },
                onError: { msg in
                    vm.errorMessage = msg
                    showIDScanner = false
                }
            )
        }
        .confirmationDialog(
            ConstantStrings.deleteAccountConfirmationTitle,
            isPresented: $showDeleteAccountConfirm,
            titleVisibility: .visible
        ) {
            Button(ConstantStrings.deleteAccountButton, role: .destructive) {
                Task {
                    await vm.deleteMyAccount()

                    if vm.errorMessage == nil {
                        dismiss()
                    }
                }
            }

            Button(ConstantStrings.cancelAction, role: .cancel) { }
        }
    }

    // MARK: - Photo Section

    private var photoSection: some View {
        VStack(spacing: 14) {
            profileImage(size: 96)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )

            PhotosPicker(selection: $vm.photoItem, matching: .images) {
                Label(ConstantStrings.changePhotoButton, systemImage: "photo")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.10))
                    )
            }
            .onChange(of: vm.photoItem) { _, newValue in
                Task {
                    await vm.onPickPhoto(newValue)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Identity Row

    private var identityRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.text.rectangle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 5) {
                Text(ConstantStrings.identityLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                TextField(ConstantStrings.identityLabel, text: $vm.tcIdentityNumber)
                    .font(.system(size: 15, weight: .medium))
                    .keyboardType(.numberPad)
            }

            Button {
                showIDScanner = true
            } label: {
                Text(ConstantStrings.scanButton)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.10))
                    )
            }
            .buttonStyle(.plain)
        }
        .formRowBackground()
    }

    // MARK: - Document Picker Row

    private func documentPickerRow(
        title: String,
        selectedFileName: String?,
        placeholder: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(selectedFileName ?? placeholder)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .formRowBackground()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Uploaded Documents

    private func uploadedDocumentsList(_ documents: [BusinessMemberDocumentDTO]) -> some View {
        VStack(spacing: 0) {
            ForEach(documents, id: \.id) { document in
                uploadedDocumentRow(document)
            }
        }
    }

    private func uploadedDocumentRow(_ document: BusinessMemberDocumentDTO) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 3) {
                Text(ConstantStrings.uploadedFileTitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(document.fileName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }

            Spacer()

            Button(role: .destructive) {
                Task {
                    await vm.deleteDocument(document)
                }
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(
                        (vm.isDeletingDoc || vm.isLoading) ? .secondary : .red
                    )
            }
            .disabled(vm.isDeletingDoc || vm.isLoading)
        }
        .formRowBackground()
    }

    // MARK: - Danger Zone

    private var dangerZone: some View {
        sectionCard(title: ConstantStrings.dangerousActionsTitle) {
            Button(role: .destructive) {
                showDeleteAccountConfirm = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.red)
                        .frame(width: 32, height: 32)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(ConstantStrings.deleteAccountButton)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.red)

                        Text(ConstantStrings.deleteAlertMessage)
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

    // MARK: - Bottom Save Button

    private var bottomSaveButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                Task {
                    do {
                        try await vm.save()
                        dismiss()
                    }  catch {
                        if case let RepositoryError.api(message) = error {
                            vm.errorMessage = message
                        } else {
                            vm.errorMessage = ConstantStrings.profileUpdateFail
                        }
                    }
                }
            } label: {
                HStack {
                    if vm.isLoading {
                        ProgressView()
                            .tint(.white)
                    }

                    Text(vm.isLoading ? ConstantStrings.registerLoading : ConstantStrings.saveChangesButton)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(vm.isLoading ? Color.gray : Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .disabled(vm.isLoading)
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(.regularMaterial)
        }
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

    private func appTextField(
        title: String,
        text: Binding<String>,
        icon: String,
        keyboard: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization? = .sentences
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
                    .textInputAutocapitalization(autocapitalization)
                    .keyboardType(keyboard)
            }
        }
        .formRowBackground()
    }

    private func errorRow(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)

            Spacer()
        }
        .padding(14)
        .background(Color.red.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Image Preview

    private func profileImage(size: CGFloat) -> some View {
        Group {
            if let data = vm.photoData,
               let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
            } else if let url = absoluteURL(from: vm.remoteImageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()

                    case .failure, .empty:
                        placeholderAvatar

                    @unknown default:
                        placeholderAvatar
                    }
                }
            } else {
                placeholderAvatar
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var placeholderAvatar: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.10))

            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(.blue)
        }
    }

    private func absoluteURL(from pathOrUrl: String?) -> URL? {
        let baseURL = "https://personelimapi.onrender.com"

        guard var value = pathOrUrl,
              !value.isEmpty else {
            return nil
        }

        if value.lowercased().hasPrefix("http") {
            return URL(string: value)
        }

        if !value.hasPrefix("/") {
            value = "/" + value
        }

        return URL(string: baseURL + value)
    }
}

// MARK: - Shared Row Background

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
