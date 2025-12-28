import SwiftUI
import PDFKit
import MapKit

struct ProfileView: View {

    @EnvironmentObject private var appState: AppState

    // ✅ Shared network (tek instance)
    private let network: NetworkManager

    // ✅ ViewModels
    @StateObject private var vm: ProfileViewModel
    @StateObject private var perfVM: ProfilePerformanceViewModel

    // Sheets / Nav
    @State private var showEditPersonalProfile = false
    @State private var showEditCompany = false
    @State private var previewDoc: DocumentToPreview?

    @State private var showQuery = false
    @State private var selectedReportId: String?

    @State private var avatarRefreshToken = UUID()

    private var authRepo: AuthRepositoryProtocol { AuthRepositoryImpl(network: network) }

    init(network: NetworkManager = NetworkManager()) {
        self.network = network

        // Profile VM - mümkünse tek network ile
        _vm = StateObject(wrappedValue: ProfileViewModel(
            authRepo: AuthRepositoryImpl(network: network),
            memberRepo: BusinessMemberRepositoryImpl(network: network),
            businessRepo: BusinessRepositoryImpl(networkManager: network)
        ))

        // Performance VM
        let perfRepo = PerformanceRepositoryImpl(network: network)
        let getReports = GetPerformanceReportsUseCase(repo: perfRepo)
        _perfVM = StateObject(wrappedValue: ProfilePerformanceViewModel(getReportsUseCase: getReports))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {

                if vm.isLoading {
                    ProgressView().padding(.top, 28)
                }

                if let err = vm.errorMessage {
                    Text(err)
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                }

                if let m = vm.managerUI { managerProfile(m) }
                if let e = vm.employeeUI { employeeProfile(e) }

                Spacer().frame(height: 28)
            }
            .padding(.top, 10)
        }
        .background(Color.white)

        .task {
            await vm.loadIfNeeded(appState: appState)
            await loadReportsIfPossible()
        }
        .refreshable {
            await vm.reload(appState: appState)
            await loadReportsIfPossible()
        }

        // ✅ Report detail navigation
        .navigationDestination(isPresented: Binding(
            get: { selectedReportId != nil },
            set: { if !$0 { selectedReportId = nil } }
        )) {
            if let rid = selectedReportId {
                PerformanceReportDetailView(reportId: rid)
            }
        }

