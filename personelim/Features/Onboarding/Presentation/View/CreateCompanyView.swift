import SwiftUI

struct CreateCompanyView: View {

    @StateObject private var vm = CreateCompanyViewModel()

    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let onVerified: () -> Void

    private var canSubmit: Bool {
        !vm.companyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !vm.phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !vm.detailedAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        vm.selectedProvinceId != nil &&
        vm.selectedDistrictId != nil &&
        !vm.isLoading
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerSection

                        companyInfoSection

                        officeSection

                        locationSection

                        addressSection

                        if vm.isLoading {
                            loadingCard
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }

                bottomCreateButton
            }
            .navigationTitle(ConstantStrings.createCompanyTitle)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await vm.loadProvinces()
            }
            .sheet(isPresented: $vm.showMapPicker) {
                MapPickerView { result in
                    vm.setLocation(
                        result.coordinate,
                        address: result.address
                    )
                }
            }
            .sheet(isPresented: $vm.showOTP) {
                EmailVerifyView(email: vm.verifyEmail) { code in
                    Task {
                        do {
                            _ = try await vm.verifyBusiness(code: code)
                            vm.showOTP = false

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                dismiss()
                                onVerified()
                            }
                        } catch {
                            vm.errorMessage = error.localizedDescription
                        }
                    }
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
    }
}

// MARK: - Sections

private extension CreateCompanyView {

    var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                Image(systemName: "building.2.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 5) {
                Text(ConstantStrings.createCompanyTitle)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)

                Text("Şirket bilgilerini tamamlayarak işletmeni oluştur.")
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

    var companyInfoSection: some View {
        sectionCard(title: "Şirket Bilgileri") {
            inputRow(
                title: "Şirket İsmi",
                placeholder: "Şirket adı",
                text: $vm.companyName,
                icon: "building.2.fill"
            )

            inputRow(
                title: ConstantStrings.phoneLabel,
                placeholder: ConstantStrings.phonePlaceholder,
                text: $vm.phone,
                icon: "phone.fill",
                keyboard: .phonePad
            )

            inputRow(
                title: ConstantStrings.descriptionLabel,
                placeholder: ConstantStrings.descriptionPlaceholder,
                text: $vm.description,
                icon: "text.alignleft"
            )
        }
    }

    var officeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ConstantStrings.addLocation)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.primary)

                    Text("\(vm.offices.count) ofis bilgisi")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        vm.addOffice()
                    }
                } label: {
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
            .padding(.horizontal, 2)

            VStack(spacing: 12) {
                ForEach($vm.offices) { $office in
                    officeCard($office)
                }
            }
        }
    }

    func officeCard(_ office: Binding<Office>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.10))

                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.blue)
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 3) {
                    Text("\(ConstantStrings.officePrefix) \(office.wrappedValue.index)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.primary)

                    Text(hasLocation(office.wrappedValue) ? ConstantStrings.selectedLocation : "Konum seçilmedi")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if office.wrappedValue.id == vm.offices.last?.id && vm.offices.count > 1 {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            vm.removeLastOffice()
                        }
                    } label: {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.red)
                            .frame(width: 34, height: 34)
                            .background(Color.red.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }

            inputRow(
                title: ConstantStrings.officeNamePlaceholder,
                placeholder: ConstantStrings.officeNamePlaceholder,
                text: office.name,
                icon: "signpost.right.fill"
            )

            inputRow(
                title: ConstantStrings.addressPlaceholder,
                placeholder: ConstantStrings.addressPlaceholder,
                text: office.address,
                icon: "map.fill"
            )

            Button {
                vm.beginPickLocation(for: office.wrappedValue.id)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.blue)
                        .frame(width: 32, height: 32)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(ConstantStrings.pickFromMap)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.primary)

                        if let lat = office.wrappedValue.latitude,
                           let lng = office.wrappedValue.longitude {
                            Text("\(lat), \(lng)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        } else {
                            Text("Haritadan ofis konumu seç")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
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
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    var locationSection: some View {
        sectionCard(title: "Konum Bilgileri") {
            provincePicker

            if vm.selectedProvinceId != nil {
                districtPicker
            }
        }
    }

    var provincePicker: some View {
        menuRow(
            title: ConstantStrings.provinceLabel,
            value: selectedProvinceName,
            icon: "map.fill"
        ) {
            Button(ConstantStrings.pickerSelect) {
                vm.selectedProvinceId = nil
                vm.selectedDistrictId = nil
                vm.districts = []
            }

            ForEach(vm.provinces) { province in
                Button(province.name) {
                    Task {
                        await vm.selectProvince(province.id)
                    }
                }
            }
        }
    }

    var districtPicker: some View {
        menuRow(
            title: ConstantStrings.districtLabel,
            value: selectedDistrictName,
            icon: "mappin.circle.fill"
        ) {
            Button(ConstantStrings.pickerSelect) {
                vm.selectedDistrictId = nil
            }

            ForEach(vm.districts) { district in
                Button(district.name) {
                    vm.selectedDistrictId = district.id
                }
            }
        }
    }

    var addressSection: some View {
        sectionCard(title: "Adres Detayı") {
            inputRow(
                title: ConstantStrings.detailedAddressLabel,
                placeholder: ConstantStrings.detailedAddressPlaceholder,
                text: $vm.detailedAddress,
                icon: "house.and.flag.fill"
            )
        }
    }

    var loadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()

            Text("Şirket oluşturuluyor...")
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

    var bottomCreateButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                Task {
                    await vm.createCompany(appState: appState)
                }
            } label: {
                HStack(spacing: 8) {
                    if vm.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                    }

                    Text(vm.isLoading ? "Oluşturuluyor..." : ConstantStrings.createCompanyButton)
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(canSubmit ? Color.blue : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!canSubmit)
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(.regularMaterial)
        }
    }
}

// MARK: - UI Helpers

private extension CreateCompanyView {

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

    func inputRow(
        title: String,
        placeholder: String,
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

                TextField(placeholder, text: text)
                    .font(.system(size: 15, weight: .medium))
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(.sentences)
            }
        }
        .formRowBackground()
    }

    func menuRow<Content: View>(
        title: String,
        value: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        Menu {
            content()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(value)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(value == ConstantStrings.pickerSelect ? .secondary : .primary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .formRowBackground()
        }
        .buttonStyle(.plain)
    }

    var selectedProvinceName: String {
        guard let id = vm.selectedProvinceId else {
            return ConstantStrings.pickerSelect
        }

        return vm.provinces.first(where: { $0.id == id })?.name ?? ConstantStrings.pickerSelect
    }

    var selectedDistrictName: String {
        guard let id = vm.selectedDistrictId else {
            return ConstantStrings.pickerSelect
        }

        return vm.districts.first(where: { $0.id == id })?.name ?? ConstantStrings.pickerSelect
    }

    func hasLocation(_ office: Office) -> Bool {
        office.latitude != nil && office.longitude != nil
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
