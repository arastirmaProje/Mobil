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

            Text(ConstantStrings.emailVerificationTitle)
                .font(.title2.bold())

            Text( String(format: ConstantStrings.emailVerificationDescriptionFormat, email))
                .foregroundColor(.gray)

            OTPInputView(code: $code) { otp in
                onCodeEntered(otp)
            }

            Spacer()
        }
        .padding()
    }
}
