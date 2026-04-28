import SwiftUI

struct EditDepartmentView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: DepartmentViewModel
    
    let departmentId: String
    let departmentName: String
    let businessId: String
    
    @State private var selectedCategoryId: Int
    var onComplete: (() -> Void)?
    
    init(viewModel: DepartmentViewModel, departmentId: String, departmentName: String, businessId: String, initialCategoryId: Int, onComplete: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.departmentId = departmentId
        self.departmentName = departmentName
        self.businessId = businessId
        self.onComplete = onComplete
        _selectedCategoryId = State(initialValue: initialCategoryId)
    }
    
    var body: some View {
        NavigationStack {
            Form {
            
                Section(header: Text("\(ConstantStrings.currentDepartmentPrefix)\(departmentName)")) {
        
                    Picker(ConstantStrings.selectNewCategory, selection: $selectedCategoryId) {
                        if viewModel.categories.isEmpty {

                            Text(ConstantStrings.categoriesLoading).tag(0)
                        }
                        ForEach(viewModel.categories, id: \.id) { category in
                            Text(category.name).tag(category.id)
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle(ConstantStrings.editCategoryTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(ConstantStrings.cancelButton) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(ConstantStrings.updateButton) {
                        Task {
                            await viewModel.updateDepartment(
                                id: departmentId,
                                name: departmentName,
                                categoryId: selectedCategoryId,
                                businessId: businessId
                            )
                            
                            if viewModel.errorMessage == nil {
                                dismiss()
                                onComplete?()
                            }
                        }
                    }
                }
            }
            .task {
                await viewModel.fetchCategories()
            }
        }
    }
}
