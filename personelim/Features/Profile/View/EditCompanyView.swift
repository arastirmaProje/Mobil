import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct EditCompanyView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: EditCompanyViewModel

    @State private var showDocPicker = false

    init(authRepo: AuthRepositoryProtocol) {
        _vm = StateObject(
            wrappedValue: EditCompanyViewModel(authRepo: authRepo)
        )
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        logoSection

                        sectionCard(title: ConstantStrings.companyInfoSectionTitle) {
                            appTextField(
                                title: ConstantStrings.companyNameLabel,
                                text: $vm.companyName,
                                icon: "building.2"
                            )

                            appTextField(
                                title: ConstantStrings.companyEmailLabel,
                                text: $vm.companyEmail,
                                icon: "envelope",
                                keyboard: .emailAddress,
                                autocapitalization: .never
                            )

                            appTextField(
                                title: ConstantStrings.companyDescriptionLabel,
                                text: $vm.description,
                                icon: "text.alignleft"
                            )
                        }

                        sectionCard(title: ConstantStrings.documentsLabel) {
                            documentPickerRow
                        }

                        officeSection

                        sectionCard(title: ConstantStrings.addressInfoSectionTitle) {
                            provincePicker

                            if vm.selectedProvinceId != nil {
                                districtPicker
                            }

                            appTextField(
                                title: ConstantStrings.detailedAddressLabel,
                                text: $vm.detailedAddress,
                                icon: "map"
                            )

                            appTextField(
                                title: ConstantStrings.phoneLabel,
                                text: $vm.phone,
                                icon: "phone",
                                keyboard: .phonePad
                            )
                        }

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
            .navigationTitle(ConstantStrings.editCompanyTitle)
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
        .sheet(isPresented: $vm.showMapPicker) {
            MapPickerView { result in
                vm.setLocation(result.coordinate)
            }
        }
        .alert(
            vm.errorMessage ?? "",
            isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { newValue in
                    if !newValue {
                        vm.errorMessage = nil
                    }
                }
            )
        ) {
            Button(ConstantStrings.okButton) {
                vm.errorMessage = nil
            }
        }
    }

    // MARK: - Logo Section

    private var logoSection: some View {
        VStack(spacing: 14) {
            profileImage(size: 92)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )

            PhotosPicker(selection: $vm.photoItem, matching: .images) {
                Label(ConstantStrings.changeLogoButton, systemImage: "photo")
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

    private func profileImage(size: CGFloat) -> some View {
        Group {
            if let data = vm.photoData,
               let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.10))

                    Image(systemName: "building.2.crop.circle")
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundStyle(.blue)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    // MARK: - Document

    private var documentPickerRow: some View {
        Button {
            showDocPicker = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 3) {
                    Text(ConstantStrings.documentsLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(vm.documentURL?.lastPathComponent ?? ConstantStrings.selectPDFDocument)
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

    // MARK: - Office Section

    private var officeSection: some View {
        sectionCard(title: ConstantStrings.officesTitle) {
            VStack(spacing: 0) {
                ForEach($vm.offices) { $office in
                    officeCard($office)
                }

                Button {
                    vm.addOffice()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)

                        Text(ConstantStrings.addOfficeButton)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.blue)

                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 13)
                    .background(Color(.systemBackground))
                }
                .buttonStyle(.plain)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
        }
    }

    private func officeCard(_ office: Binding<CompanyOfficeForm>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(ConstantStrings.officePrefix) \(office.wrappedValue.index)")
                    .font(.system(size: 15, weight: .bold))

                Spacer()

                if office.wrappedValue.id == vm.offices.last?.id {
                    Button(action: vm.removeLastOffice) {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(vm.offices.count <= 1 ? .secondary : .red)
                    }
                    .disabled(vm.offices.count <= 1)
                }
            }

            TextField(ConstantStrings.officeNamePlaceholder, text: office.name)
                .font(.system(size: 15, weight: .medium))
                .padding(.horizontal, 12)
                .frame(height: 46)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Button {
                vm.beginPickLocation(for: office.wrappedValue.id)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundStyle(.blue)

                    Text(ConstantStrings.pickFromMap)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.blue)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if let lat = office.wrappedValue.latitude,
               let lng = office.wrappedValue.longitude {
                Text(
                    "\(ConstantStrings.selectedLocation): \(String(format: "%.5f", lat)), \(String(format: "%.5f", lng))"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            } else {
                Text(ConstantStrings.locationNotSelected)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.black.opacity(0.055))
                .frame(height: 0.7)
                .padding(.leading, 14)
        }
    }

    // MARK: - Province / District

    private var provincePicker: some View {
        pickerRow(
            title: ConstantStrings.provinceLabel,
            icon: "map.fill",
            placeholder: ConstantStrings.provincePickerPlaceholder,
            selection: Binding<Int?>(
                get: {
                    vm.selectedProvinceId
                },
                set: { newId in
                    guard let newId else {
                        vm.selectedProvinceId = nil
                        vm.selectedDistrictId = nil
                        vm.districts = []
                        return
                    }

                    Task {
                        await vm.selectProvince(newId)
                    }
                }
            ),
            items: vm.provinces
        )
    }

    private var districtPicker: some View {
        pickerRow(
            title: ConstantStrings.districtLabel,
            icon: "mappin",
            placeholder: ConstantStrings.districtPickerPlaceholder,
            selection: Binding<Int?>(
                get: {
                    vm.selectedDistrictId
                },
                set: {
                    vm.selectedDistrictId = $0
                }
            ),
            items: vm.districts
        )
    }

    private func pickerRow<T: Identifiable>(
        title: String,
        icon: String,
        placeholder: String,
        selection: Binding<Int?>,
        items: [T]
    ) -> some View where T.ID == Int, T: NamedPickerItem {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Picker(placeholder, selection: selection) {
                    Text(ConstantStrings.pickerSelect).tag(Int?.none)

                    ForEach(items) { item in
                        Text(item.name).tag(Int?.some(item.id))
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .tint(.primary)
            }

            Spacer()
        }
        .formRowBackground()
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
                    } catch {
                        if case let RepositoryError.api(message) = error {
                            vm.errorMessage = message
                        } else {
                            vm.errorMessage = ConstantStrings.companyUpdateFail
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

// MARK: - Picker Protocol

private protocol NamedPickerItem {
    var id: Int { get }
    var name: String { get }
}

extension ProvinceDTO: NamedPickerItem {}
extension DistrictDTO: NamedPickerItem {}
