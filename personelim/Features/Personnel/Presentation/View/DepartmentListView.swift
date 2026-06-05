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
            }
            .navigationTitle("Departmanlar")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $searchQuery,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Departman ara"
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
                        businessId: businessId
                    )
                }
            }
            .sheet(isPresented: $chartVM.showingCustomDatePicker) {
                customDatePickerSheet
            }
            .sheet(isPresented: $showingAddSheet) {
                AddDepartmentView(
                    viewModel: viewModel,
                    businessId: businessId
                )
            }
            .task {
                if viewModel.departments.isEmpty {
                    await viewModel.fetchDepartments(businessId: businessId)
                    await loadChart()
                }
            }
        }
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
                Text("Departmanlar")
                    .font(.title3.weight(.bold))

                Text("\(filteredDepartments.count) departman listeleniyor")
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

            Text(searchQuery.isEmpty ? "Henüz departman yok" : "Sonuç bulunamadı")
                .font(.headline)

            Text(searchQuery.isEmpty
                 ? "Yeni departman ekleyerek listeyi oluşturmaya başlayabilirsin."
                 : "Arama kriterini değiştirerek tekrar deneyebilirsin.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if searchQuery.isEmpty {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Departman Ekle", systemImage: "plus")
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
                    Picker("Sıralama", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.title).tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
    }

    // MARK: - DATE PICKER

    private var customDatePickerSheet: some View {
        NavigationStack {
            Form {
                Section("Tarih Aralığı") {
                    DatePicker(
                        "Başlangıç",
                        selection: $chartVM.chartStartDate,
                        displayedComponents: .date
                    )

                    DatePicker(
                        "Bitiş",
                        selection: $chartVM.chartEndDate,
                        displayedComponents: .date
                    )
                }
            }
            .navigationTitle("Özel Tarih")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") {
                        chartVM.showingCustomDatePicker = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Uygula") {
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
                return "A-Z"
            case .nameZA:
                return "Z-A"
            }
        }
    }
}
