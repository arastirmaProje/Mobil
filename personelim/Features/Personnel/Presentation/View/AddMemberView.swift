
import SwiftUI

struct AddMemberView: View {

    @Environment(\.dismiss) private var dismiss

    @StateObject private var jobTitleViewModel = JobTitleViewModel()
    @StateObject private var memberViewModel = BusinessMemberViewModel()

    let businessId: String
    let departmentId: String

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var salary = ""
    @State private var tcNo = ""
    @State private var selectedPositionId: Int = 0
    @State private var positionSearchText = ""

    private var selectedPositionName: String {
        jobTitleViewModel.jobTitles
            .first(where: { $0.id == selectedPositionId })?
            .name ?? ConstantStrings.selectEmployeePlaceholder
    }

    private var filteredJobTitles: [JobTitleDTO] {
        let query = positionSearchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return jobTitleViewModel.jobTitles
        }

        return jobTitleViewModel.jobTitles.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        email.contains("@") &&
        selectedPositionId != 0
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerSection

                        personalInfoSection

                        jobInfoSection

                        positionSection

                        selectedPositionSummary

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }

                bottomAddButton
            }
            .navigationTitle(ConstantStrings.addMemberNavTitle)
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
                await jobTitleViewModel.fetchJobTitlesByDepartment(
                    departmentId: departmentId
                )
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))

                Image(systemName: "person.badge.plus.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 5) {
                Text(ConstantStrings.addMemberNavTitle)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)

                Text(ConstantStrings.addMemberDescription)
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

    // MARK: - Personal Info

    private var personalInfoSection: some View {
        sectionCard(title: ConstantStrings.personalInfoSectionHeader) {
            inputRow(
                title: ConstantStrings.firstNameLabel,
                text: $firstName,
                icon: "person.fill",
                autocapitalization: .words
            )

            inputRow(
                title: ConstantStrings.lastNameLabel,
                text: $lastName,
                icon: "person.text.rectangle.fill",
                autocapitalization: .words
            )

            inputRow(
                title: ConstantStrings.emailLabel,
                text: $email,
                icon: "envelope.fill",
                keyboard: .emailAddress,
                autocapitalization: .never
            )

            inputRow(
                title: ConstantStrings.tcNoLabel,
                text: $tcNo,
                icon: "number.square.fill",
                keyboard: .numberPad,
                autocapitalization: .never
            )
        }
    }

    // MARK: - Job Info

    private var jobInfoSection: some View {
        sectionCard(title: ConstantStrings.jobInfoSectionHeader) {
            inputRow(
                title: ConstantStrings.salaryPlaceholder,
                text: $salary,
                icon: "turkishlirasign.circle.fill",
                keyboard: .decimalPad,
                autocapitalization: .never
            )
        }
    }

    // MARK: - Position

    private var positionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(ConstantStrings.positionLabel)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 2)

            positionSearchBox

            if filteredJobTitles.isEmpty {
                emptyPositionState
            } else {
                VStack(spacing: 0) {
                    ForEach(filteredJobTitles) { title in
                        positionRow(title)

                        if title.id != filteredJobTitles.last?.id {
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

    private var positionSearchBox: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)

            TextField(ConstantStrings.positionSearchPlaceholder, text: $positionSearchText)
                .font(.system(size: 15, weight: .medium))
                .textInputAutocapitalization(.words)

            if !positionSearchText.isEmpty {
                Button {
                    positionSearchText = ""
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

    private func positionRow(_ title: JobTitleDTO) -> some View {
        Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                selectedPositionId = title.id
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected(title) ? Color.blue.opacity(0.10) : Color(.systemGray6))

                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(isSelected(title) ? .blue : .secondary)
                }
                .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(isSelected(title) ? ConstantStrings.selectedPositionText : ConstantStrings.positionText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected(title) {
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
                isSelected(title)
                ? Color.blue.opacity(0.035)
                : Color(.systemBackground)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Summary

    @ViewBuilder
    private var selectedPositionSummary: some View {
        if selectedPositionId != 0 {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.blue)

                VStack(alignment: .leading, spacing: 3) {
                    Text(ConstantStrings.selectedPositionTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(selectedPositionName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
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
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    private var emptyPositionState: some View {
        VStack(spacing: 12) {
            Image(systemName: "briefcase.circle")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(.blue)

            Text(ConstantStrings.positionNotFoundTitle)
                .font(.headline)

            Text(ConstantStrings.positionNotFoundDescription)
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

    // MARK: - Bottom Button

    private var bottomAddButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                addMemberAction()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.badge.plus.fill")

                    Text(ConstantStrings.addButton)
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(isFormValid ? Color.blue : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!isFormValid)
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(.regularMaterial)
        }
    }

    // MARK: - UI Helpers

    private func sectionCard<Content: View>(
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

    private func inputRow(
        title: String,
        text: Binding<String>,
        icon: String,
        keyboard: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization? = .sentences
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                TextField(title, text: text)
                    .font(.system(size: 15, weight: .medium))
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(autocapitalization)
            }
        }
        .formRowBackground()
    }

    private func isSelected(_ title: JobTitleDTO) -> Bool {
        selectedPositionId == title.id
    }

    // MARK: - Action

    private func addMemberAction() {
        let request = CreateMemberRequestDTO(
            businessId: businessId,
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            positionId: selectedPositionId,
            departmentId: departmentId,
            salary: Double(salary.replacingOccurrences(of: ",", with: ".")) ?? 0.0,
            tcIdentityNumber: tcNo.isEmpty ? nil : tcNo
        )

        Task {
            await memberViewModel.addMember(request: request)
            dismiss()
        }
    }
}

// MARK: - Row Background

private extension View {
    func formRowBackground() -> some View {
        self
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.black.opacity(0.055))
                    .frame(height: 0.7)
                    .padding(.leading, 58)
            }
    }
}

