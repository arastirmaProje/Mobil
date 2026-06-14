//

//  PremiumSubscriptionViews.swift

//  personelim

//

//  Created by Tuğberk Acabey on 16.05.2026.

//

import SwiftUI

struct PremiumPromotionCard: View {

    let isSubscribed: Bool

    let onTap: () -> Void

    private var cardColor: Color {

        isSubscribed ? .orange : .blue

    }

    var body: some View {

        Button(action: onTap) {

            HStack(spacing: 14) {

                ZStack {

                    Circle()

                        .fill(cardColor.opacity(0.12))

                    Image(systemName: isSubscribed ? "crown.fill" : "sparkles")

                        .font(.system(size: 20, weight: .semibold))

                        .foregroundStyle(cardColor)

                }

                .frame(width: 46, height: 46)

                VStack(alignment: .leading, spacing: 6) {

                    Text(isSubscribed ? "Premium Aktif" : ConstantStrings.premiumTitle)

                        .font(.system(size: 18, weight: .bold))

                        .foregroundStyle(.primary)

                        .lineLimit(1)

                    Text(

                        isSubscribed

                        ? "Aboneliğiniz aktif. İsterseniz buradan iptal edebilirsiniz."

                        : ConstantStrings.premiumCardDescription

                    )

                    .font(.system(size: 14))

                    .foregroundStyle(.secondary)

                    .fixedSize(horizontal: false, vertical: true)

                }

                Spacer(minLength: 10)

                Text(isSubscribed ? "İptal Et" : "Yükselt")

                    .font(.caption.weight(.bold))

                    .foregroundStyle(cardColor)

                    .padding(.horizontal, 10)

                    .padding(.vertical, 7)

                    .background(

                        Capsule()

                            .fill(cardColor.opacity(0.12))

                    )

                Image(systemName: "chevron.right")

                    .font(.system(size: 13, weight: .semibold))

                    .foregroundStyle(.secondary)

            }

            .padding(.horizontal, 18)

            .padding(.vertical, 15)

            .frame(maxWidth: .infinity, alignment: .leading)

            .background(cardColor.opacity(0.08))

            .overlay(

                RoundedRectangle(cornerRadius: 14, style: .continuous)

                    .stroke(cardColor.opacity(0.35), lineWidth: 1.4)

            )

            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

        }

        .buttonStyle(.plain)

        .accessibilityLabel(

            isSubscribed

            ? "Premium abonelik aktif"

            : ConstantStrings.premiumTitle

        )

    }

}

struct PremiumSubscriptionView: View {

    @StateObject private var viewModel: PremiumSubscriptionViewModel

    @Environment(\.dismiss) private var dismiss

    let businessId: String

    let onSubscriptionChanged: () -> Void

    init(

        businessId: String,

        repository: PremiumSubscriptionRepositoryProtocol = PremiumSubscriptionRepositoryImpl(),

        onSubscriptionChanged: @escaping () -> Void

    ) {

        self.businessId = businessId

        self.onSubscriptionChanged = onSubscriptionChanged

        _viewModel = StateObject(

            wrappedValue: PremiumSubscriptionViewModel(repository: repository)

        )

    }

    var body: some View {

        ScrollView(showsIndicators: false) {

            VStack(spacing: 24) {

                header

                featuresList

                plansContent

            }

            .padding(.horizontal, 28)

            .padding(.top, 26)

            .padding(.bottom, 34)

        }

        .background(Color.white.ignoresSafeArea())

        .navigationBarBackButtonHidden(true)

        .toolbar(.hidden, for: .navigationBar)

        .task {

            await viewModel.loadPlans()

        }

        .alert(ConstantStrings.premiumPurchaseAlertTitle, isPresented: $viewModel.isPurchaseAlertPresented) {

            Button(ConstantStrings.cancelButton, role: .cancel) { }

            Button(ConstantStrings.premiumPurchaseButton) {

                Task {

                    await purchaseSelectedPlan()

                }

            }

        } message: {

            Text(purchaseAlertMessage)

        }

        .alert(ConstantStrings.errorTitle, isPresented: errorBinding) {

            Button(ConstantStrings.okButton, role: .cancel) {

                viewModel.errorMessage = nil

            }

        } message: {

            Text(viewModel.errorMessage ?? ConstantStrings.unknownError)

        }

        .alert(ConstantStrings.premiumTitle, isPresented: successBinding) {

            Button(ConstantStrings.okButton, role: .cancel) {

                viewModel.successMessage = nil

            }

        } message: {

            Text(viewModel.successMessage ?? "")

        }

        .overlay {

            if viewModel.isPurchasing {

                ZStack {

                    Color.black.opacity(0.08).ignoresSafeArea()

                    ProgressView()

                        .padding(18)

                        .background(Color.white)

                        .clipShape(RoundedRectangle(cornerRadius: 12))

                }

            }

        }

    }

