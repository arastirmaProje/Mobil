//
//  TaskDetailView.swift
//  personelim
//
//  Created by Tuğberk Acabey on 19.12.2025.
//

import SwiftUI

struct TaskDetailView: View {

    // MARK: - Properties
    let task: TaskEntity
    let currentUserId: String?

    @Environment(\.dismiss) private var dismiss

    // MARK: - Derived States
    private var isCompleted: Bool {
        task.status.lowercased() == "tamamlandı"
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
        ScrollView {
            VStack(spacing: 24) {

                topBar
                headerSection
                dateSection
                descriptionSection
                footerSection

                Spacer(minLength: 40)
            }
            .padding(.bottom, 32)
        }
        .navigationBarBackButtonHidden(true)
    }
}

private extension TaskDetailView {

    var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
}

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
}

private extension TaskDetailView {

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
}

private extension TaskDetailView {

    var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Görev detayı")
                .font(.headline)

            Text(task.description ?? "Detay eklenmemiş.")
                .font(.body)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

private extension TaskDetailView {

    var footerSection: some View {
        VStack(spacing: 12) {

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
