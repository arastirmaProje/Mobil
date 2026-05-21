import SwiftUI
import PDFKit
import MapKit

struct ProfileView: View {

    @EnvironmentObject private var appState: AppState

    private let network: NetworkManager

    @StateObject private var vm: ProfileViewModel
    @StateObject private var perfVM: ProfilePerformanceViewModel
    @StateObject private var slackVM: SlackIntegrationViewModel

    @State private var showCreateLeave = false
    @State private var showEditPersonalProfile = false
    @State private var showEditCompany = false
    @State private var showAddSlackIntegration = false
    @State private var showPremiumSubscription = false
    @State private var showQuery = false
    @State private var selectedReportId: String?
    @State private var selectedSlackIntegration: SlackIntegration?
    @State private var previewDoc: DocumentToPreview?
    @State private var avatarRefreshToken = UUID()
    
    @State private var isInitialLoad = true 

    // MARK: - Repos
    private var authRepo: AuthRepositoryProtocol {
        AuthRepositoryImpl(network: network)
    }

    // MARK: - Init
    init(network: NetworkManager = NetworkManager()) {
        self.network = network

        _vm = StateObject(
            wrappedValue: ProfileViewModel(
                memberRepo: BusinessMemberRepositoryImpl(network: network),
                leaveRepo: LeaveRepositoryImpl(network: network)
            )
        )

        let perfRepo = PerformanceRepositoryImpl(network: network)
        let getReports = GetPerformanceReportsUseCase(repo: perfRepo)
        _perfVM = StateObject(
            wrappedValue: ProfilePerformanceViewModel(
                getReportsUseCase: getReports
            )
        )

        _slackVM = StateObject(
            wrappedValue: SlackIntegrationViewModel(
                repository: SlackWebhookRepositoryImpl(network: network)
            )
        )
    }

    // MARK: - Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {

                if vm.isLoading && isInitialLoad {
                    ProgressView()
                        .padding(.top, 28)
                }

                if let err = vm.errorMessage {
                    Text(err)
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                }

                if appState.businessId != nil {
                    PremiumPromotionCard(
                        isSubscribed: appState.companyDTO?.isSubscribed ?? false,
                        onTap: { showPremiumSubscription = true }
                    )
                    .padding(.horizontal, 16)
                }

                if let m = vm.managerUI {
                    managerProfile(m)
                }

                if let e = vm.employeeUI {
                    employeeProfile(e)
                }

