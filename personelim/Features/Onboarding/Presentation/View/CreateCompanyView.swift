//
//  CreateCompanyView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 23.11.2025.
//

import SwiftUI

struct CreateCompanyView: View {

    @StateObject private var vm = CreateCompanyViewModel()
    
    @Environment(\.dismiss) private var dismiss
    let onVerified: () -> Void 

    var body: some View {
        VStack(spacing: 0) {

            header

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    Text("Şirket oluştur")
                        .font(.title2.bold())
                        .padding(.top, 12)

                    // MARK: - Şirket Bilgileri
                    field("Şirket İsmi", "Şirket adı", $vm.companyName)

                    // MARK: - Ofisler
                    officeSection

                    // MARK: - Şehir
                    cityPicker

                    // MARK: - İlçe
                    if vm.showDistricts {
                        districtPicker
                    }

                    // MARK: - Ek Alanlar
                    field("Detaylı Adres", "Adres gir", $vm.detailedAddress)
                    field("Telefon", "555 555 55 55", $vm.phone)
                    field("Açıklama", "Açıklama gir", $vm.description)

                    Spacer().frame(height: 12)
                }
                .padding(.horizontal, 20)
            }

            // MARK: - OLUŞTUR
            Button {
                Task { await vm.createCompany() }
            } label: {
                Text(vm.isLoading ? "Oluşturuluyor..." : "Oluştur")
            }
            .disabled(vm.isLoading)
            .buttonStyle(OnboardingButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)

        // MARK: - OTP SHEET
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
        // MARK: - ERROR
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

// MARK: - HEADER
private extension CreateCompanyView {

    var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(Circle())
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 6)
        .background(Color.clear)
    }
}

// MARK: - FIELD
private extension CreateCompanyView {

    func field(
        _ title: String,
        _ placeholder: String,
        _ text: Binding<String>
    ) -> some View {
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
                Button("Ekle") {
                    vm.addOffice()
                }
                .foregroundColor(.blue)
            }

            ForEach($vm.offices) { $office in
                VStack(alignment: .leading, spacing: 6) {

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

                    TextField("Adres", text: $office.address)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.gray.opacity(0.4))
                        )
                }
            }
        }
    }
}

// MARK: - CITY PICKER
private extension CreateCompanyView {

    var cityPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Şehir")
                .font(.system(size: 14, weight: .medium))

            Picker("Şehir seç", selection: $vm.selectedCity) {
                ForEach(vm.cities, id: \.self) { city in
                    Text(city).tag(city)
                }
            }
            .pickerStyle(.menu)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.4))
            )
            .onChange(of: vm.selectedCity) { _ in
                vm.selectedDistrict = ""
            }
        }
    }
}

// MARK: - DISTRICT PICKER
private extension CreateCompanyView {

    var districtPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("İlçe")
                .font(.system(size: 14, weight: .medium))

            Picker("İlçe seç", selection: $vm.selectedDistrict) {
                ForEach(vm.districts[vm.selectedCity] ?? [], id: \.self) { dist in
                    Text(dist).tag(dist)
                }
            }
            .pickerStyle(.menu)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.4))
            )
        }
    }
}
