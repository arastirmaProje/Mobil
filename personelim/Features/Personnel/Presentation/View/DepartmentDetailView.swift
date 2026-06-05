
import SwiftUI

struct DepartmentDetailView: View {
    let departmentId: String
    let departmentName: String
    let businessId: String
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    @StateObject private var memberViewModel = BusinessMemberViewModel()
    @StateObject private var deptViewModel = DepartmentViewModel()
    
    @State private var showAddMemberSheet = false
    @State private var showDeleteAlert = false
    @State private var showEditSheet = false
    
    @State private var startDate = Date().addingTimeInterval(-604800)
    @State private var endDate = Date()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                
          
                headerSection
                
            
                performanceQuerySection
                
           
                if let performance = deptViewModel.departmentPerformance {
                    aiAnalysisSection(performance)
                    
                    employeeScoresSection(performance)
                }
                
          
                employeesSection
                
                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: { showAddMemberSheet = true }) {
                        Label(ConstantStrings.addMemberAction, systemImage: "person.badge.plus")
                    }
                    
                    Button(action: { showEditSheet = true }) {
                        Label(ConstantStrings.editDepartmentAction, systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: { showDeleteAlert = true }) {
                        Label(ConstantStrings.deleteDepartmentAction, systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .task {
            await memberViewModel.fetchMembers(businessId: businessId)
        }
        .sheet(isPresented: $showAddMemberSheet) {
            AddMemberView(businessId: businessId, departmentId: departmentId)
        }
        .sheet(isPresented: $showEditSheet) {
            EditDepartmentView(
                viewModel: deptViewModel,
                departmentId: departmentId,
                departmentName: departmentName,
                businessId: businessId,
                initialCategoryId: 1,
                onComplete: {
                    dismiss()
                }
            )
            .presentationDetents([.medium, .large])
        }
        .confirmationDialog(ConstantStrings.deleteDepartmentAction, isPresented: $showDeleteAlert, titleVisibility: .visible) {
            Button(ConstantStrings.deleteButton, role: .destructive) {
                Task {
                    await deptViewModel.deleteDepartment(id: departmentId, businessId: businessId)
                    dismiss()
                }
            }
            Button(ConstantStrings.cancelButton, role: .cancel) { }
        } message: {
            Text(ConstantStrings.deleteDepartmentConfirmation)
        }
        .alert(ConstantStrings.errorTitle, isPresented: Binding<Bool>(
            get: { deptViewModel.errorMessage != nil },
            set: { _ in deptViewModel.errorMessage = nil }
        )) {
            Button(ConstantStrings.okButton, role: .cancel) { }
        } message: {
            Text(deptViewModel.errorMessage ?? "")
        }
    }
    
    // MARK: - Header Section View
    private var headerSection: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(UIColor.systemGray5))
                .frame(width: 52, height: 52)
                .overlay(
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(departmentName)
                    .font(.system(size: 22, weight: .bold))
                
                let filteredMembersCount = memberViewModel.members.filter({ $0.departmentId == departmentId }).count
                Text("\(filteredMembersCount) \(ConstantStrings.employeesHeader)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.top, 4)
    }
    
    // MARK: - Performance Query Fields View
    private var performanceQuerySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Departman Performans Sorgulama")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 12) {
                DatePicker("Başlangıç Tarihi", selection: $startDate, displayedComponents: .date)
                    .font(.system(size: 15, weight: .medium))
                
                Divider()
                
                DatePicker("Bitiş Tarihi", selection: $endDate, displayedComponents: .date)
                    .font(.system(size: 15, weight: .medium))
                
                Divider()
                
                Button(action: {
                    Task {
                        await deptViewModel.fetchDepartmentPerformance(
                            businessId: businessId,
                            departmentId: departmentId,
                            startDate: startDate,
                            endDate: endDate
                        )
                    }
                }) {
                    HStack {
                        Spacer()
                        if deptViewModel.isPerformanceLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Performansı Sorgula")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .background(deptViewModel.isPerformanceLoading ? Color.blue.opacity(0.6) : Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(deptViewModel.isPerformanceLoading)
                .buttonStyle(.plain)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
            )
        }
    }
    
    // MARK: - AI Analysis Score & Summary Card
    private func aiAnalysisSection(_ performance: DepartmentPerformanceResponseDTO) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Performans Analizi")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 16) {
                // Skor Üst Alanı
                HStack(spacing: 14) {
                    ScoreMiniGauge(score: Int(performance.departmanSkoru))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Genel Performans Skoru")
                            .font(.system(size: 14, weight: .semibold))
                        Text("\(performance.toplamCalisan) Aktif Çalışan Analiz Edildi")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                
                Divider()
                
                // Rapor Özeti
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "brain.headlight.lens")
                            .foregroundColor(.purple)
                            .font(.system(size: 14, weight: .semibold))
                        Text("Rapor Özeti")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.purple)
                    }
                    Text(performance.raporOzeti)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                }
                
                Divider()
                
                // Detaylı Analiz
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .foregroundColor(.blue)
                            .font(.system(size: 14, weight: .semibold))
                        Text("Detaylı Analiz Raporu")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    Text(performance.detayliRapor)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
            )
        }
    }
    
    // MARK: - Employee Performance Scores List View
    private func employeeScoresSection(_ performance: DepartmentPerformanceResponseDTO) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Çalışan Dönem Skorları")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.secondary)
            
            if performance.calisanSkorlari.isEmpty {
                Text("Bu dönemde kaydedilmiş çalışan skoru bulunamadı.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
            } else {
                VStack(spacing: 10) {
                    ForEach(performance.calisanSkorlari) { calisan in
                        HStack(spacing: 12) {
                            ScoreMiniGauge(score: Int(calisan.performansSkoru))
                            
                            Text(calisan.adSoyad)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(String(format: "%.1f Puan", calisan.performansSkoru))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(calisan.performansSkoru < 40 ? .red : .green)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Employees List Section View
    private var employeesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(ConstantStrings.employeesHeader)
                .font(.system(size: 18, weight: .semibold))
            
            let filteredMembers = memberViewModel.members.filter({ $0.departmentId == departmentId })
            
            if filteredMembers.isEmpty {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGray6))
                    .frame(height: 70)
                    .overlay(
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color(UIColor.systemGray5))
                                .frame(width: 44, height: 44)
                                .overlay(Image(systemName: "person.slash.fill").foregroundColor(.gray))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(ConstantStrings.noEmployeesInDepartment)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                    )
            } else {
                VStack(spacing: 10) {
                    ForEach(filteredMembers) { member in
                        NavigationLink(destination: PersonnelDetailView(memberId: member.id)) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
                                .frame(height: 74)
                                .overlay(
                                    HStack(spacing: 14) {
                                        Circle()
                                            .fill(Color(UIColor.systemGray5))
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Image(systemName: "person.fill")
                                                    .foregroundColor(.blue)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(member.fullName)
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(.primary)
                                            
                                            Text(member.positionName ?? ConstantStrings.defaultPosition)
                                                .font(.system(size: 13))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, 14)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Mini Radial Gauge (PersonnelDetailView'dan Alınan Yapı)
private struct ScoreMiniGauge: View {
    let score: Int
    
    private func scoreColor(_ s: Int) -> Color {
        switch s {
        case 0..<40: return .red
        case 40..<70: return .orange
        case 70..<85: return .blue
        default: return .green
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 5)

            Circle()
                .trim(from: 0, to: CGFloat(max(0, min(score, 100))) / 100)
                .stroke(
                    scoreColor(score),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Text("\(score)")
                .font(.system(size: 11, weight: .bold))
        }
        .frame(width: 40, height: 40)
    }
}