    private var header: some View {

        VStack(spacing: 16) {

            HStack {

                Button {

                    dismiss()

                } label: {

                    Image(systemName: "chevron.left")

                        .font(.system(size: 20, weight: .semibold))

                        .foregroundColor(.black)

                        .frame(width: 46, height: 46)

                        .background(Color(.systemGray6))

                        .clipShape(Circle())

                }

                .buttonStyle(.plain)

                Spacer()

            }

            Text(ConstantStrings.premiumTitle)

                .font(.system(size: 26, weight: .bold))

                .lineLimit(1)

                .minimumScaleFactor(0.8)

        }

    }

    private var featuresList: some View {

        VStack(spacing: 8) {

            ForEach(Self.featureTexts, id: \.self) { feature in

                Text(feature)

                    .font(.system(size: 18))

                    .foregroundStyle(.secondary)

                    .multilineTextAlignment(.center)

                    .frame(maxWidth: .infinity)

            }

        }

        .padding(.top, 8)

    }

    @ViewBuilder

    private var plansContent: some View {

        if viewModel.isLoading {

            ProgressView()

                .frame(maxWidth: .infinity)

                .padding(.top, 24)

        } else if viewModel.plans.isEmpty {

            PremiumEmptyPlansView()

        } else {

            VStack(spacing: 18) {

                ForEach(viewModel.plans) { plan in

                    PremiumPlanCard(plan: plan) {

                        viewModel.selectPlan(plan)

                    }

                }

            }

            .padding(.top, 8)

        }

    }

    private var purchaseAlertMessage: String {

        guard let plan = viewModel.selectedPlan else { return "" }

        return String(

            format: ConstantStrings.premiumPurchaseAlertMessageFormat,

            plan.title,

            plan.priceText

        )

    }

    private var errorBinding: Binding<Bool> {

        Binding(

            get: { viewModel.errorMessage != nil },

            set: { if !$0 { viewModel.errorMessage = nil } }

        )

    }

    private var successBinding: Binding<Bool> {

        Binding(

            get: { viewModel.successMessage != nil },

            set: { if !$0 { viewModel.successMessage = nil } }

        )

    }

    private func purchaseSelectedPlan() async {

        let success = await viewModel.purchaseSelectedPlan(

            businessId: businessId

        )

        guard success else { return }

        onSubscriptionChanged()

    }

    private static let featureTexts = [

        ConstantStrings.premiumFeatureAIChatbot,

        ConstantStrings.premiumFeaturePerformance,

        ConstantStrings.premiumFeaturePDF,

        ConstantStrings.premiumFeatureCalendar,

        ConstantStrings.premiumFeatureRoleManagement

    ]

}

private struct PremiumPlanCard: View {

    let plan: PremiumSubscriptionPlan

    let onTap: () -> Void

    var body: some View {

        Button(action: onTap) {

            ZStack(alignment: .top) {

                HStack(spacing: 14) {

                    VStack(alignment: .leading, spacing: 7) {

                        Text(plan.title)

                            .font(.system(size: 25, weight: .bold))

                            .foregroundStyle(.primary)

                        if let subtitle = plan.subtitle {

                            Text(subtitle)

                                .font(.system(size: 18))

                                .foregroundStyle(.secondary)

                                .fixedSize(horizontal: false, vertical: true)

                        }

                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {

                        Text(plan.priceText)

                            .font(.system(size: 22, weight: .bold))

                            .foregroundStyle(.primary)

                        if let originalPrice = plan.originalPriceText {

                            Text(originalPrice)

                                .font(.system(size: 17, weight: .bold))

                                .foregroundStyle(.secondary)

                                .strikethrough()

                        }

                    }

                }

                .padding(.horizontal, 20)

                .padding(.vertical, 22)

                .frame(minHeight: 110)

                .frame(maxWidth: .infinity)

                .background(

                    plan.isHighlighted

                    ? Color.blue.opacity(0.18)

                    : Color(.systemGray6)

                )

                .overlay(

                    RoundedRectangle(cornerRadius: 10)

                        .stroke(

                            plan.isHighlighted ? Color.blue : Color.clear,

                            lineWidth: 3

                        )

                )

                .clipShape(RoundedRectangle(cornerRadius: 10))

                if let badgeText = plan.badgeText {

                    Text(badgeText)

                        .font(.system(size: 16, weight: .semibold))

                        .foregroundStyle(.white)

                        .padding(.horizontal, 10)

                        .padding(.vertical, 6)

                        .background(Color.blue)

                        .clipShape(RoundedRectangle(cornerRadius: 5))

                        .offset(y: -18)

                }

            }

        }

        .buttonStyle(.plain)

    }

}

private struct PremiumEmptyPlansView: View {

    var body: some View {

        VStack(spacing: 8) {

            Text(ConstantStrings.premiumPlansEmptyTitle)

                .font(.system(size: 17, weight: .semibold))

                .foregroundStyle(.primary)

            Text(ConstantStrings.premiumPlansEmptyDescription)

                .font(.system(size: 14))

                .foregroundStyle(.secondary)

                .multilineTextAlignment(.center)

        }

        .padding(18)

        .frame(maxWidth: .infinity)

        .background(Color(.systemGray6))

        .clipShape(RoundedRectangle(cornerRadius: 10))

    }

}
