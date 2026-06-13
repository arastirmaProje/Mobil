import SwiftUI

@available(iOS 17.0, *)
struct DepartmentPerformanceQueryView: View {

    @Environment(\.dismiss) private var dismiss

    let businessId: String
    let departmentId: String
    let onCreated: () -> Void

    @StateObject private var vm = DepartmentPerformanceViewModel()

    @State private var startDate: Date?
    @State private var endDate: Date?

    private var canSubmit: Bool {
        !vm.isLoading && startDate != nil && endDate != nil
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerSection

                        calendarSection

                        if let errorMessage = vm.errorMessage {
                            errorCard(errorMessage)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }

                bottomSubmitButton
            }
            .navigationTitle(ConstantStrings.departmentPerformanceQueryButton)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
        }
    }
}

// MARK: - Sections

@available(iOS 17.0, *)
private extension DepartmentPerformanceQueryView {

    var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                Image(systemName: "building.2.crop.circle.fill")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 58, height: 58)

            VStack(alignment: .leading, spacing: 5) {
                Text(ConstantStrings.departmentPerformanceQueriesTitle)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(ConstantStrings.departmentPerformanceQueryInstruction)
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

    var calendarSection: some View {
        sectionCard(title: ConstantStrings.dateRangeSectionTitle) {
            VStack(spacing: 14) {
                RangeCalendarCard(
                    startDate: $startDate,
                    endDate: $endDate
                )
                .disabled(vm.isLoading)

                HStack(spacing: 0) {
                    dateSummaryBox(
                        title: ConstantStrings.startTitle,
                        value: startDate?.trShortDate() ?? ConstantStrings.dashPlaceholder,
                        icon: "calendar"
                    )

                    Divider()
                        .padding(.vertical, 10)

                    dateSummaryBox(
                        title: ConstantStrings.endTitle,
                        value: endDate?.trShortDate() ?? ConstantStrings.dashPlaceholder,
                        icon: "calendar.badge.clock"
                    )
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
            }
            .padding(14)
            .background(Color(.systemBackground))
        }
    }

    var bottomSubmitButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                Task {
                    guard canSubmit else { return }
                    guard let startDate, let endDate else { return }

                    vm.startDate = startDate
                    vm.endDate = endDate

                    await vm.load(
                        businessId: businessId,
                        departmentId: departmentId
                    )

                    if vm.errorMessage == nil {
                        onCreated()
                        dismiss()
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if vm.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "sparkle.magnifyingglass")
                    }

                    Text(
                        vm.isLoading
                        ? ConstantStrings.bulkQueryLoading
                        : ConstantStrings.createQueryButton
                    )
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

// MARK: - UI Pieces

@available(iOS 17.0, *)
private extension DepartmentPerformanceQueryView {

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

    func dateSummaryBox(
        title: String,
        value: String,
        icon: String
    ) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(
                        value == ConstantStrings.dashPlaceholder
                        ? .secondary
                        : .primary
                    )
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.systemBackground))
    }

    func errorCard(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            Text(message)
                .font(.caption)
                .foregroundStyle(.red)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.red.opacity(0.25), lineWidth: 1)
        )
    }
}
