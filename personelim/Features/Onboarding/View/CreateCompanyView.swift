//
//  CreateCompanyView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 23.11.2025.
//


import SwiftUI

struct CreateCompanyView: View {
    
    @StateObject private var vm = CreateCompanyViewModel()
    @State private var showVerifySheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            header
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("Şirket oluştur")
                        .font(.title2.bold())
                        .padding(.top, 12)
                    
                    // MARK: — Şirket Bilgileri
                    field("Şirket İsmi", "Name", $vm.companyName)
                    field("Email", "damn@gmail.com", $vm.email)
                    secureField("Şifre", "123...", $vm.password)
                    
                    // MARK: — Ofis Ekleme
                    officeSection
                    
                    // MARK: — Şehir
                    cityPicker
                    
                    // MARK: — İlçe
                    if vm.showDistricts {
                        districtPicker
                    }
                    
                    // MARK: — Ek Alanlar
                    field("Detaylı Adres", "Adres gir", $vm.detailedAddress)
                    field("Telefon", "555 555 55 55", $vm.phone)
                    field("Açıklama", "Açıklama gir", $vm.description)
                    
                    Spacer().frame(height: 12)
                }
                .padding(.horizontal, 20)
            }
            
            // MARK: — Oluştur Butonu
            Button("Oluştur") {
                if vm.isFormValid() {
                    // Şimdilik direkt şirket oluşturmuyoruz,
                    // önce email doğrulama için sheet açıyoruz.
                    showVerifySheet = true
                } else {
                    print("Form geçersiz! Zorunlu alanları doldur.")
                }
            }
            .buttonStyle(OnboardingButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showVerifySheet) {
            EmailVerifyView(email: vm.email) { code in
                vm.verifyOTPAndCreateCompany(otp: code) { success in
                    if success {
                        showVerifySheet = false
                        print("✅ Şirket oluşturuldu! (Buradan Home / Login'e yönlendirebilirsin.)")
                    } else {
                        print("❌ OTP hatalı veya oluşturma başarısız.")
                        // İstersen burada hata state tutup UI'da gösterebilirsin.
                    }
                }
            }
        }
    }
}

// MARK: - HEADER

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

// MARK: - FIELD COMPONENTS

private extension CreateCompanyView {
    
    func field(_ label: String, _ placeholder: String, _ text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
            
            TextField(placeholder, text: text)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.gray.opacity(0.4))
                )
        }
    }
    
    func secureField(_ label: String, _ placeholder: String, _ text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
            
            SecureField(placeholder, text: text)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.gray.opacity(0.4))
                )
        }
    }
}

// MARK: - OFİS BÖLÜMÜ

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
            
            ForEach(vm.offices.indices, id: \.self) { i in
                VStack(alignment: .leading, spacing: 6) {
                    
                    HStack {
                        Text("Ofis \(vm.offices[i].index)")
                            .font(.system(size: 14, weight: .medium))
                        Spacer()
                        
                        if i == vm.offices.count - 1 {
                            Button(action: vm.removeLastOffice) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    TextField("Adres", text: $vm.offices[i].address)
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

// MARK: - Office Model

struct Office: Identifiable {
    let id = UUID()
    let index: Int
    var address: String
}

// MARK: - Preview

struct CreateCompanyView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CreateCompanyView()
                .previewDevice("iPhone 15 Pro")
            
            CreateCompanyView()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
        }
    }
}
