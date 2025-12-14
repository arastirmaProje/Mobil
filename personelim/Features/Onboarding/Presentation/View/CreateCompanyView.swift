//
//  CreateCompanyView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 23.11.2025.
//

import SwiftUI

struct CreateCompanyView: View {

    @StateObject private var vm = CreateCompanyViewModel()

    var body: some View {
        VStack(spacing: 0) {

            header

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    Text("Şirket oluştur")
                        .font(.title2.bold())
                        .padding(.top, 12)

                    field("Şirket İsmi", "Şirket adı", $vm.companyName)

                    officeSection

                    cityPicker

                    if vm.showDistricts {
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
                Task { await vm.createCompany() }
            } label: {
                Text(vm.isLoading ? "Oluşturuluyor..." : "Oluştur")
            }
            .disabled(vm.isLoading)
            .buttonStyle(OnboardingButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $vm.showOTP) {
            
                Task {
                    let success = await vm.verifyBusiness(code: code)
                    if success {
                        vm.showOTP = false
                        print("✅ Business verified → Home")
                    }
                }
            }
        }
        .alert(
            vm.errorMessage ?? "",
            isPresented: .constant(vm.errorMessage != nil)
        ) {
            Button("Tamam") { vm.errorMessage = nil }
        }
    }
}

private extension CreateCompanyView {

    var header: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "chevron.left")
                    .padding(10)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(Circle())
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

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

private extension CreateCompanyView {

    var cityPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Şehir")
                .font(.system(size: 14, weight: .medium))

            Picker("Şehir seç", selection: $vm.selectedCity) {
                ForEach(vm.cities, id: \.self) {
                    Text($0)
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

private extension CreateCompanyView {

    var districtPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("İlçe")
                .font(.system(size: 14, weight: .medium))

            Picker("İlçe seç", selection: $vm.selectedDistrict) {
                ForEach(vm.districts[vm.selectedCity] ?? [], id: \.self) {
                    Text($0)
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

