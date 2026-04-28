import SwiftUI

struct AddDepartmentView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: DepartmentViewModel
    let businessId: String

    @State private var selectedCategoryId: Int = 0
    
    private var selectedCategoryName: String {
        viewModel.categories.first(where: { $0.id == selectedCategoryId })?.name ?? ""
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(ConstantStrings.selectSectorHeader)) {
                    Picker(ConstantStrings.sectorLabel, selection: $selectedCategoryId) {
                        Text(ConstantStrings.pickerSelect).tag(0)
                        ForEach(viewModel.categories) { category in
                            Text(category.name).tag(category.id)
                        }
                    }
                    .pickerStyle(.inline)
                }
                
                if selectedCategoryId != 0 {
                    Section {
                        Text(ConstantStrings.departmentToCreateLabel)
                            .foregroundColor(.secondary) +
                        Text(selectedCategoryName)
                            .bold()
                    }
                }
            }
            .navigationTitle(ConstantStrings.addDepartmentTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(ConstantStrings.closeButton) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(ConstantStrings.addButton) {
                        Task {
                            await viewModel.createDepartment(
                                name: selectedCategoryName,
                                businessId: businessId,
                                categoryId: selectedCategoryId
                            )
                            dismiss()
                        }
                    }
                    .disabled(selectedCategoryId == 0)
                }
            }
            .task {
                await viewModel.fetchCategories()
            }
        }
    }
}
