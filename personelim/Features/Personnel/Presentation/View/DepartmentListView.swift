import SwiftUI

struct DepartmentListView: View {

    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = DepartmentViewModel()
    @StateObject private var chartVM = DepartmentChartViewModel()

    @State private var showingAddSheet = false
    @State private var searchQuery = ""
    @State private var sortOption: SortOption = .nameAZ
    @State private var selectedDepartment: DepartmentResponseDTO?

    private var businessId: String {
        TokenStore.shared.selectedBusinessId ?? ""
    }

    private var filteredDepartments: [DepartmentResponseDTO] {
        filterAndSortDepartments(viewModel.departments)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                List {
                    chartSection

                    departmentHeaderSection

                    if filteredDepartments.isEmpty {
                        emptyDepartmentSection
                    } else {
                        departmentRows
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(.systemBackground))
                .refreshable {
                    await refreshDepartments()
                }
            }
            .navigationTitle(ConstantStrings.departmentsNavTitle)
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $searchQuery,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: ConstantStrings.departmentSearchPrompt
            )
            .toolbar { toolbarContent }
            .navigationDestination(
                isPresented: Binding(
                    get: {
                        selectedDepartment != nil
                    },
                    set: { isPresented in
                        if !isPresented {
                            selectedDepartment = nil
                        }
                    }
                )
            ) {
                if let dept = selectedDepartment {
                    DepartmentDetailView(
                        departmentId: dept.id,
                        departmentName: dept.name,
                        departmentCategoryId: dept.categoryId,
                        businessId: businessId,
                        onChanged: {
                            Task {
                                await refreshDepartments()
                            }
                        }
                    )
                }
            }
            .sheet(isPresented: $chartVM.showingCustomDatePicker) {
                customDatePickerSheet
            }
            .sheet(
                isPresented: $showingAddSheet,
                onDismiss: {
                    Task {
                        await refreshDepartments()
                    }
                }
            ) {
                AddDepartmentView(
                    viewModel: viewModel,
                    businessId: businessId
                )
            }
            .task {
                if viewModel.departments.isEmpty {
                    await refreshDepartments()
                }
            }
        }
    }

    // MARK: - REFRESH

    private func refreshDepartments() async {
        await viewModel.fetchDepartments(businessId: businessId)
        await loadChart()
    }

    // MARK: - CHART DATA LOAD

    private func loadChart() async {
        await viewModel.fetchDepartmentCharts(
            businessId: businessId,
            startDate: chartVM.chartStartDate,
            endDate: chartVM.chartEndDate
        )

        await MainActor.run {
            if let graph = viewModel.businessCharts?.grafikVerisi {
                chartVM.setBusinessGraph(graph)
            }
        }
    }

    // MARK: - CHART SECTION

    private var chartSection: some View {
        DepartmentChartSectionView(
            viewModel: chartVM,
            reloadChartData: loadChart
        )
        .listRowInsets(EdgeInsets(top: 14, leading: 16, bottom: 12, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    // MARK: - HEADER SECTION

    private var departmentHeaderSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(ConstantStrings.departmentsNavTitle)
                    .font(.title3.weight(.bold))

                Text(String(format: ConstantStrings.departmentListedCountFormat, filteredDepartments.count))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            sortBadge
        }
        .padding(.horizontal, 2)
        .padding(.top, 6)
        .listRowInsets(EdgeInsets(top: 4, leading: 18, bottom: 8, trailing: 18))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private var sortBadge: some View {
        Text(sortOption.title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.blue)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(Color.blue.opacity(0.12))
            )
    }

    // MARK: - ROWS

    private var departmentRows: some View {
        ForEach(filteredDepartments, id: \.id) { dept in
            Button {
                selectedDepartment = dept
            } label: {
                DepartmentCardView(department: dept)
            }
            .buttonStyle(.plain)
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }

    // MARK: - EMPTY STATE

    private var emptyDepartmentSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "building.2.crop.circle")
                .font(.system(size: 38))
                .foregroundStyle(.secondary)

            Text(searchQuery.isEmpty ? ConstantStrings.noDepartmentYetTitle : ConstantStrings.departmentSearchNoResultTitle)
                .font(.headline)

            Text(searchQuery.isEmpty ? ConstantStrings.noDepartmentYetDescription : ConstantStrings.departmentSearchNoResultDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if searchQuery.isEmpty {
                Button {
                    showingAddSheet = true
                } label: {
                    Label(ConstantStrings.addDepartmentTitle, systemImage: "plus")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.blue)
                        )
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    // MARK: - FILTER + SORT

    private func filterAndSortDepartments(_ depts: [DepartmentResponseDTO]) -> [DepartmentResponseDTO] {
        let filtered = searchQuery.isEmpty
            ? depts
            : depts.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery)
            }

        return filtered.sorted {
            switch sortOption {
            case .nameAZ:
                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            case .nameZA:
                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending
            }
        }
    }

    // MARK: - TOOLBAR

    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker(ConstantStrings.sortTitle, selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.title).tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 24, weight: .semibold))
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 24, weight: .semibold))
                }
            }
        }
    }

    // MARK: - DATE PICKER

    private var customDatePickerSheet: some View {
        NavigationStack {
            Form {
                Section(ConstantStrings.dateRangeSectionTitle) {
                    DatePicker(ConstantStrings.startTitle, selection: $chartVM.chartStartDate, displayedComponents: .date)

                    DatePicker(ConstantStrings.endTitle, selection: $chartVM.chartEndDate, displayedComponents: .date)
                }
            }
            .navigationTitle(ConstantStrings.customDateTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(ConstantStrings.cancelAction) {
                        chartVM.showingCustomDatePicker = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(ConstantStrings.applyAction) {
                        chartVM.showingCustomDatePicker = false

                        Task {
                            await loadChart()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - SORT ENUM

    private enum SortOption: CaseIterable {
        case nameAZ
        case nameZA

        var title: String {
            switch self {
            case .nameAZ:
                return ConstantStrings.sortAZ
            case .nameZA:
                return ConstantStrings.sortZA
            }
        }
    }
}
