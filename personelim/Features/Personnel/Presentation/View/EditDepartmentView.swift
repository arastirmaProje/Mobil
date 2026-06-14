import SwiftUI

struct EditDepartmentView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: DepartmentViewModel

    let departmentId: String
    let departmentName: String
    let businessId: String

    @State private var selectedCategoryId: Int
    @State private var searchText = ""

    var onComplete: (() -> Void)?

    init(
        viewModel: DepartmentViewModel,
        departmentId: String,
        departmentName: String,
        businessId: String,
        initialCategoryId: Int,
        onComplete: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.departmentId = departmentId
        self.departmentName = departmentName
        self.businessId = businessId
        self.onComplete = onComplete
        _selectedCategoryId = State(initialValue: initialCategoryId)
    }

    private var selectedCategoryName: String {
        viewModel.categories
            .first(where: { $0.id == selectedCategoryId })?
            .name ?? "-"
    }

    private var filteredCategories: [JobCategoryDTO] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return viewModel.categories
        }

        return viewModel.categories.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerSection

                        searchSection

                        categoriesSection

                        selectedSummarySection

                        if let error = viewModel.errorMessage {
                            errorCard(error)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }

                bottomUpdateButton
            }
            .navigationTitle(ConstantStrings.editCategoryTitle)
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
            .task {
                await viewModel.fetchCategories()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                Image(systemName: "building.2.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 5) {
                Text(ConstantStrings.editCategoryTitle)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)

                Text(departmentName)
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

    // MARK: - Search

    private var searchSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)

            TextField(ConstantStrings.categorySearchPlaceholder, text: $searchText)
                .font(.system(size: 15, weight: .medium))
                .textInputAutocapitalization(.words)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Categories

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(ConstantStrings.selectNewCategory)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.primary)

                Spacer()

                Text("\(filteredCategories.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.10))
                    )
            }
            .padding(.horizontal, 2)

            if viewModel.categories.isEmpty {
                loadingCard
            } else if filteredCategories.isEmpty {
                emptyCategoryState
            } else {
                VStack(spacing: 0) {
                    ForEach(filteredCategories, id: \.id) { category in
                        categoryRow(category)

                        if category.id != filteredCategories.last?.id {
                            Divider()
                                .padding(.leading, 58)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
            }
        }
    }

    private func categoryRow(_ category: JobCategoryDTO) -> some View {
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                selectedCategoryId = category.id
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected(category) ? Color.blue.opacity(0.10) : Color(.systemGray6))

                    Image(systemName: "building.2.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(isSelected(category) ? .blue : .secondary)
                }
                .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 3) {
                    Text(category.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(isSelected(category) ? ConstantStrings.selectedCategoryText : ConstantStrings.departmentCategoryText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected(category) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(.blue)
                } else {
                    Circle()
                        .stroke(Color.black.opacity(0.14), lineWidth: 1.4)
                        .frame(width: 21, height: 21)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(
                isSelected(category)
                ? Color.blue.opacity(0.035)
                : Color(.systemBackground)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Summary

    private var selectedSummarySection: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 3) {
                Text("\(ConstantStrings.currentDepartmentPrefix)\(departmentName)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(selectedCategoryName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(14)
        .background(Color.blue.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.blue.opacity(0.16), lineWidth: 1)
        )
    }

    // MARK: - States

    private var loadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()

            Text(ConstantStrings.categoriesLoading)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var emptyCategoryState: some View {
        VStack(spacing: 12) {
            Image(systemName: "building.2.crop.circle")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(.blue)

            Text(ConstantStrings.categoryNotFoundTitle)
                .font(.headline)

            Text(ConstantStrings.departmentSearchNoResultDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private func errorCard(_ message: String) -> some View {
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

    // MARK: - Bottom Button

    private var bottomUpdateButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                Task {
                    await viewModel.updateDepartment(
                        id: departmentId,
                        name: departmentName,
                        categoryId: selectedCategoryId,
                        businessId: businessId
                    )

                    if viewModel.errorMessage == nil {
                        onComplete?()
                        dismiss()
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")

                    Text(ConstantStrings.updateButton)
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(selectedCategoryId == 0 ? Color.gray : Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(selectedCategoryId == 0)
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(.regularMaterial)
        }
    }

    // MARK: - Helpers

    private func isSelected(_ category: JobCategoryDTO) -> Bool {
        selectedCategoryId == category.id
    }
}
