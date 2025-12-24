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
        _vm = StateObject(wrappedValue: EditPersonalProfileViewModel(authRepo: authRepo))
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {

                    Text("Profil düzenle")
                        .font(.title2.bold())
                        .padding(.top, 8)

                    HStack(spacing: 12) {
                        profileImage(size: 44)

                        Text("Profil Resmi")
                            .font(.body)

                        Spacer()

                        PhotosPicker(selection: $vm.photoItem, matching: .images) {
                            Text("Ekle")
                                .font(.body)
                                .foregroundColor(.blue)
                        }
                        .onChange(of: vm.photoItem) { _, newValue in
                            Task { await vm.onPickPhoto(newValue) }
                        }
                    }
                    .padding(.vertical, 6)

                    LabeledRoundedField(title: "Email") {
                        TextField("", text: $vm.email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                    }

                    LabeledRoundedField(title: "İsim") {
                        TextField("", text: $vm.firstName)
                    }

                    LabeledRoundedField(title: "Soyisim") {
                        TextField("", text: $vm.lastName)
                    }

                    LabeledRoundedField(title: "Kimlik", trailingTitle: "Tara", trailingAction: {
                        showIDScanner = true
                    }) {
                        TextField("", text: $vm.tcIdentityNumber)
                            .keyboardType(.numberPad)
                    }

                    LabeledRoundedField(title: "CV", trailingTitle: "Ekle", trailingAction: {
                        showCVPicker = true
                    }) {
                        TextField("", text: Binding(
                            get: { vm.cvURL?.lastPathComponent ?? "" },
                            set: { _ in }
                        ))
                        .disabled(true)
                    }

                    if !vm.existingCVs.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Yüklenmiş CV’ler")
                                .font(.footnote)
                                .foregroundColor(.gray)

                            ForEach(vm.existingCVs, id: \.id) { d in
                                HStack(spacing: 10) {
                                    Text(d.fileName)
                                        .font(.callout)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Button(role: .destructive) {
                                        Task { await vm.deleteDocument(d) }
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .disabled(vm.isDeletingDoc || vm.isLoading)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                    }

                    LabeledRoundedField(title: "Belgeler", trailingTitle: "Ekle", trailingAction: {
                        showDocPicker = true
                    }) {
                        TextField("", text: Binding(
                            get: { vm.documentURL?.lastPathComponent ?? "" },
                            set: { _ in }
                        ))
                        .disabled(true)
                    }

                    if !vm.existingDocuments.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Yüklenmiş Belgeler")
                                .font(.footnote)
                                .foregroundColor(.gray)

                            ForEach(vm.existingDocuments, id: \.id) { d in
                                HStack(spacing: 10) {
                                    Text(d.fileName)
                                        .font(.callout)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Button(role: .destructive) {
                                        Task { await vm.deleteDocument(d) }
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .disabled(vm.isDeletingDoc || vm.isLoading)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                    }

                    if let err = vm.errorMessage {
                        Text(err)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, 4)
                    }

                    Divider().padding(.top, 8)

                    Button(role: .destructive) {
                        showDeleteAccountConfirm = true
                    } label: {
                        Text("Hesabı Sil")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.12))
                            .cornerRadius(12)
                    }
                    .disabled(vm.isLoading)

                    Spacer().frame(height: 24)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .task { await vm.load() }

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
            case .failure(let error):
                vm.errorMessage = error.localizedDescription
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
            case .failure(let error):
                vm.errorMessage = error.localizedDescription
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
            "Hesabınızı silmek istiyor musunuz?",
            isPresented: $showDeleteAccountConfirm,
            titleVisibility: .visible
        ) {
            Button("Hesabı Sil", role: .destructive) {
                Task {
                    await vm.deleteMyAccount()
                    if vm.errorMessage == nil {
                        dismiss()
                    }
                }
            }
            Button("Vazgeç", role: .cancel) { }
        }
    }

    // MARK: - Top Bar (geri + check)
    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }

            Spacer()

            Button {
                Task {
                    do {
                        try await vm.save()
                        dismiss()
                    } catch {
                        vm.errorMessage = error.localizedDescription
                    }
                }
            } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
            .disabled(vm.isLoading)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 10)
    }

    // MARK: - Foto preview 
    private func profileImage(size: CGFloat) -> some View {
        Group {
            if let data = vm.photoData, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
            } else if let url = absoluteURL(from: vm.remoteImageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    case .failure:
                        Circle().fill(Color.gray.opacity(0.25))
                    case .empty:
                        ProgressView()
                    @unknown default:
                        Circle().fill(Color.gray.opacity(0.25))
                    }
                }
            } else {
                Circle().fill(Color.gray.opacity(0.25))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private func absoluteURL(from pathOrUrl: String?) -> URL? {
        let baseURL = "https://personelimapi.onrender.com"
        guard var s = pathOrUrl, !s.isEmpty else { return nil }
        if s.lowercased().hasPrefix("http") { return URL(string: s) }
        if !s.hasPrefix("/") { s = "/" + s }
        return URL(string: baseURL + s)
    }
}

// MARK: - UI Helper
private struct LabeledRoundedField<Content: View>: View {
    let title: String
    var trailingTitle: String? = nil
    var trailingAction: (() -> Void)? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title).font(.body)
                Spacer()
                if let trailingTitle {
                    Button(trailingTitle) { trailingAction?() }
                        .foregroundColor(.blue)
                        .font(.body)
                }
            }

            content()
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
}