        // ✅ Query sheet
        .sheet(isPresented: $showQuery) {
            if let bid = appState.businessId,
               let uid = appState.userId {
                PerformanceQueryView(
                    businessId: bid,
                    employeeUserId: uid,
                    onCreated: { _ in
                        Task { await perfVM.load(businessId: bid, employeeUserId: uid) }
                    }
                )
                .presentationDetents([.large])
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Yükleniyor...")
                        .foregroundColor(.gray)
                }
                .presentationDetents([.medium])
            }
        }

        // ✅ Edit sheets
        .sheet(isPresented: $showEditPersonalProfile, onDismiss: {
            avatarRefreshToken = UUID()
            Task {
                await vm.reload(appState: appState)
                await loadReportsIfPossible()
            }
        }) {
            EditPersonalProfileView(authRepo: authRepo)
        }

        .sheet(isPresented: $showEditCompany, onDismiss: {
            avatarRefreshToken = UUID()
            Task { await vm.reload(appState: appState) }
        }) {
            EditCompanyView(authRepo: authRepo)
        }

        .sheet(item: $previewDoc) { doc in
            DocumentPreviewSheet(title: doc.title, documentId: doc.documentId, network: network)
        }
    }

    // MARK: - Load reports helper
    private func loadReportsIfPossible() async {
        guard let bid = appState.businessId,
              let uid = appState.userId else { return }
        await perfVM.load(businessId: bid, employeeUserId: uid)
    }

    // MARK: - Employee
    private func employeeProfile(_ p: EmployeeProfileUI) -> some View {
        VStack(spacing: 14) {

            VStack(alignment: .leading, spacing: 12) {
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
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(.blue.opacity(0.35), lineWidth: 1))
                            .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 4)
                    }
                }
            }
            .padding(16)
            .headerStyle()
            .padding(.horizontal, 16)

            // ✅ Sorgu + geçmiş (çalışan altında)
            PerformanceSectionView(
                reports: perfVM.reports,
                isLoading: perfVM.isLoading,
                error: perfVM.error,
                onCreateQuery: { showQuery = true },
                onSelectReport: { selectedReportId = $0 }
            )
            .padding(.horizontal, 16)

            VStack(alignment: .leading, spacing: 14) {
                infoSection(title: "Kimlik", value: p.tcIdentityNumber ?? "-")
                infoSection(title: "Email", value: p.email)
                documentsSection(title: "Belgeler", documents: p.documentFiles)
                infoSection(title: "Kalan İzin Günü", value: p.remainingLeaveDaysText)
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Manager
    private func managerProfile(_ m: ManagerProfileUI) -> some View {
        VStack(spacing: 14) {

            VStack(spacing: 14) {
                companyHeaderCard(m)
                companyDetailsSection(m)
                officesSection(offices: m.offices)
            }
            .padding(16)
            .headerStyle()
            .padding(.horizontal, 16)

            Divider()
                .padding(.horizontal, 24)
                .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 12) {

                HStack(alignment: .center, spacing: 12) {
                    let empAbs = network.absoluteURL(from: m.employee.imageUrl)
                    AvatarView(url: empAbs, size: 44, refreshId: avatarRefreshToken)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(m.employee.fullName)
                            .font(.system(size: 18, weight: .semibold))
                        Text("Ünvan: \(m.employee.position ?? "-")")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Text("Gelir: \(m.employee.salaryText ?? "-")")
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
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(.blue.opacity(0.35), lineWidth: 1))
                            .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 4)
                    }
                }

             

                VStack(alignment: .leading, spacing: 14) {
                    infoSection(title: "Kimlik", value: m.employee.tcIdentityNumber ?? "-")
                    infoSection(title: "Email", value: m.employee.email)
                    documentsSection(title: "Belgeler", documents: m.employee.documentFiles)
                }
                
                // ✅ Sorgu + geçmiş (yöneticide çalışan kartı altında)
                PerformanceSectionView(
                    reports: perfVM.reports,
                    isLoading: perfVM.isLoading,
                    error: perfVM.error,
                    onCreateQuery: { showQuery = true },
                    onSelectReport: { selectedReportId = $0 }
                )
            }
            .padding(16)
            .headerStyle()
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Company Header
    private func companyHeaderCard(_ m: ManagerProfileUI) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {

                let companyAbs = network.absoluteURL(from: m.companyImageUrl)
                AvatarView(url: companyAbs, size: 60, refreshId: avatarRefreshToken)

                VStack(alignment: .leading, spacing: 4) {
                    Text(m.companyName)
                        .font(.system(size: 20, weight: .semibold))

                    if let desc = trimmedOrNil(m.companyDescription) {
                        Text("Açıklama: \(desc)")
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
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(Capsule().strokeBorder(.blue.opacity(0.35), lineWidth: 1))
                        .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 4)
                }
            }
        }
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

                let city = trimmedOrNil(m.companyCityLine)
                if let city, city != "-" {
                    infoSection(title: "İl / İlçe", value: city, compact: true)
                }

                if let phone = trimmedOrNil(m.companyPhoneNumber) {
                    tappableInfoRow(title: "Telefon", value: phone) { openPhone(phone) }
                }

                if let addr = trimmedOrNil(m.companyAddress) {
                    infoSection(title: "Adres", value: addr, compact: true)
                }
            }
        }
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
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
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
                .background(Color(.systemGray6))
                .cornerRadius(12)
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
                .background(Color(.systemGray6))
                .cornerRadius(12)
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
                                    .font(.system(size: 16))
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
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
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
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }

    private func trimmedOrNil(_ s: String?) -> String? {
        let t = (s ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
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
        item.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

private extension View {
    func headerStyle() -> some View {
        self
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
    }
}
