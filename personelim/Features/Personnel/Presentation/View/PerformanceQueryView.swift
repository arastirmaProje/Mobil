//
//  PerformanceQueryView.swift
//  personelim
//
//  Created by Yusuf Kaan USTA on 25.12.2025.
//

import SwiftUI

@available(iOS 17.0, *)
struct PerformanceQueryView: View {

    @Environment(\.dismiss) private var dismiss

    let businessId: String
    let employeeUserId: String
    let onCreated: (PerformanceReportDTO) -> Void

    @StateObject private var vm: PerformanceQueryViewModel

    @State private var startDate: Date?
    @State private var endDate: Date?

    init(
        businessId: String,
        employeeUserId: String,
        onCreated: @escaping (PerformanceReportDTO) -> Void
    ) {
        self.businessId = businessId
        self.employeeUserId = employeeUserId
        self.onCreated = onCreated

        let repo = PerformanceRepositoryImpl(network: NetworkManager())
        let useCase = QueryPerformanceUseCase(repo: repo)
        _vm = StateObject(wrappedValue: PerformanceQueryViewModel(queryUseCase: useCase))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    VStack(alignment: .leading, spacing: 6) {
                        Text(ConstantStrings.performanceQueryTitle)
                            .font(.title.bold())
                        
                        Text(ConstantStrings.performanceQuerySubtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    RangeCalendarCard(
                        startDate: $startDate,
                        endDate: $endDate
                    )
                    .disabled(vm.isLoading)

                    HStack(spacing: 24) {
                        VStack(alignment: .leading) {
                            Text(ConstantStrings.startTitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(startDate?.trShortDate() ?? "-")
                                .font(.body.bold())
                        }

                        VStack(alignment: .leading) {
                            Text(ConstantStrings.endTitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(endDate?.trShortDate() ?? "-")
                                .font(.body.bold())
                        }
                    }
                    .padding(.horizontal)

                    if let err = vm.errorMessage {
                        Text(err)
                            .foregroundColor(.red)
                            .font(.system(size: 13))
                            .padding(.horizontal)
                    }

                    Spacer(minLength: 32)
                }
                .padding(.vertical, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            guard !vm.isLoading else { return }
                            guard let s = startDate, let e = endDate else { return }
                            vm.startDate = s
                            vm.endDate = e
                            if let report = await vm.submit(
                                businessId: businessId,
                                employeeUserId: employeeUserId
                            ) {
                                onCreated(report)
                                dismiss()
                            }
                        }
                    } label: {
                        toolbarSubmitLabel
                    }
                    .disabled(vm.isLoading || startDate == nil || endDate == nil)
                }
            }
        }
    }

    @ViewBuilder
    private var toolbarSubmitLabel: some View {
        if vm.isLoading {
            ProgressView()
                .controlSize(.small)
                .frame(width: 24, height: 24)
        } else {
            Image(systemName: "checkmark")
                .font(.headline)
        }
    }
}
