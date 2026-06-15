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
    @State private var showUnsubscribeAlert = false
    @State private var showLeaveManagement = false
    @State private var showMyLeaves = false

    @State private var selectedReportId: String?
    @State private var selectedSlackIntegration: SlackIntegration?
    @State private var previewDoc: DocumentToPreview?
    @State private var avatarRefreshToken = UUID()

    @State private var isInitialLoad = true

    private var authRepo: AuthRepositoryProtocol {
        AuthRepositoryImpl(network: network)
    }

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

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {

                if vm.isLoading && isInitialLoad {
                    loadingCard
                }

                if let err = vm.errorMessage {
                    errorCard(err)
                }

                if appState.role.canSeePersonnelTab,
                   appState.businessId != nil {
                    PremiumPromotionCard(
                        isSubscribed: appState.companyDTO?.isSubscribed == true,
                        onTap: {
                            if appState.companyDTO?.isSubscribed == true {
                                showUnsubscribeAlert = true
                            } else {
                                showPremiumSubscription = true
                            }
                        }
                    )
                    .padding(.horizontal, 16)
                }

                logoutSection
                    .padding(.horizontal, 16)

                if let m = vm.managerUI {
                    managerProfile(m)
                }

                if let e = vm.employeeUI {
                    employeeProfile(e)
                        .padding(.horizontal, 16)
                }

                Spacer().frame(height: 28)
            }
            .padding(.top, 12)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle(ConstantStrings.tabProfileTitle)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await vm.loadIfNeeded(appState: appState)
            await loadReportsIfPossible()
            await loadSlackIfPossible()
            isInitialLoad = false
        }
        .refreshable {
            await vm.reload(appState: appState)
            await loadSlackIfPossible()
        }
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
        .sheet(isPresented: $showCreateLeave, onDismiss: {
            Task {
                await vm.reload(appState: appState)
            }
        }) {
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
                        Task {
                            await perfVM.load(
                                businessId: bid,
                                employeeUserId: uid
                            )
                        }
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
        .navigationDestination(isPresented: $showMyLeaves) {
            if let employee = currentEmployeeUI {
                MyLeavesView(leaves: employee.leaveRequests)
            } else {
                loadingSheet()
            }
        }
        .navigationDestination(isPresented: $showLeaveManagement) {
            if let bid = appState.businessId {
                LeaveManagementView(businessId: bid)
            } else {
                loadingSheet()
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
                        Task {
                            await appState.bootstrap(
                                authRepository: AuthRepositoryImpl(network: network),
                                businessRepository: BusinessRepositoryImpl(networkManager: network),
                                businessMemberRepository: BusinessMemberRepositoryImpl(network: network)
                            )

                            await vm.reload(appState: appState)
                        }
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
        .confirmationDialog(
            ConstantStrings.unsubscribePremiumConfirmationTitle,
            isPresented: $showUnsubscribeAlert,
            titleVisibility: .visible
        ) {
            Button(ConstantStrings.unsubscribePremiumButton, role: .destructive) {
                Task {
                    guard let businessId = appState.businessId else { return }

                    let success = await vm.unsubscribeBusiness(
                        businessId: businessId
                    )

                    if success {
                        await appState.bootstrap(
                            authRepository: AuthRepositoryImpl(network: network),
                            businessRepository: BusinessRepositoryImpl(networkManager: network),
                            businessMemberRepository: BusinessMemberRepositoryImpl(network: network)
                        )

                        await vm.reload(appState: appState)
                        await loadSlackIfPossible()
                    }
                }
            }

            Button(ConstantStrings.cancelButton, role: .cancel) { }
        }
        .alert(
            ConstantStrings.errorTitle,
            isPresented: Binding(
                get: { vm.logoutErrorMessage != nil },
                set: { if !$0 { vm.logoutErrorMessage = nil } }
            )
        ) {
            Button(ConstantStrings.okButton, role: .cancel) { }
        } message: {
            Text(vm.logoutErrorMessage ?? ConstantStrings.unknownError)
        }
        .alert(
            ConstantStrings.errorTitle,
            isPresented: Binding(
                get: { vm.unsubscribeErrorMessage != nil },
                set: { if !$0 { vm.unsubscribeErrorMessage = nil } }
            )
        ) {
            Button(ConstantStrings.okButton, role: .cancel) { }
        } message: {
            Text(vm.unsubscribeErrorMessage ?? ConstantStrings.unknownError)
        }
    }

    private var currentEmployeeUI: EmployeeProfileUI? {
        vm.employeeUI ?? vm.managerUI?.employee
    }

    // MARK: - Employee Profile

    private func employeeProfile(
        _ p: EmployeeProfileUI,
        showsSalary: Bool = true
    ) -> some View {
        VStack(spacing: 14) {

            profileHeaderCard(
                imageUrl: p.imageUrl,
                title: p.fullName,
                subtitle: "",
                detail: showsSalary
                    ? String(
                        format: ConstantStrings.incomeFormat,
                        p.salaryText ?? ConstantStrings.dashPlaceholder
                    )
                    : nil,
                editAction: { showEditPersonalProfile = true }
            )

            infoGroup(title: ConstantStrings.personalInfoSectionHeader) {
                infoSection(
                    title: ConstantStrings.identityLabel,
                    value: p.tcIdentityNumber ?? ConstantStrings.dashPlaceholder,
                    icon: "person.text.rectangle"
                )

                infoSection(
                    title: ConstantStrings.emailLabel,
                    value: p.email,
                    icon: "envelope"
                )
            }

            documentsSection(
                title: ConstantStrings.documentsLabel,
                documents: p.documentFiles
            )

            LeaveSectionView(
                leaves: p.leaveRequests,
                onCreateLeave: { showCreateLeave = true },
                onShowAll: { showMyLeaves = true }
            )
            .unifiedCard()

            PerformanceSectionView(
                reports: perfVM.reports,
                isLoading: perfVM.isLoading,
                error: perfVM.error,
                onCreateQuery: { showQuery = true },
                onSelectReport: { selectedReportId = $0 }
            )
            .unifiedCard()
        }
    }

    // MARK: - Manager Profile

    private func managerProfile(_ m: ManagerProfileUI) -> some View {
        VStack(spacing: 14) {

            profileHeaderCard(
                imageUrl: m.companyImageUrl,
                title: m.companyName,
                subtitle: trimmedOrNil(m.companyDescription) ?? ConstantStrings.companyNoDescription,
                detail: nil,
                editAction: { showEditCompany = true }
            )
            .padding(.horizontal, 16)

            companyDetailsSection(m)
                .padding(.horizontal, 16)

            officesSection(offices: m.offices)
                .padding(.horizontal, 16)

            managementActionsSection
                .padding(.horizontal, 16)

            SlackIntegrationSection(
                integrations: slackVM.integrations,
                isLoading: slackVM.isLoading,
                onAdd: { showAddSlackIntegration = true },
                onSelect: { selectedSlackIntegration = $0 }
            )
            .unifiedCard()
            .padding(.horizontal, 16)

            employeeProfile(m.employee, showsSalary: false)
                .padding(.horizontal, 16)
        }
    }

    // MARK: - Management Actions

    private var managementActionsSection: some View {
        infoGroup(title: ConstantStrings.managementActionsTitle) {
            Button {
                showLeaveManagement = true
            } label: {
                rowCard(
                    icon: "calendar.badge.checkmark",
                    title: ConstantStrings.leaveRequestsTitle,
                    subtitle: ConstantStrings.leaveRequestsSubtitle,
                    trailingIcon: "chevron.right"
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Header Card

    private func profileHeaderCard(
        imageUrl: String?,
        title: String,
        subtitle: String,
        detail: String?,
        editAction: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 14) {

            let abs = network.absoluteURL(from: imageUrl)

            AvatarView(url: abs, size: 64, refreshId: avatarRefreshToken)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                if !subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                if let detail = trimmedOrNil(detail) {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Button(action: editAction) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.10))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: - Company Details

    private func companyDetailsSection(_ m: ManagerProfileUI) -> some View {
        infoGroup(title: ConstantStrings.companyInfoSectionTitle) {
            infoSection(
                title: ConstantStrings.emailLabel,
                value: m.companyEmail,
                icon: "envelope"
            )

            if let officeName = trimmedOrNil(m.companyLocationName) {
                infoSection(
                    title: ConstantStrings.mainOfficeTitle,
                    value: officeName,
                    icon: "building.2"
                )
            }

            if let city = trimmedOrNil(m.companyCityLine),
               city != ConstantStrings.dashPlaceholder {
                infoSection(
                    title: ConstantStrings.cityDistrictTitle,
                    value: city,
                    icon: "mappin.and.ellipse"
                )
            }

            if let phone = trimmedOrNil(m.companyPhoneNumber) {
                tappableInfoRow(
                    title: ConstantStrings.phoneLabel,
                    value: phone,
                    icon: "phone.fill"
                ) {
                    openPhone(phone)
                }
            }

            if let addr = trimmedOrNil(m.companyAddress) {
                infoSection(
                    title: ConstantStrings.addressPlaceholder,
                    value: addr,
                    icon: "map"
                )
            }
        }
    }

    // MARK: - Offices

    private func officesSection(offices: [OfficeUI]) -> some View {
        infoGroup(title: ConstantStrings.officesTitle) {
            if offices.isEmpty {
                emptyRow(
                    text: ConstantStrings.noRegisteredOffice,
                    icon: "building.2.crop.circle"
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(offices.enumerated()), id: \.element.id) { idx, office in
                        Button {
                            openAppleMaps(for: office)
                        } label: {
                            rowCard(
                                icon: "building.2",
                                title: office.name.isEmpty
                                    ? String(format: ConstantStrings.officeDefaultNameFormat, idx + 1)
                                    : office.name,
                                subtitle: office.hasCoordinate
                                    ? ConstantStrings.openInMap
                                    : ConstantStrings.noLocationInfo,
                                trailingIcon: office.hasCoordinate ? "chevron.right" : nil
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(!office.hasCoordinate)
                    }
                }
            }
        }
    }

    // MARK: - Documents

    private func documentsSection(
        title: String,
        documents: [BusinessMemberDocumentDTO]?
    ) -> some View {
        infoGroup(title: title) {
            let docs = documents ?? []

            if docs.isEmpty {
                emptyRow(
                    text: ConstantStrings.noDocumentFound,
                    icon: "doc"
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(docs, id: \.id) { document in
                        Button {
                            previewDoc = .init(
                                id: document.id,
                                title: document.fileName,
                                documentId: document.id
                            )
                        } label: {
                            rowCard(
                                icon: "doc.text",
                                title: document.fileName,
                                subtitle: ConstantStrings.previewText,
                                trailingIcon: "chevron.right"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Reusable UI

    private func infoGroup<Content: View>(
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

    private func infoSection(
        title: String,
        value: String,
        icon: String
    ) -> some View {
        rowCard(
            icon: icon,
            title: title,
            subtitle: value,
            trailingIcon: nil
        )
    }

    private func tappableInfoRow(
        title: String,
        value: String,
        icon: String,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            rowCard(
                icon: icon,
                title: title,
                subtitle: value,
                trailingIcon: "phone.circle.fill"
            )
        }
        .buttonStyle(.plain)
    }

    private func rowCard(
        icon: String,
        title: String,
        subtitle: String,
        trailingIcon: String?
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            if let trailingIcon {
                Image(systemName: trailingIcon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.black.opacity(0.055))
                .frame(height: 0.7)
                .padding(.leading, 56)
        }
    }

    private func emptyRow(
        text: String,
        icon: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 30, height: 30)

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    // MARK: - Logout

    private var logoutSection: some View {
        Button {
            Task {
                await vm.logout(appState: appState)
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.10))

                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.red)
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 4) {
                    Text(ConstantStrings.logoutButtonTitle)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.red)

                    Text(ConstantStrings.logoutButtonDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if vm.isLoggingOut {
                    ProgressView()
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.red.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(vm.isLoggingOut)
    }

    // MARK: - Feedback

    private var loadingCard: some View {
        HStack(spacing: 12) {
            ProgressView()

            Text(ConstantStrings.profileLoading)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }

    private func errorCard(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.red)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.red.opacity(0.25), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }

    // MARK: - Helpers

    private func trimmedOrNil(_ s: String?) -> String? {
        let t = (s ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }

    private func loadReportsIfPossible() async {
        guard let bid = appState.businessId,
              let uid = appState.userId else { return }

        await perfVM.load(
            businessId: bid,
            employeeUserId: uid
        )
    }

    private func loadSlackIfPossible() async {
        guard appState.role.canSeePersonnelTab,
              let bid = appState.businessId else { return }

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

        let coordinate = CLLocationCoordinate2D(
            latitude: lat,
            longitude: lng
        )

        let item = MKMapItem(
            placemark: MKPlacemark(coordinate: coordinate)
        )

        item.name = office.name

        item.openInMaps(
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey:
                    MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }

    private func loadingSheet() -> some View {
        VStack(spacing: 12) {
            ProgressView()

            Text(ConstantStrings.loadingText)
                .foregroundStyle(.secondary)
        }
        .padding()
        .presentationDetents([.medium])
    }
}

// MARK: - View Helper

private extension View {

    func unifiedCard() -> some View {
        self
            .padding(14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
    }
}

