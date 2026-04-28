import SwiftUI

struct DepartmentListView: View {
    @StateObject private var viewModel = DepartmentViewModel()
    @State private var showingAddSheet = false
    
    private var businessId: String {
        TokenStore.shared.selectedBusinessId ?? ""
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView(ConstantStrings.loadingText)
                } else if viewModel.departments.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "building.2.crop.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text(ConstantStrings.noDepartmentsFound)
                            .foregroundColor(.secondary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.departments, id: \.id) { dept in
                                NavigationLink(value: dept) {
                                    DepartmentCardView(department: dept)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(ConstantStrings.departmentsNavTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchDepartments(businessId: businessId)
                }
            }
            .navigationDestination(for: DepartmentResponseDTO.self) { dept in
                DepartmentDetailView(
                    departmentId: dept.id,
                    departmentName: dept.name,
                    businessId: businessId
                )
            }
            .sheet(isPresented: $showingAddSheet) {
                AddDepartmentView(viewModel: viewModel, businessId: businessId)
            }
        }
    }
}
