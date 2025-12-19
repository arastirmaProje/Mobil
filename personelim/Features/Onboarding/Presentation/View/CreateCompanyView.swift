import SwiftUI

struct CreateCompanyView: View {

    @StateObject private var vm = CreateCompanyViewModel()
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let onVerified: () -> Void

    var body: some View {
        VStack(spacing: 0) {


            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    Text("Şirket oluştur")
                        .font(.title2.bold())
                        .padding(.top, 12)

                    field("Şirket İsmi", "Şirket adı", $vm.companyName)

                    officeSection

                    provincePicker

                    if vm.selectedProvinceId != nil {
                        districtPicker
                    }

                    field("Detaylı Adres", "Adres gir", $vm.detailedAddress)
                    field("Telefon", "555 555 55 55", $vm.phone)
                    field("Açıklama", "Açıklama gir", $vm.description)

                    Spacer().frame(height: 12)
                }
                .padding(.horizontal, 20)
            }

            Button {
                Task { await vm.createCompany(appState: appState) }
            } label: {
                Text("Oluştur")
            }
            .disabled(vm.isLoading)
            .buttonStyle(OnboardingButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .ignoresSafeArea(edges: .bottom)
       
        .task { await vm.loadProvinces() }
        .sheet(isPresented: $vm.showMapPicker) {
            MapPickerView { result in
                vm.setLocation(result.coordinate, address: result.address)
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
                set: { newValue in if !newValue { vm.errorMessage = nil } }
            )
        ) {
            Button("Tamam") { vm.errorMessage = nil }
        }
    }
}

// MARK: - FIELD
private extension CreateCompanyView {
    func field(_ title: String, _ placeholder: String, _ text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .medium))

            TextField(placeholder, text: text)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.gray.opacity(0.4))
                )
        }
    }
}

// MARK: - OFFICE SECTION
private extension CreateCompanyView {
    var officeSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text("Lokasyon ekle")
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

// MARK: - PROVINCE PICKER
private extension CreateCompanyView {
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
}

// MARK: - DISTRICT PICKER
private extension CreateCompanyView {
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
