
import SwiftUI
import PDFKit

struct ProfileView: View {

    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = ProfileViewModel()

    @State private var showEditPersonalProfile = false
    @State private var showEditCompany = false
    @State private var previewDoc: DocumentToPreview?

    private let network = NetworkManager()
    private var authRepo: AuthRepositoryProtocol { AuthRepositoryImpl(network: network) }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                if vm.isLoading {
                    ProgressView().padding(.top, 24)
                }

                if let err = vm.errorMessage {
                    Text(err).foregroundColor(.red)
                }

                if let m = vm.managerUI {
                    managerProfile(m)
                }

                if let e = vm.employeeUI {
                    employeeProfile(e)
                }

                Spacer().frame(height: 40)
            }
        }
        .task { await vm.load(appState: appState) }

        .sheet(isPresented: $showEditPersonalProfile) {
            EditPersonalProfileView(authRepo: authRepo)
        }

        .sheet(isPresented: $showEditCompany) {
            EditCompanyView(authRepo: authRepo)
        }

        .sheet(item: $previewDoc) { doc in
            DocumentPreviewSheet(
                title: doc.title,
                documentId: doc.documentId,
                network: network
            )
        }
    }

    // MARK: - Employee
    private func employeeProfile(_ p: EmployeeProfileUI) -> some View {
        VStack(spacing: 24) {

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center) {

                    let abs = network.absoluteURL(from: p.imageUrl)
                    AvatarView(url: network.cacheBusted(abs), size: 60)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(p.fullName).font(.title3.bold())
                        Text("Ünvan: \(p.position ?? "-")").font(.subheadline).foregroundColor(.gray)
                        Text("Gelir: \(p.salaryText ?? "-")").font(.subheadline).foregroundColor(.gray)
                    }

                    Spacer()

                    Button(action: { showEditPersonalProfile = true }) {
                        Text("Düzenle")
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.white)
            }
            .padding(.top, 20)

            VStack(alignment: .leading, spacing: 16) {
                infoSection(title: "Kimlik", value: p.tcIdentityNumber ?? "-")
                infoSection(title: "Email", value: p.email)
                documentsSection(title: "Belgeler", documents: p.documentFiles)
                infoSection(title: "Kalan İzin Günü", value: p.remainingLeaveDaysText)
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Manager
    private func managerProfile(_ m: ManagerProfileUI) -> some View {
        VStack(spacing: 16) {

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center) {

                    let abs = network.absoluteURL(from: m.employee.imageUrl)
                    AvatarView(url: network.cacheBusted(abs), size: 60)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(m.companyName).font(.title3.bold())

                        if let desc = m.companyDescription, !desc.isEmpty {
                            Text("Açıklama: \(desc)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Text(m.companyEmail)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Button(action: { showEditCompany = true }) {
                        Text("Düzenle")
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.white)
            }
            .padding(.top, 20)

            officesSection(offices: m.offices)
                

            Divider().padding(.horizontal)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    let abs2 = network.absoluteURL(from: m.employee.imageUrl)
                    AvatarView(url: network.cacheBusted(abs2), size: 44)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(m.employee.fullName).font(.headline)
                        Text("Ünvan: \(m.employee.position ?? "-")").foregroundColor(.gray).font(.subheadline)
                        Text("Gelir: \(m.employee.salaryText ?? "-")").foregroundColor(.gray).font(.subheadline)
                    }

                    Spacer()

                    Button(action: { showEditPersonalProfile = true }) {
                        Text("Düzenle")
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }

                infoSection(title: "Kimlik", value: m.employee.tcIdentityNumber ?? "-")
                documentsSection(title: "Belgeler", documents: m.employee.documentFiles)
                infoSection(title: "Email", value: m.employee.email)
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Ofisler UI
    private func officesSection(offices: [OfficeUI]) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            if offices.isEmpty {
                Text("-")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(offices.enumerated()), id: \.element.id) { idx, o in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ofis \(idx + 1)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.gray)

                            infoSection(title: "Ofis Adı", value: o.name)
                            infoSection(title: "Adres", value: o.address)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }

    // MARK: - Helpers
    private func infoSection(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(value)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
    }

    private func documentsSection(title: String, documents: [BusinessMemberDocumentDTO]?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)

            let docs = documents ?? []
            if docs.isEmpty {
                Text("-")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(docs, id: \.id) { d in
                        Button {
                            previewDoc = .init(id: d.id, title: d.fileName, documentId: d.id)
                        } label: {
                            Text(d.fileName)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
}