                Spacer().frame(height: 28)
            }
            .padding(.top, 10)
        }
        .background(Color.white.ignoresSafeArea())
        .task {
            await vm.loadIfNeeded(appState: appState)
            await loadReportsIfPossible()
            await loadSlackIfPossible()
            isInitialLoad = false
        }
        .refreshable {
            await vm.reload(appState: appState)
            await loadReportsIfPossible()
            await loadSlackIfPossible()
        }
        // MARK: - Sheets
        .sheet(isPresented: $showEditPersonalProfile, onDismiss: {
            avatarRefreshToken = UUID()
            Task { await vm.reload(appState: appState) }
        }) {
            EditPersonalProfileView(authRepo: authRepo)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showEditCompany, onDismiss: {
            avatarRefreshToken = UUID()
            Task { await vm.reload(appState: appState) }
        }) {
            EditCompanyView(authRepo: authRepo)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showCreateLeave) {
            if let bid = appState.businessId {
                CreateLeaveView(businessId: bid)
                    .presentationDetents([.large])
            } else {
                loadingSheet()
            }
        }
        .sheet(isPresented: $showQuery) {
            if let bid = appState.businessId, let uid = appState.userId {
                PerformanceQueryView(
                    businessId: bid,
                    employeeUserId: uid,
                    onCreated: { _ in
                        Task { await perfVM.load(businessId: bid, employeeUserId: uid) }
                    }
                )
                .presentationDetents([.large])
            } else {
                loadingSheet()
            }
        }
        .sheet(item: $previewDoc) { doc in
            DocumentPreviewSheet(
                title: doc.title,
                documentId: doc.documentId,
                network: network
            )
            .presentationDetents([.large])
        }
        // MARK: - Navigation
        .navigationDestination(
            isPresented: Binding(
                get: { selectedReportId != nil },
                set: { if !$0 { selectedReportId = nil } }
            )
        ) {
            if let rid = selectedReportId {
                PerformanceReportDetailView(reportId: rid)
            }
        }
        .navigationDestination(isPresented: $showAddSlackIntegration) {
            if let bid = appState.businessId {
                SlackIntegrationEditorView(
                    viewModel: slackVM,
                    businessId: bid,
                    integration: nil
                )
            } else {
                loadingSheet()
            }
        }
        .navigationDestination(isPresented: $showPremiumSubscription) {
            if let bid = appState.businessId {
                PremiumSubscriptionView(
                    businessId: bid,
                    repository: PremiumSubscriptionRepositoryImpl(network: network),
                    onSubscriptionChanged: {
                        Task { await vm.reload(appState: appState) }
                    }
                )
            } else {
                loadingSheet()
            }
        }
        .navigationDestination(item: $selectedSlackIntegration) { integration in
            if let bid = appState.businessId {
                SlackIntegrationEditorView(
                    viewModel: slackVM,
                    businessId: bid,
                    integration: integration
                )
            } else {
                loadingSheet()
            }
        }
    }

    // MARK: - Employee Profile
    private func employeeProfile(_ p: EmployeeProfileUI) -> some View {
        VStack(spacing: 14) {
            HStack(alignment: .center, spacing: 12) {

                let abs = network.absoluteURL(from: p.imageUrl)
                AvatarView(url: abs, size: 60, refreshId: avatarRefreshToken)

                VStack(alignment: .leading, spacing: 4) {
                    Text(p.fullName)
                        .font(.system(size: 20, weight: .semibold))

                    Text("Ünvan: \(p.position ?? "-")")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    Text("Gelir: \(p.salaryText ?? "-")")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: { showEditPersonalProfile = true }) {
                    Text("Düzenle")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .headerStyle()
            
            infoSection(title: "Kimlik", value: p.tcIdentityNumber ?? "-")
            infoSection(title: "Email", value: p.email)

            documentsSection(title: "Belgeler", documents: p.documentFiles)
            
            LeaveSectionView(
                remainingDaysText: p.remainingLeaveDaysText,
                onCreateLeave: { showCreateLeave = true }
            )

            PerformanceSectionView(
                reports: perfVM.reports,
                isLoading: perfVM.isLoading,
                error: perfVM.error,
                onCreateQuery: { showQuery = true },
                onSelectReport: { selectedReportId = $0 }
            )
        }
    }

    // MARK: - Manager Profile
    private func managerProfile(_ m: ManagerProfileUI) -> some View {
        VStack(spacing: 16) {

            companyHeaderCard(m)

            companyDetailsSection(m)
            officesSection(offices: m.offices)
            SlackIntegrationSection(
                integrations: slackVM.integrations,
                isLoading: slackVM.isLoading,
                onAdd: { showAddSlackIntegration = true },
                onSelect: { selectedSlackIntegration = $0 }
            )

            Divider()
                .padding(.vertical, 8)

            employeeProfile(m.employee)

        }
        .padding(.horizontal, 16)
    }

    // MARK: - Company Header
    private func companyHeaderCard(_ m: ManagerProfileUI) -> some View {
        HStack(spacing: 12) {

            let abs = network.absoluteURL(from: m.companyImageUrl)
            AvatarView(url: abs, size: 60, refreshId: avatarRefreshToken)

            VStack(alignment: .leading, spacing: 4) {
                Text(m.companyName)
                    .font(.system(size: 20, weight: .semibold))

                if let desc = trimmedOrNil(m.companyDescription) {
                    Text(desc)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Button(action: { showEditCompany = true }) {
                Text("Düzenle")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

        }
        .headerStyle()
    }

    // MARK: - Company Details
    private func companyDetailsSection(_ m: ManagerProfileUI) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Şirket Bilgileri")
                .font(.system(size: 16, weight: .semibold))

            VStack(alignment: .leading, spacing: 10) {
                infoSection(title: "Email", value: m.companyEmail, compact: true)
                if let officeName = trimmedOrNil(m.companyLocationName) {
                    infoSection(title: "Ana Ofis", value: officeName, compact: true)
                }
                if let city = trimmedOrNil(m.companyCityLine), city != "-" {
                    infoSection(title: "İl / İlçe", value: city, compact: true)
                }
                if let phone = trimmedOrNil(m.companyPhoneNumber) {
                    tappableInfoRow(title: "Telefon", value: phone) {
                        openPhone(phone)
                    }
                }
                if let addr = trimmedOrNil(m.companyAddress) {
                    infoSection(title: "Adres", value: addr, compact: true)
                }
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Offices
    private func officesSection(offices: [OfficeUI]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ofisler")
                .font(.system(size: 16, weight: .semibold))

            if offices.isEmpty {
                emptyRow(text: "-")
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(offices.enumerated()), id: \.element.id) { idx, o in
                        Button {
                            openAppleMaps(for: o)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "building.2")
                                    .foregroundColor(.secondary)
                                Text(o.name.isEmpty ? "Ofis \(idx + 1)" : o.name)
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(!o.hasCoordinate)
                    }
                }
            }
        }
    }

    // MARK: - Helpers
    private func infoSection(title: String, value: String, compact: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: compact ? 6 : 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)

            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .padding(compact ? 12 : 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
                )
        }
    }

    private func tappableInfoRow(title: String, value: String, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                HStack {
                    Text(value)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "phone.fill")
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
                )
            }
        }
        .buttonStyle(.plain)
    }

    private func documentsSection(title: String, documents: [BusinessMemberDocumentDTO]?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)

            let docs = documents ?? []
            if docs.isEmpty {
                emptyRow(text: "-")
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(docs, id: \.id) { d in
                        Button {
                            previewDoc = .init(id: d.id, title: d.fileName, documentId: d.id)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.secondary)
                                Text(d.fileName)
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func emptyRow(text: String) -> some View {
        Text(text)
            .font(.system(size: 16))
            .foregroundColor(.secondary)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
            )
    }

    private func trimmedOrNil(_ s: String?) -> String? {
        let t = (s ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }

    private func loadReportsIfPossible() async {
        guard let bid = appState.businessId, let uid = appState.userId else { return }
        await perfVM.load(businessId: bid, employeeUserId: uid)
    }

    private func loadSlackIfPossible() async {
        guard appState.role.canSeePersonnelTab, let bid = appState.businessId else { return }
        await slackVM.load(businessId: bid)
    }

    private func openPhone(_ phone: String) {
        let digits = phone.filter { "0123456789+".contains($0) }
        guard let url = URL(string: "tel://\(digits)") else { return }
        UIApplication.shared.open(url)
    }

    private func openAppleMaps(for office: OfficeUI) {
        guard office.hasCoordinate,
              let lat = office.latitude,
              let lng = office.longitude else { return }

        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let item = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        item.name = office.name
        item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    private func loadingSheet() -> some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Yükleniyor...")
                .foregroundColor(.gray)
        }
        .padding()
        .presentationDetents([.medium])
    }
}

// MARK: - View Modifier
private extension View {
    func headerStyle() -> some View {
        self
            .background(Color.white)
    }
}
