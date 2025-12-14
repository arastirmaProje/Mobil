//
//  EmailVerifyView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 24.11.2025.
//

import SwiftUI

struct EmailVerifyView: View {

    let email: String
    let onCodeEntered: (String) -> Void

    @State private var code = ""

    var body: some View {
        VStack(spacing: 24) {

            Text("Email Doğrulama")
                .font(.title2.bold())
                .padding(.top, 32)

            Text("\(email) adresine gönderilen doğrulama kodunu giriniz.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            TextField("6 haneli kod", text: $code)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
                .onChange(of: code) { newValue in
                    if newValue.count == 6 {
                        onCodeEntered(newValue)
                    }
                }

            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

