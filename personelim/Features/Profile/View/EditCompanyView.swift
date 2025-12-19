import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct EditCompanyView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: EditCompanyViewModel

    @State private var showDocPicker = false

    init(authRepo: AuthRepositoryProtocol) {
        _vm = StateObject(wrappedValue: EditCompanyViewModel(authRepo: authRepo))
    }

    var body: some View {
        VStack(spacing: 0) {

            topBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {

                    Text("Şirket düzenle")
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

                    LabeledRoundedField(title: "Şirket İsmi") {
                        TextField("", text: $vm.companyName)
                    }

                    LabeledRoundedField(title: "Email") {
                        TextField("", text: $vm.companyEmail)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                    }

                    LabeledRoundedField(title: "Açıklama") {
                        TextField("", text: $vm.description)
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

                    officeSection

                    provincePicker

                    if vm.selectedProvinceId != nil {
                        districtPicker
                    }

                    LabeledRoundedField(title: "Adres") {
                        TextField("", text: $vm.detailedAddress)
                    }

                    LabeledRoundedField(title: "Telefon") {
                        TextField("", text: $vm.phone)
                            .keyboardType(.phonePad)
                    }

                    if let err = vm.errorMessage {
                        Text(err)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, 4)
                    }

                    Spacer().frame(height: 24)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .task { await vm.load() }

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

        .sheet(isPresented: $vm.showMapPicker) {
            MapPickerView { result in
                vm.setLocation(result.coordinate, address: result.address)
            }
        }

        .alert(
            vm.errorMessage ?? "",
            isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { newValue in if !newValue { vm.errorMessage = nil } }
            )
        ) {
            Button("Tamam") { vm.errorMessage = nil }
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

    private func profileImage(size: CGFloat) -> some View {
        Group {
            if let data = vm.photoData, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
            } else {
                Circle().fill(Color.gray.opacity(0.25))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

// MARK: - Lokasyon ekle (CreateCompany ile aynı yapı)
private extension EditCompanyView {
    var officeSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text("Lokasyon düzenle")
                    .font(.system(size: 14, weight: .medium))
                Spacer()
                Button("Ekle") { vm.addOffice() }
                    .foregroundColor(.blue)
            }

            ForEach($vm.offices) { $office in
                VStack(alignment: .leading, spacing: 10) {

                    HStack {
                        Text("Ofis \(office.index)")
                            .font(.system(size: 14, weight: .medium))
                        Spacer()

                        if office.id == vm.offices.last?.id {
                            Button(action: vm.removeLastOffice) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    TextField("Ofis adı (örn: Ofis 1)", text: $office.name)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.gray.opacity(0.4))
                        )

                    TextField("Adres", text: $office.address)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.gray.opacity(0.4))
                        )

                    Button("Haritadan seç") {
                        vm.beginPickLocation(for: office.id)
                    }
                    .foregroundColor(.blue)

                    if let lat = office.latitude, let lng = office.longitude {
                        Text("Seçilen Konum: \(lat), \(lng)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

private extension EditCompanyView {
    var provincePicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("İl")
                .font(.system(size: 14, weight: .medium))

            Picker("İl seç", selection: Binding<Int?>(
                get: { vm.selectedProvinceId },
                set: { newId in
                    guard let newId else {
                        vm.selectedProvinceId = nil
                        vm.selectedDistrictId = nil
                        vm.districts = []
                        return
                    }
                    Task { await vm.selectProvince(newId) }
                }
            )) {
                Text("Seçiniz").tag(Int?.none)
                ForEach(vm.provinces) { p in
                    Text(p.name).tag(Int?.some(p.id))
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .padding(.horizontal, 12)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.4))
            )
        }
    }

    var districtPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("İlçe")
                .font(.system(size: 14, weight: .medium))

            Picker("İlçe seç", selection: Binding<Int?>(
                get: { vm.selectedDistrictId },
                set: { vm.selectedDistrictId = $0 }
            )) {
                Text("Seçiniz").tag(Int?.none)
                ForEach(vm.districts) { d in
                    Text(d.name).tag(Int?.some(d.id))
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .padding(.horizontal, 12)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.4))
            )
        }
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
