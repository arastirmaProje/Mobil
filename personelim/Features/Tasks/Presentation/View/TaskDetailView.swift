import SwiftUI

struct TaskDetailView: View {

    // MARK: - Input
    let task: TaskEntity
    let currentUserId: String?
    let onTaskUpdated: () -> Void

    @Environment(\.dismiss) private var dismiss

    // MARK: - UI State
    @State private var showStatusPicker = false
    @State private var selectedStatus: TaskStatus?
    @State private var navigateToFeedback = false

    enum TaskStatus: String {
        case completed = "Tamamlandı"
        case pending = "Tamamlanmadı"
    }

    // MARK: - Derived States
    private var isCompleted: Bool {
        selectedStatus == .completed || task.status.lowercased() == "tamamlandı"
    }

    private var isExpired: Bool {
        !isCompleted && task.endDate < Date()
    }

    private var statusText: String {
        if isCompleted { return "Tamamlandı" }
        if isExpired { return "Süresi geçti" }
        return "Beklemede"
    }

    private var statusColor: Color {
        if isCompleted { return .green }
        if isExpired { return .red }
        return .orange
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    dateSection
                    descriptionSection
                    statusSection
                    footerSection
                }
                .padding(.bottom, 40)
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToFeedback) {
                TaskFeedbackView(
                    task: task,
                    onSaved: {
                        onTaskUpdated()
                        dismiss()
                    }
                )
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if selectedStatus == .completed {
                            navigateToFeedback = true
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundStyle(
                                selectedStatus == .completed ? .primary : .secondary
                            )
                            .font(.headline)
                    }
                    .disabled(selectedStatus != .completed)
                }
            }
        }
    }
}

// MARK: - UI Sections
private extension TaskDetailView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(task.title)
                .font(.title2.bold())

            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)

                Text(statusText)
                    .font(.subheadline.bold())
                    .foregroundColor(statusColor)
            }

            if let assignedBy = task.assignedByName {
                Text("\(assignedBy) tarafından atandı")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tarih aralığı")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Başlangıç")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(task.startDate.formatted(date: .long, time: .omitted))
                        .font(.body.bold())
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Bitiş")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(task.endDate.formatted(date: .long, time: .omitted))
                        .font(.body.bold())
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Görev detayı")
                .font(.headline)

            Text(task.description ?? "Detay eklenmemiş.")
                .font(.body)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }


    var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Durumu seçiniz")
                .font(.headline)

            Button {
                withAnimation { showStatusPicker.toggle() }
            } label: {
                HStack {
                    Text(selectedStatus?.rawValue ?? "Seçiniz")
                        .foregroundColor(selectedStatus == nil ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }

            if showStatusPicker {
                VStack(spacing: 0) {
                    Button {
                        selectedStatus = .completed
                        showStatusPicker = false
                    } label: {
                        HStack {
                            Text("Tamamlandı")
                            Spacer()
                        }
                        .padding()
                    }

                    Divider()

                    Button {
                        selectedStatus = .pending
                        showStatusPicker = false
                    } label: {
                        HStack {
                            Text("Tamamlanmadı")
                            Spacer()
                        }
                        .padding()
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }

    var footerSection: some View {
        VStack {
            if isCompleted {
                Label("Bu görev tamamlandı", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else if isExpired {
                Label("Görev süresi geçti", systemImage: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal)
    }
}
