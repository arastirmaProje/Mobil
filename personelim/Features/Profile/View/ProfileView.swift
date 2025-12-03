//
//  ProfileView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 2.12.2025.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // ---------------------------------------------------
                // PROFIL BAŞLIK BİLGİLERİ
                // ---------------------------------------------------
                VStack(alignment: .leading, spacing: 12) {
                    
                    HStack(alignment: .center) {
                        
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 60, height: 60)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Yusuf Kaan Usta")
                                .font(.title3.bold())
                            
                            Text("Ünvan: Geliştirici")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("Gelir: 2500TL")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Text("Düzenle")
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.white)
                
                
                }
                .padding(.top, 20)
                
                // ---------------------------------------------------
                // FORM ALANLARI
                // ---------------------------------------------------
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    infoSection(title: "Kimlik", value: "112112112112")
                    infoSection(title: "Email", value: "112112112112")
                    infoSection(title: "CV", value: "Resume")
                    infoSection(title: "Belgeler", value: "Askerlik Belgesi")
                    infoSection(title: "Kalan İzin Günü", value: "4")
                    
                }
                .padding(.horizontal)
                
                // ---------------------------------------------------
                // SORGU
                // ---------------------------------------------------
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Sorgu")
                            .font(.title3.bold())
                        Spacer()
                        Button("Sorgu") { }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    Text("Bu çalışan daha önce sorgulanmamıştır.")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                .padding(.horizontal)
                
                
                // ---------------------------------------------------
                // İZİN
                // ---------------------------------------------------
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    HStack {
                        Text("İzin")
                            .font(.title3.bold())
                        
                        Spacer()
                        
                        Button("Kullan") { }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hastalık")
                                    .bold()
                                
                                Text("Hastalık detayı")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                
                                Text("07/05/2025 - 07/06/2025")
                                    .foregroundColor(.gray)
                                    .font(.footnote)
                            }
                            Spacer()
                            
                            Circle()
                                .fill(Color.gray.opacity(0.4))
                                .frame(width: 22, height: 22)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer().frame(height: 40)
            }
        }
    }
}


/// Form alanı component
private func infoSection(title: String, value: String) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(title)
            .font(.headline)
        
        Text(value)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}
